const cds = require('@sap/cds');
const {
    recomputeAverageRating,
    recomputeStatus,
    recomputeCategoryPreference,
    reconcileFeedbackInteractions
} = require('./customer-derived-fields');

module.exports = function registerCustomerLifecycleHandlers(srv) {

    srv.before('CREATE', 'Customers', async (req) => {
        if (!req.data.statusCode_code) {
            req.data.statusCode_code = 'INACTIVE';
        }
    });

    srv.after('SAVE', 'Customers', async (customer) => {
        const customerID = customer.customerID;
        if (!customerID) {
            console.warn('[customer-lifecycle.js] SAVE fired without customerID');
            return;
        }

        const db = await cds.connect.to('db');

        console.log(`[customer-lifecycle.js] Recalculating derived fields for ${customerID}`);

        await reconcileFeedbackInteractions(db, customerID);
        await recomputeCategoryPreference(db, customerID);
        await recomputeAverageRating(db, customerID);
        await recomputeStatus(db, customerID);
    });
};