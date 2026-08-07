const cds = require('@sap/cds');
const registerCustomerLifecycleHandlers = require('./handlers/customer-lifecycle');
const registerCustomerNoteHandlers = require('./handlers/customer-notes');

module.exports = class CRMService extends cds.ApplicationService {
    async init() {
        registerCustomerLifecycleHandlers(this);
        registerCustomerNoteHandlers(this);
        return super.init();
    }
};