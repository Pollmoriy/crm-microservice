const cds = require('@sap/cds');
const registerCustomerLifecycleHandlers = require('./handlers/customer-lifecycle');
const registerCustomerNoteHandlers = require('./handlers/customer-notes');

module.exports = class CRMService extends cds.ApplicationService {
    async init() {
        registerCustomerLifecycleHandlers(this);
        registerCustomerNoteHandlers(this);

        this.on('READ', 'Configuration', (req) => {
            return {
                ID: 'current-user',
                isAdmin: req.user.is('CRMAdmin'),
                isSalesManager: req.user.is('SalesManager'),
                isSupportAgent: req.user.is('SupportAgent')
            };
        });

        return super.init();
    }
};