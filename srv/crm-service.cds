using crm from '../db/schema';

@path: '/crm'
@description: 'Customer Relationship Management Service'
service CRMService {
    entity Customers as projection on crm.Customer;
    entity Preferences as projection on crm.Preference;
    entity Feedbacks as projection on crm.Feedback;
    entity Interactions as projection on crm.Interaction;
    entity CustomerNotes as projection on crm.CustomerNote;
    entity MarketingCampaigns as projection on crm.MarketingCampaign;
    entity CustomerStatusCodes as projection on crm.CustomerStatusCode;
}