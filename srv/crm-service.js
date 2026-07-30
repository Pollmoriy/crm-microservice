const cds = require('@sap/cds');
const registerFeedbackHandlers = require('./handlers/feedback');
const registerCustomerStatusHandlers = require('./handlers/customer-status');
module.exports = class CRMService extends cds.ApplicationService {
    async init() {
        registerFeedbackHandlers(this);
        registerCustomerStatusHandlers(this);
        return super.init();
    }

}