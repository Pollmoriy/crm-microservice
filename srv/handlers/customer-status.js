const cds = require('@sap/cds');

module.exports = function registerCustomerStatusHandlers(service) {
    service.before(
    'CREATE',
    'Customers',
    async (req) => {
            if (!req.data.statusCode_code) {
                req.data.statusCode_code = 'INACTIVE';
            }

        }
    );

    service.after(
        'CREATE',
        'Interactions',
        async (interaction) => {
            const db = await cds.connect.to('db');
            const customerID = interaction.customerID_customerID;
            if (!customerID) {
                return;
            }
            const sixMonthsAgo = new Date();
            sixMonthsAgo.setMonth(
                sixMonthsAgo.getMonth() - 6
            );
            const recentInteractions = await db.run(
                SELECT.from('crm.Interaction')
                    .where({
                        customerID_customerID: customerID
                    })
            );
            const hasRecentActivity = recentInteractions.some(
                item => new Date(item.date) >= sixMonthsAgo
            );
            const status = hasRecentActivity
                ? 'ACTIVE'
                : 'INACTIVE';
            await db.run(
                UPDATE('crm.Customer')
                    .set({
                        statusCode_code: status
                    })
                    .where({
                        customerID
                    })
            );
        }
    );

    service.after(
        'CREATE',
        'Feedbacks',
        async (feedback) => {
            const db = await cds.connect.to('db');
            const customerID =
                feedback.customerID_customerID;
            if (!customerID) {
                return;
            }
            let status = 'ACTIVE';
            if (feedback.rating < 3) {
                status = 'AT_RISK';
            }
            await db.run(
                UPDATE('crm.Customer')
                    .set({
                        statusCode_code: status
                    })
                    .where({
                        customerID
                    })
            );
        }
    );

};