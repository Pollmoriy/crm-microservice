const cds = require('@sap/cds');
const registerFeedbackHandlers = require('./handlers/feedback');

module.exports = class CRMService extends cds.ApplicationService {
    async init() {
        registerFeedbackHandlers(this);
        return super.init();
    }

}