const cds = require('@sap/cds');
const registerFeedbackHandlers = require('./handlers/feedback');
const registerCustomerStatusHandlers = require('./handlers/customer-status');
const registerPreferenceHandlers = require('./handlers/customer-preferences');
const registerInteractionHistoryHandlers = require('./handlers/interaction-history');

module.exports = class CRMService extends cds.ApplicationService {
    async init() {
        registerFeedbackHandlers(this);
        registerCustomerStatusHandlers(this);
        registerPreferenceHandlers(this);
        registerInteractionHistoryHandlers(this);
        return super.init();
    }

}