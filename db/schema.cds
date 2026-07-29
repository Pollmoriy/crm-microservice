namespace crm;

entity CustomerStatusCode {
    key code : String(20);
    description : String(500);
}

entity Customer {
    key customerID : UUID;
    firstName : String(100);
    lastName  : String(100);
    email : String(150);
    phone : String(30);
    statusCode : Association to CustomerStatusCode;
    interactions : Composition of many Interaction on interactions.customerID = $self;
    preferences : Association to many Preference on preferences.customerID = $self;
    feedbacks : Association to many Feedback on feedbacks.customerID = $self;
    notes : Composition of many CustomerNote on notes.customerID = $self;
    campaigns : Association to many CustomerCampaigns on campaigns.customer = $self;
}

entity Preference {
    key preferenceID : UUID;
    productCategory : String(100);
    notes : String(500);
    customerID : Association to Customer;
}

entity Feedback {
    key feedbackID : UUID;
    rating : Integer;
    comments : String(1000);
    feedbackDate : Date;
    customerID : Association to Customer;
}

entity Interaction {
    key interactionID : UUID;
    date : Date;
    method : String(100);
    summary : String(1000);
    customerID : Association to Customer;
}

entity CustomerNote {
    key noteID : UUID;
    content : String(1000);
    authorID : String(100);
    date : Date;
    customerID : Association to Customer;
}

entity MarketingCampaign {
    key campaignID : UUID;
    name : String(200);
    startDate : Date;
    endDate : Date;
    description : String(1000);
    customers : Association to many CustomerCampaigns on customers.campaign = $self;
}

entity CustomerCampaigns {
    key customer : Association to Customer;
    key campaign : Association to MarketingCampaign;
}