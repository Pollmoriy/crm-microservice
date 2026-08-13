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

    srv.after('SAVE', 'Customers', async (customer, req) => {
        const record = Array.isArray(customer) ? customer[0] : customer;

        const customerID =
            record?.customerID ||
            req?.data?.customerID ||
            (req?.params?.[0] && req.params[0].customerID) ||
            (req?.params?.[0] && req.params[0].ID);

        if (!customerID) {
            return;
        }

        const tx = cds.tx(req);

        await reconcileFeedbackInteractions(tx, customerID);
        await recomputeCategoryPreference(tx, customerID);
        await recomputeAverageRating(tx, customerID);
        await recomputeStatus(tx, customerID);
    });
};