const cds = require('@sap/cds');

module.exports = function registerCustomerPreferenceHandlers(srv) {
    srv.after(
        'CREATE',
        'Interactions',
        async (interaction) => {
            const customerID =
                interaction.customerID_customerID;
            if (!customerID) {
                console.log("No customer ID");
                return;
            }
            const db = await cds.connect.to('db');
            const interactions =
                await db.run(
                    SELECT.from('crm.Interaction')
                    .where({
                        customerID_customerID:
                        customerID
                    })
                );
            if (!interactions.length) {
                return;
            }
            const productCounter = {};
            interactions.forEach(item => {
                const product =
                    item.method;
                if (!product) {
                    return;
                }
                if (!productCounter[product]) {
                    productCounter[product] = 0;
                }
                productCounter[product]++;
            });
            const preferredProduct =
                Object.keys(productCounter)
                .reduce((a, b) =>
                    productCounter[a] >= productCounter[b]
                    ? a
                    : b
                );
            const existingPreference =
                await db.run(
                    SELECT.one
                    .from('crm.Preference')
                    .where({
                        customerID_customerID:
                        customerID
                    })
                );
            if (existingPreference) {
                await db.run(
                    UPDATE('crm.Preference')
                    .set({
                        productCategory:
                        preferredProduct,
                        notes:
                        `Ordered ${productCounter[preferredProduct]} times`
                    })
                    .where({
                        preferenceID:
                        existingPreference.preferenceID
                    })
                );
            } else {
                await db.run(
                    INSERT.into('crm.Preference')
                    .entries({
                        productCategory:
                        preferredProduct,
                        notes:
                        `Ordered ${productCounter[preferredProduct]} times`,
                        customerID_customerID:
                        customerID
                    })
                );
            }
            const categoryCounter = {};
            const categories = {
                "Marketing Materials":
                [
                    "Flyers",
                    "Posters",
                    "Brochures"
                ],

                "Business Printing":
                [
                    "Business Cards"
                ],

                "Large Format Printing":
                [
                    "Large Format Printing"
                ]
            };
            Object.entries(productCounter)
            .forEach(([product, count]) => {
                let category = null;
                for (
                    const [categoryName, products]
                    of Object.entries(categories)
                ) {
                    if (
                        products.includes(product)
                    ) {
                        category =
                        categoryName;
                        break;
                    }
                }
                if (category) {
                    if (!categoryCounter[category]) {
                        categoryCounter[category] = 0;

                    }
                    categoryCounter[category] += count;
                }
            });
            const customerCategory =
                Object.keys(categoryCounter)
                .reduce((a, b) =>
                    categoryCounter[a] >= categoryCounter[b]
                    ? a
                    : b
                );
            await db.run(
                UPDATE('crm.Customer')
                .set({
                    categoryGroup:
                    customerCategory
                })
                .where({
                    customerID:
                    customerID
                })
            );
        }
    );
};