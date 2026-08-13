using CRMService as service from '../../srv/crm-service';

annotate service.Customers with {
    customerID    @UI.Hidden;
    firstName     @title: 'First Name';
    lastName      @title: 'Last Name';
    email         @title: 'Email';
    phone         @title: 'Phone';
    averageRating @title: 'Avg. Rating';
};

annotate service.Customers with @(
    UI.HeaderInfo: {
        TypeName      : 'Customer',
        TypeNamePlural: 'Customers',
        Title: { $Type: 'UI.DataField', Value: firstName },
        Description: { $Type: 'UI.DataField', Value: lastName }
    },

    UI.SelectionFields: [ statusCode_code, categoryGroup_code, averageRating ],

        UI.CreateHidden: {
        $edmJson: {
            $Not: {
                $Path: '/Configuration/isAdmin'
            }
        }
    },

    UI.UpdateHidden: {
        $edmJson: {
            $Not: {
                $Or: [
                    { $Path: '/Configuration/isAdmin' },
                    { $Path: '/Configuration/isSalesManager' }
                ]
            }
        }
    },

    UI.DeleteHidden: {
        $edmJson: {
            $Not: {
                $Path: '/Configuration/isAdmin'
            }
        }
    },

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
                { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfoFacet',  Label: 'Customer Details', Target: '@UI.FieldGroup#GeneralInfo' },
                { $Type: 'UI.ReferenceFacet', ID: 'PreferencesFacet',  Label: 'Preferences (auto-detected)', Target: 'preferences/@UI.LineItem' },
                { $Type: 'UI.ReferenceFacet', ID: 'QuickInsightsFacet', Label: 'Quick Insights', Target: 'recentInteractions/@UI.PresentationVariant' }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'HistoryTab',
            Label : 'History',
            Facets: [
                { $Type: 'UI.ReferenceFacet', ID: 'InteractionFacet', Label: 'Interaction History', Target: 'interactions/@UI.LineItem' },
                { $Type: 'UI.ReferenceFacet', ID: 'FeedbackFacet',    Label: 'Feedback History',    Target: 'feedbacks/@UI.LineItem' }
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

    Common.SideEffects #OnFeedbackSave: {
        SourceEntities  : [ feedbacks ],
        TargetProperties: [ 'averageRating', 'statusCode_code' ],
        TargetEntities  : [ interactions, recentInteractions ]
    },
    Common.SideEffects #OnInteractionSave: {
        SourceEntities  : [ interactions ],
        TargetProperties: [ 'categoryGroup_code', 'statusCode_code' ],
        TargetEntities  : [ preferences, recentInteractions ]
    }
);

annotate service.Customers with {
    statusCode @(
        Common.Label: 'Status',
        Common.Text: statusCode.description,
        Common.Text.@UI.TextArrangement: #TextOnly,
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'CustomerStatusCodes',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: statusCode_code, ValueListProperty: 'code' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
            ]
        }
    )
};

annotate service.Customers with {
    categoryGroup @(
        Common.Label: 'Category Group',
        Common.Text: categoryGroup.description,
        Common.Text.@UI.TextArrangement: #TextOnly,
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'ProductCategoryGroups',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: categoryGroup_code, ValueListProperty: 'code' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
            ]
        }
    )
};

annotate service.CustomerStatusCodes with {
    code        @Common.Label: 'Status Code';
    description @Common.Label: 'Description';
};

annotate service.ProductCategoryGroups with {
    code        @Common.Label: 'Group Code';
    description @Common.Label: 'Description';
};

annotate service.ProductCategories with {
    code        @Common.Label: 'Category Code';
    description @Common.Label: 'Description';
};

annotate service.InteractionMethods with {
    code        @Common.Label: 'Method Code';
    description @Common.Label: 'Description';
};


annotate service.Preferences with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: productCategory.description, Label: 'Product Category' },
        { $Type: 'UI.DataField', Value: notes, Label: 'Notes' }
    ],
    UI.CreateHidden: true,
    UI.UpdateHidden: true,
    UI.DeleteHidden: true
);


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


annotate service.Interactions with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: method_code,          Label: 'Type' },
        { $Type: 'UI.DataField', Value: date,                 Label: 'Date' },
        { $Type: 'UI.DataField', Value: summary,               Label: 'Description' },
        { $Type: 'UI.DataField', Value: productCategory_code, Label: 'Category' }
    ],
    UI.SelectionFields: [ method_code ]
);

annotate service.Interactions with {
    customerID     @UI.Hidden;
    sourceFeedback @UI.Hidden;

    method @(
        Common.Label: 'Type',
        Common.Text: method.description,
        Common.Text.@UI.TextArrangement: #TextOnly,
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'InteractionMethods',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: method_code, ValueListProperty: 'code' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
            ]
        }
    );

    productCategory @(
        Common.Label: 'Category',
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


annotate service.RecentInteractions with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: method.description, Label: 'Type' },
        { $Type: 'UI.DataField', Value: date, Label: 'Date' },
        { $Type: 'UI.DataField', Value: summary, Label: 'Description' }
    ],
    UI.PresentationVariant: {
        Text: 'Quick Insights',
        SortOrder: [ { Property: date, Descending: true } ],
        Visualizations: [ '@UI.LineItem' ],
        MaxItems: 10
    }
);


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