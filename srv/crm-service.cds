using crm from '../db/schema';

@path: '/crm'
@description: 'Customer Relationship Management Service'
service CRMService {

    @odata.draft.enabled
    @(restrict: [
        { grant: '*',                       to: 'CRMAdmin' },
        { grant: ['READ', 'UPDATE'],        to: 'SalesManager' },
        { grant: 'READ',                    to: 'SupportAgent' }
    ])
    entity Customers as projection on crm.Customer {
        *,
        interactions       : redirected to Interactions,
        recentInteractions : redirected to RecentInteractions
    };

    @(restrict: [
        { grant: '*',                       to: 'CRMAdmin' },
        { grant: ['READ', 'CREATE'],        to: ['SalesManager', 'SupportAgent'] }
    ])
    entity Interactions as projection on crm.Interaction;

    @readonly
    entity RecentInteractions as projection on crm.Interaction;

    @(restrict: [
        { grant: '*',                       to: 'CRMAdmin' },
        { grant: ['READ', 'CREATE'],        to: 'SalesManager' },
        { grant: 'READ',                    to: 'SupportAgent' }
    ])
    entity Feedbacks as projection on crm.Feedback;

    entity Preferences           as projection on crm.Preference;
    entity CustomerNotes         as projection on crm.CustomerNote;
    entity CustomerStatusCodes   as projection on crm.CustomerStatusCode;
    entity ProductCategoryGroups as projection on crm.ProductCategoryGroup;
    entity ProductCategories     as projection on crm.ProductCategory;
    entity InteractionMethods    as projection on crm.InteractionMethod;

    action calculateRating();

    @odata.singleton
    @cds.persistence.skip
    entity Configuration {
        key ID: String;
        isAdmin: Boolean;
        isSalesManager: Boolean;
        isSupportAgent: Boolean;
    }
}