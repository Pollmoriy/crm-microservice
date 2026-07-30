namespace crm;

entity CustomerStatusCode {
    key code : String(20);
    @mandatory
    description : String(500);
}

entity Customer {
    key customerID : UUID;
    @mandatory
    @assert.format: '^[A-Za-zÀ-ÿА-Яа-яЁё'' -]{2,100}$'
    firstName : String(100);
    @mandatory
    @assert.format: '^[A-Za-zÀ-ÿА-Яа-яЁё'' -]{2,100}$'
    lastName  : String(100);
    @mandatory
    @assert.format: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    email : String(150);
    @mandatory
    @assert.format: '^\+?[0-9() \-]{7,20}$'
    phone : String(30);
    averageRating : Decimal(3,2) default 0;
    categoryGroup : String(100);
    lastInteractionDate : Date;
    statusCode : Association to CustomerStatusCode;
    interactions : Composition of many Interaction on interactions.customerID = $self;
    preferences : Association to many Preference on preferences.customerID = $self;
    feedbacks : Association to many Feedback on feedbacks.customerID = $self;
    notes : Composition of many CustomerNote on notes.customerID = $self;
    campaigns : Association to many CustomerCampaigns on campaigns.customer = $self;
}

entity Preference {
    key preferenceID : UUID;
    @mandatory
    productCategory : String(100);
    notes : String(500);
    @mandatory
    customerID : Association to Customer;
}

entity Feedback {
    key feedbackID : UUID;
    @mandatory
    @assert.range: [1,5]
    rating : Integer;
    @mandatory
    comments : String(1000);
    @mandatory
    feedbackDate : Date;
    @mandatory
    customerID : Association to Customer;
}

entity Interaction {
    key interactionID : UUID;
    @mandatory
    date : Date;
    @mandatory
    method : String(100);
    @mandatory
    summary : String(1000);
    @mandatory
    customerID : Association to Customer;
}

entity CustomerNote {
    key noteID : UUID;
    @mandatory
    content : String(1000);
    @mandatory
    authorID : String(100);
    @mandatory
    date : Date;
    @mandatory
    customerID : Association to Customer;
}

entity MarketingCampaign {
    key campaignID : UUID;
    @mandatory
    name : String(200);
    @mandatory
    startDate : Date;
    endDate : Date;
    description : String(1000);
    customers : Association to many CustomerCampaigns on customers.campaign = $self;
}

entity CustomerCampaigns {
    key customer : Association to Customer;
    key campaign : Association to MarketingCampaign;
}