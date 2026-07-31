using CRMService as service from '../../srv/crm-service';

// ============================================================
// CUSTOMERS
// ============================================================
annotate service.Customers with {
    customerID    @UI.Hidden;
    firstName     @title: 'First Name';
    lastName      @title: 'Last Name';
    email         @title: 'Email';
    phone         @title: 'Phone';
    averageRating @title: 'Avg. Rating';
    statusCode_code    @Common.Label: 'Status';
    categoryGroup_code @Common.Label: 'Category Group';
};

annotate service.Customers with @(
    UI.HeaderInfo: {
        TypeName      : 'Customer',
        TypeNamePlural: 'Customers',
        Title: { $Type: 'UI.DataField', Value: firstName },
        Description: { $Type: 'UI.DataField', Value: lastName }
    },

    UI.SelectionFields: [ statusCode_code, categoryGroup_code ],

    UI.LineItem: [
        { $Type: 'UI.DataField', Value: firstName, Label: 'First Name' },
        { $Type: 'UI.DataField', Value: lastName,  Label: 'Last Name' },
        { $Type: 'UI.DataField', Value: email,     Label: 'Email' },
        { $Type: 'UI.DataField', Value: phone,     Label: 'Phone' },
        { $Type: 'UI.DataField', Value: averageRating, Label: 'Avg. Rating' },
        {
            $Type : 'UI.DataField',
            Value : statusCode.description,
            Label : 'Status',
            Criticality: statusCode.criticality,
            CriticalityRepresentation: #WithIcon
        },
        { $Type: 'UI.DataField', Value: categoryGroup.description, Label: 'Category Group' }
    ],

    UI.HeaderFacets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Status', Target: '@UI.FieldGroup#StatusHeader' }
    ],

    UI.FieldGroup#StatusHeader: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: statusCode.description,
                Criticality: statusCode.criticality,
                CriticalityRepresentation: #WithIcon
            },
            { $Type: 'UI.DataField', Value: averageRating },
            { $Type: 'UI.DataField', Value: categoryGroup.description }
        ]
    },

    UI.Facets: [
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'OverviewTab',
            Label : 'Overview',
            Facets: [
                { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfoFacet', Label: 'Customer Details', Target: '@UI.FieldGroup#GeneralInfo' },
                { $Type: 'UI.ReferenceFacet', ID: 'PreferencesFacet', Label: 'Preferences (auto-detected)', Target: 'preferences/@UI.LineItem' }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'HistoryTab',
            Label : 'History',
            Facets: [
                { $Type: 'UI.ReferenceFacet', ID: 'RecentActivityFacet', Label: 'Recent Activity',    Target: 'interactions/@UI.PresentationVariant#RecentActivity' },
                { $Type: 'UI.ReferenceFacet', ID: 'InteractionFacet',    Label: 'Interaction History', Target: 'interactions/@UI.LineItem' },
                { $Type: 'UI.ReferenceFacet', ID: 'FeedbackFacet',       Label: 'Feedback History',    Target: 'feedbacks/@UI.LineItem' }
            ]
        },
        { $Type: 'UI.ReferenceFacet', ID: 'NotesFacet', Label: 'Notes', Target: 'notes/@UI.LineItem' }
    ],

    UI.FieldGroup#GeneralInfo: {
        Data: [
            { $Type: 'UI.DataField', Value: firstName },
            { $Type: 'UI.DataField', Value: lastName },
            { $Type: 'UI.DataField', Value: email },
            { $Type: 'UI.DataField', Value: phone }
        ]
    },

    // Backend пересчитал -> просим UI перечитать эти поля/навигации
    Common.SideEffects #OnFeedbackChange: {
        SourceEntities  : [ feedbacks ],
        TargetProperties: [ 'averageRating', 'statusCode_code' ],
        TargetEntities  : [ interactions ]
    },
    Common.SideEffects #OnInteractionChange: {
        SourceEntities  : [ interactions ],
        TargetProperties: [ 'categoryGroup_code', 'statusCode_code' ],
        TargetEntities  : [ preferences ]
    }
);

// ---------- Value Help: показывать сразу весь список ----------
annotate service.Customers with {
    statusCode_code @Common.ValueListWithFixedValues: true;
    categoryGroup_code @Common.ValueListWithFixedValues: true;
};

annotate service.CustomerStatusCodes with {
    code @Common.Label: 'Status Code';
    description @Common.Label: 'Description';
    code @Common.Text: description;
    code @Common.Text.@UI.TextArrangement: #TextOnly;
};

annotate service.ProductCategoryGroups with {
    code @Common.Label: 'Group Code';
    description @Common.Label: 'Description';
    code @Common.Text: description;
    code @Common.Text.@UI.TextArrangement: #TextOnly;
};

annotate service.ProductCategories with {
    code @Common.Label: 'Category Code';
    description @Common.Label: 'Description';
    code @Common.Text: description;
    code @Common.Text.@UI.TextArrangement: #TextOnly;
};

// ============================================================
// PREFERENCES — только просмотр, формируется системой
// ============================================================
annotate service.Preferences with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: productCategory.description, Label: 'Product Category' },
        { $Type: 'UI.DataField', Value: notes, Label: 'Notes' }
    ],
    UI.CreateHidden: true,
    UI.UpdateHidden: true,
    UI.DeleteHidden: true
);

// ============================================================
// FEEDBACKS
// ============================================================
annotate service.Feedbacks with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: feedbackDate, Label: 'Date' },
        { $Type: 'UI.DataField', Value: rating, Label: 'Rating' },
        { $Type: 'UI.DataField', Value: comments, Label: 'Comments' }
    ]
);

annotate service.Feedbacks with {
    customerID @UI.Hidden;
};

// ============================================================
// INTERACTIONS — полная история (создаваемая) + Recent Activity (read-only)
// ============================================================
annotate service.Interactions with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: method,  Label: 'Type' },
        { $Type: 'UI.DataField', Value: date,    Label: 'Date' },
        { $Type: 'UI.DataField', Value: summary, Label: 'Description' },
        { $Type: 'UI.DataField', Value: productCategory.description, Label: 'Category' }
    ],
    UI.SelectionFields: [ method ],

    UI.LineItem#RecentActivity: [
        { $Type: 'UI.DataField', Value: method,  Label: 'Type' },
        { $Type: 'UI.DataField', Value: date,    Label: 'Date' },
        { $Type: 'UI.DataField', Value: summary, Label: 'Description' }
    ],

    UI.PresentationVariant#RecentActivity: {
        Text: 'Recent Activity',
        SortOrder: [ { Property: date, Descending: true } ],
        Visualizations: [ '@UI.LineItem#RecentActivity' ],
        MaxItems: 5
    },

    // Recent Activity — строго только просмотр
    UI.CreateHidden #RecentActivity: true,
    UI.UpdateHidden #RecentActivity: true,
    UI.DeleteHidden #RecentActivity: true
);

annotate service.Interactions with {
    customerID @UI.Hidden;
    productCategory_code @(
        Common.Label: 'Product Category',
        Common.Text: productCategory.description,
        Common.Text.@UI.TextArrangement: #TextOnly,
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'ProductCategories',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: productCategory_code, ValueListProperty: 'code' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
            ]
        }
    )
};

// ============================================================
// CUSTOMER NOTES — Author проставляется автоматически
// ============================================================
annotate service.CustomerNotes with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: date, Label: 'Date' },
        { $Type: 'UI.DataField', Value: authorID, Label: 'Author' },
        { $Type: 'UI.DataField', Value: content, Label: 'Note' }
    ]
);

annotate service.CustomerNotes with {
    customerID @UI.Hidden;
    authorID   @Core.Computed: true;
};