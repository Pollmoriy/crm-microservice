using { managed } from '@sap/cds/common';

namespace crm;

entity CustomerStatusCode {
    key code : String(20);
    @mandatory
    description : String(500);
    criticality : Integer default 1;
}

entity InteractionMethod {
    key code : String(20);
    @mandatory
    description : String(100);
}

entity Customer : managed {
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
    categoryGroup : Association to ProductCategoryGroup;
    statusCode : Association to CustomerStatusCode;
    interactions       : Composition of many Interaction on interactions.customerID = $self;
    recentInteractions : Association to many Interaction on recentInteractions.customerID = $self;
    preferences  : Composition of many Preference   on preferences.customerID  = $self;
    feedbacks    : Composition of many Feedback     on feedbacks.customerID    = $self;
    notes        : Composition of many CustomerNote on notes.customerID        = $self;
}

entity Preference {
    key preferenceID : UUID;
    @mandatory
    productCategory : Association to ProductCategory;
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
    method : Association to InteractionMethod;
    @mandatory
    summary : String(1000);
    @mandatory
    customerID : Association to Customer;
    productCategory : Association to ProductCategory;
    sourceFeedback  : Association to Feedback; // связь для авто-лога, чтобы не дублировать
}

entity CustomerNote {
    key noteID : UUID;
    @mandatory
    content : String(1000);
    authorID : String(100);
    @mandatory
    date : Date;
    @mandatory
    customerID : Association to Customer;
}

entity ProductCategoryGroup {
    key code : String(50);
    @mandatory
    description : String(200);
    categories : Association to many ProductCategory on categories.group = $self;
}

entity ProductCategory {
    key code : String(50);
    @mandatory
    description : String(200);
    group : Association to ProductCategoryGroup;
}