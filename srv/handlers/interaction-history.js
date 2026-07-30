const cds = require('@sap/cds');

module.exports = function registerInteractionHistoryHandlers(srv) {
    srv.after(
        'CREATE',
        'Feedbacks',
        async (feedback) => {
            const db = await cds.connect.to('db');
            await db.create('crm.Interaction').entries({
                customerID_customerID:
                    feedback.customerID_customerID,
                date:
                    feedback.feedbackDate,
                method:
                    'Feedback',
                summary:
                    `Customer submitted feedback with rating ${feedback.rating}`
            });
        }
    );
};