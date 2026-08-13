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
        // Временная диагностика — покажет реальную структуру payload в логах
        console.log('[customer-lifecycle.js] RAW customer payload:', JSON.stringify(customer));
        console.log('[customer-lifecycle.js] RAW req.data:', JSON.stringify(req?.data));
        console.log('[customer-lifecycle.js] RAW req.params:', JSON.stringify(req?.params));

        const record = Array.isArray(customer) ? customer[0] : customer;

        const customerID =
            record?.customerID ||
            req?.data?.customerID ||
            (req?.params?.[0] && req.params[0].customerID) ||
            (req?.params?.[0] && req.params[0].ID);

        if (!customerID) {
            console.warn('[customer-lifecycle.js] SAVE fired without customerID — check RAW logs above');
            return;
        }

        const tx = cds.tx(req);

        console.log(`[customer-lifecycle.js] Recalculating derived fields for ${customerID}`);

        await reconcileFeedbackInteractions(tx, customerID);
        await recomputeCategoryPreference(tx, customerID);
        await recomputeAverageRating(tx, customerID);
        await recomputeStatus(tx, customerID);
    });
};