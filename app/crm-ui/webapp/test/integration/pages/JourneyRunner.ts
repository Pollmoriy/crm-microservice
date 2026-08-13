import JourneyRunner from "sap/fe/test/JourneyRunner";
import ListReport from "sap/fe/test/ListReport";
import ObjectPage from "sap/fe/test/ObjectPage";
import CustomCustomersListGenerated from "./CustomersList.gen";
import CustomCustomersObjectPageGenerated from "./CustomersObjectPage.gen";
import CustomInteractionsObjectPageGenerated from "./InteractionsObjectPage.gen";

const runner = new JourneyRunner({
    launchUrl: sap.ui.require.toUrl("crm/crmui") + "/test/flpSandbox.html#crmcrmui-tile",
    pages: {
        onTheCustomersListGenerated: new ListReport(
            {
                appId: "crm.crmui",
                componentId: "CustomersList",
                entitySet: "",
                contextPath: "/Customers"
            },
            CustomCustomersListGenerated
        ),
        onTheCustomersObjectPageGenerated: new ObjectPage(
            {
                appId: "crm.crmui",
                componentId: "CustomersObjectPage",
                entitySet: "",
                contextPath: "/Customers"
            },
            CustomCustomersObjectPageGenerated
        ),
        onTheInteractionsObjectPageGenerated: new ObjectPage(
            {
                appId: "crm.crmui",
                componentId: "InteractionsObjectPage",
                entitySet: "",
                contextPath: "/Customers/interactions"
            },
            CustomInteractionsObjectPageGenerated
        )
    },
    async: true
});

export default runner;
