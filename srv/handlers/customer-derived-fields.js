const cds = require('@sap/cds');

async function recomputeAverageRating(db, customerID) {
    const feedbacks = await db.run(
        SELECT.from('crm.Feedback').where({ customerID_customerID: customerID })
    );
    const average = feedbacks.length
        ? feedbacks.reduce((sum, f) => sum + f.rating, 0) / feedbacks.length
        : 0;

    await db.run(
        UPDATE('crm.Customer')
            .set({ averageRating: Number(average.toFixed(2)) })
            .where({ customerID })
    );
}

async function recomputeStatus(db, customerID) {
    const latestFeedback = await db.run(
        SELECT.one.from('crm.Feedback')
            .where({ customerID_customerID: customerID })
            .orderBy('feedbackDate desc')
    );

    if (latestFeedback && latestFeedback.rating < 3) {
        await db.run(UPDATE('crm.Customer').set({ statusCode_code: 'AT_RISK' }).where({ customerID }));
        return;
    }

    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const interactions = await db.run(
        SELECT.from('crm.Interaction').where({ customerID_customerID: customerID })
    );
    const hasRecentActivity = interactions.some(i => new Date(i.date) >= sixMonthsAgo);

    await db.run(
        UPDATE('crm.Customer')
            .set({ statusCode_code: hasRecentActivity ? 'ACTIVE' : 'INACTIVE' })
            .where({ customerID })
    );
}

async function recomputeCategoryPreference(db, customerID) {
    const interactions = await db.run(
        SELECT.from('crm.Interaction').where({ customerID_customerID: customerID })
    );

    const counts = {};
    interactions.forEach(i => {
        const cat = i.productCategory_code;
        if (!cat) return;
        counts[cat] = (counts[cat] || 0) + 1;
    });

    const categoryCodes = Object.keys(counts);
    if (!categoryCodes.length) return;

    const topCategory = categoryCodes.reduce((a, b) => (counts[a] >= counts[b] ? a : b));

    const existingPreference = await db.run(
        SELECT.one.from('crm.Preference').where({ customerID_customerID: customerID })
    );

    if (existingPreference) {
        await db.run(
            UPDATE('crm.Preference')
                .set({ productCategory_code: topCategory, notes: 'Most requested category' })
                .where({ preferenceID: existingPreference.preferenceID })
        );
    } else {
        await db.run(
            INSERT.into('crm.Preference').entries({
                productCategory_code: topCategory,
                notes: 'Most requested category',
                customerID_customerID: customerID
            })
        );
    }

    const category = await db.run(
        SELECT.one.from('crm.ProductCategory').where({ code: topCategory })
    );
    if (!category || !category.group_code) return;

    await db.run(
        UPDATE('crm.Customer').set({ categoryGroup_code: category.group_code }).where({ customerID })
    );
}

async function reconcileFeedbackInteractions(db, customerID) {
    const feedbacks = await db.run(
        SELECT.from('crm.Feedback').where({ customerID_customerID: customerID })
    );
    const feedbackIDs = feedbacks.map(f => f.feedbackID);

    // Создаём или обновляем Interaction для каждого текущего Feedback
    for (const feedback of feedbacks) {
        const existing = await db.run(
            SELECT.one.from('crm.Interaction')
                .where({ sourceFeedback_feedbackID: feedback.feedbackID })
        );

        const summary = `Customer submitted feedback with rating ${feedback.rating}`;

        if (existing) {
            await db.run(
                UPDATE('crm.Interaction')
                    .set({ date: feedback.feedbackDate, summary })
                    .where({ interactionID: existing.interactionID })
            );
        } else {
            await db.run(
                INSERT.into('crm.Interaction').entries({
                    customerID_customerID: customerID,
                    date: feedback.feedbackDate,
                    method_code: 'FEEDBACK',
                    summary,
                    sourceFeedback_feedbackID: feedback.feedbackID
                })
            );
        }
    }

    const allInteractions = await db.run(
        SELECT.from('crm.Interaction').where({ customerID_customerID: customerID })
    );
    const orphaned = allInteractions.filter(
        i => i.sourceFeedback_feedbackID && !feedbackIDs.includes(i.sourceFeedback_feedbackID)
    );

    for (const interaction of orphaned) {
        await db.run(
            DELETE.from('crm.Interaction').where({ interactionID: interaction.interactionID })
        );
    }
}

module.exports = {
    recomputeAverageRating,
    recomputeStatus,
    recomputeCategoryPreference,
    reconcileFeedbackInteractions
};
