const cds = require('@sap/cds');

module.exports = function (srv) {
    srv.after('CREATE', 'Feedbacks', async (feedback) => {
        const customerID = feedback.customerID_customerID;
        if (!customerID) {
            console.log('Customer ID not found');
            return;
        }
        const db = await cds.connect.to('db');
        const feedbacks = await db.run(
            SELECT.from('crm.Feedback').where({
                customerID_customerID: customerID
            })
        );
        const average =
            feedbacks.reduce((sum, item) => sum + item.rating, 0) /
            feedbacks.length;
        await db.run(
            UPDATE('crm.Customer')
                .set({
                    averageRating: Number(average.toFixed(2))
                })
                .where({
                    customerID: customerID
                })
        );
    });
};