const cds = require('@sap/cds');

module.exports = function registerInteractionHistoryHandlers(srv) {
    srv.after('CREATE', 'Feedbacks', async (feedback, req) => {
        const customerID =
            feedback.customerID_customerID ||
            (req?.params?.[0] && req.params[0].customerID);

        if (!customerID) {
            console.warn('[interaction-history.js] customerID not resolved, skipping auto-log');
            return;
        }

        const db = await cds.connect.to('db');
        await db.create('crm.Interaction').entries({
            customerID_customerID: customerID,
            date: feedback.feedbackDate,
            method: 'Feedback',
            summary: `Customer submitted feedback with rating ${feedback.rating}`
        });
    });
};