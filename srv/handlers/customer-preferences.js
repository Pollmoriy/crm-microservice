const cds = require('@sap/cds');


module.exports = function (srv) {


    srv.after(
        'CREATE',
        'Interactions',
        async interaction => {


            const db = await cds.connect.to('db');


            const customerID =
                interaction.customerID_customerID;


            if (!customerID)
                return;



            // Get customer interactions

            const interactions =
                await db.run(
                    SELECT.from('crm.Interaction')
                    .where({
                        customerID_customerID:
                            customerID
                    })
                );



            const categoryCounter = {};



            interactions.forEach(item => {


                const category =
                    item.productCategory_code;


                if (!category)
                    return;



                categoryCounter[category] =
                    (categoryCounter[category] || 0) + 1;


            });



            if (
                Object.keys(categoryCounter)
                .length === 0
            )
                return;



            // Find most popular category


            const preferredCategory =
                Object.keys(categoryCounter)
                .reduce((a,b)=>
                    categoryCounter[a] >= categoryCounter[b]
                    ? a
                    : b
                );



            // Update Preference


            const existingPreference =
                await db.run(
                    SELECT.one
                    .from('crm.Preference')
                    .where({
                        customerID_customerID:
                            customerID
                    })
                );



            if(existingPreference){


                await db.run(
                    UPDATE('crm.Preference')
                    .set({

                        productCategory_code:
                            preferredCategory,

                        notes:
                            `Most requested category`

                    })
                    .where({

                        preferenceID:
                            existingPreference.preferenceID

                    })
                );

            }

            else {


                await db.run(

                    INSERT.into('crm.Preference')
                    .entries({

                        productCategory_code:
                            preferredCategory,

                        notes:
                            `Most requested category`,

                        customerID_customerID:
                            customerID

                    })

                );

            }



            // Get category group


            const category =
                await db.run(

                    SELECT.one
                    .from('crm.ProductCategory')
                    .where({

                        code:
                            preferredCategory

                    })

                );



            if(!category)
                return;



            const group =
                await db.run(

                    SELECT.one
                    .from('crm.ProductCategoryGroup')
                    .where({

                        code:
                            category.group_code

                    })

                );



            if(!group)
                return;



            // Update customer category group


            await db.run(

                UPDATE('crm.Customer')

                .set({

                    categoryGroup_code:
                        group.code

                })

                .where({

                    customerID:
                        customerID

                })

            );



        }

    );


};