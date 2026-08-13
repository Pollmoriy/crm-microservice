const path = require('path');
const cds = require('@sap/cds');

const { GET, POST, expect } = cds.test(path.join(__dirname, '..'));

const admin = { auth: { username: 'admin', password: 'admin' } };
const agent = { auth: { username: 'agent', password: 'agent' } };

describe('CRM business logic', () => {
    let id;

    beforeEach(async () => {
        const draftRes = await POST('/crm/Customers', {
            firstName: 'Polina',
            lastName: 'Shevtsova',
            email: 'polina@example.com',
            phone: '+375296148090'
        }, admin);

        id = draftRes.data.customerID || draftRes.data.ID;

        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=false)/CRMService.draftActivate`, {}, admin);
    });

    it('defaults status to INACTIVE', async () => {
        const { data } = await GET(`/crm/Customers(customerID='${id}',IsActiveEntity=true)`, admin);
        expect(data.statusCode_code).to.equal('INACTIVE');
    });

    it('recalculates averageRating and logs Interaction after Feedback save', async () => {
        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=true)/CRMService.draftEdit`, { PreserveChanges: true }, admin);

        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=false)/feedbacks`, {
            rating: 4,
            comments: 'Great',
            feedbackDate: '2026-01-01'
        }, admin);

        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=false)/CRMService.draftActivate`, {}, admin);

        const { data } = await GET(`/crm/Customers(customerID='${id}',IsActiveEntity=true)`, admin);
        expect(Number(data.averageRating)).to.equal(4);

        const { data: interactions } = await GET(
            `/crm/Interactions?$filter=customerID_customerID eq '${id}' and method_code eq 'FEEDBACK'`,
            admin
        );
        expect(interactions.value.length).to.be.above(0);
    });

    it('marks AT_RISK on low rating', async () => {
        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=true)/CRMService.draftEdit`, { PreserveChanges: true }, admin);

        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=false)/feedbacks`, {
            rating: 2,
            comments: 'Bad',
            feedbackDate: '2026-02-01'
        }, admin);

        await POST(`/crm/Customers(customerID='${id}',IsActiveEntity=false)/CRMService.draftActivate`, {}, admin);

        const { data } = await GET(`/crm/Customers(customerID='${id}',IsActiveEntity=true)`, admin);
        expect(data.statusCode_code).to.equal('AT_RISK');
    });
});

describe('Role-based access', () => {
    it('Support Agent can read', async () => {
        const res = await GET('/crm/Customers', agent);
        expect(res.status).to.equal(200);
    });

    it('Support Agent cannot create', async () => {
        let error;
        try {
            await POST('/crm/Customers', {
                firstName: 'X',
                lastName: 'Y',
                email: 'x@y.com',
                phone: '+491111111'
            }, agent);
        } catch (e) {
            error = e;
        }
        expect(error.response.status).to.equal(403);
    });
});