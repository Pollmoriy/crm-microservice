const cds = require('@sap/cds');

module.exports = function (srv) {
    srv.after('CREATE', 'Feedbacks', async (feedback, req) => {
        const customerID =
            feedback.customerID_customerID ||
            (req?.params?.[0] && req.params[0].customerID);

        if (!customerID) {
            console.warn('[feedback.js] customerID not resolved, skipping rating recalculation');
            return;
        }

        const db = await cds.connect.to('db');
        const feedbacks = await db.run(
            SELECT.from('crm.Feedback').where({ customerID_customerID: customerID })
        );

        if (!feedbacks.length) return;

        const average =
            feedbacks.reduce((sum, item) => sum + item.rating, 0) / feedbacks.length;

        await db.run(
            UPDATE('crm.Customer')
                .set({ averageRating: Number(average.toFixed(2)) })
                .where({ customerID })
        );
    });
};