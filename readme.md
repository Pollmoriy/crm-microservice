# CRM Microservice

A Customer Relationship Management (CRM) microservice developed using the SAP Cloud Application Programming Model (CAP) and deployed on SAP Business Technology Platform (SAP BTP).

The application is designed to complement a Sales Order application by providing detailed customer information, preferences, feedback, interaction history, and customer classification.

---

## 📌 Project Overview

The CRM application provides a centralized workspace for managing customer information and customer interactions.

The main functionality includes:

- Customer management
- Customer preferences
- Customer feedback and ratings
- Interaction history
- Customer status classification
- Customer category grouping
- Recent customer activity
- Internal customer notes
- Role-based access control
- Draft-enabled editing
- Value helps
- Custom filters
- Color-coded customer statuses

The project demonstrates how a real-world CRM application can be implemented using SAP CAP, SAP Fiori Elements, SAP HANA Cloud, XSUAA, and SAP BTP.

---

## 🛠 Technology Stack

| Layer | Technology |
|---|---|
| Backend | Node.js |
| Backend Framework | SAP Cloud Application Programming Model (CAP) |
| Data Model | CDS |
| Frontend | SAP Fiori Elements / SAPUI5 |
| API | OData V4 |
| Database | SAP HANA Cloud |
| Authentication & Authorization | SAP XSUAA |
| Cloud Platform | SAP BTP |
| Development Environment | SAP Business Application Studio |
| Runtime | Cloud Foundry |
| Application Router | SAP Approuter |
| Version Control | Git / GitHub |
| Build | Cloud MTA Build Tool |

---

## 🏗 Architecture

```text
                    ┌─────────────────────┐
                    │     SAP Fiori       │
                    │    Elements UI      │
                    └──────────┬──────────┘
                               │
                               │ OData V4
                               ▼
                    ┌─────────────────────┐
                    │     CAP Service     │
                    │     CRMService      │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
       ┌────────────┐   ┌────────────┐   ┌────────────┐
       │  Business  │   │   XSUAA    │   │   CAP      │
       │   Logic    │   │   Security │   │  Handlers  │
       └────────────┘   └────────────┘   └────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   SAP HANA Cloud    │
                    └─────────────────────┘
```


# 📊 Data Model

The CRM domain consists of several related entities.

## Customer

Stores the main information about a customer.

Fields:

- `customerID`
- `firstName`
- `lastName`
- `email`
- `phone`
- `statusCode`
- `averageRating`
- `categoryGroup`

## Preference

Stores customer product preferences.

Fields:

- `preferenceID`
- `productCategory`
- `notes`
- `customerID`

Relationship:

```text
Customer
   │
   └── Aggregation → Preference
```

## Feedback

Stores customer feedback and ratings.

Fields:

- `feedbackID`
- `customerID`
- `rating`
- `comments`
- `feedbackDate`
- `preferenceID`
- `statusCode`

Relationship:

```text
Customer
   │
   └── Aggregation → Feedback
```

## Interaction

Stores the history of customer interactions.

Fields:

- `interactionID`
- `customerID`
- `date`
- `method`
- `summary`
- `productCategory`
- `sourceFeedback`

Relationship:

```text
Customer
   │
   └── Composition → Interaction
```

## CustomerStatusCode

Reference entity containing customer statuses.

Examples:

- Active
- Inactive
- At Risk

The status is displayed in the UI using color-coded criticality indicators.

## Additional Entities

### CustomerNote

Stores internal customer notes.

Fields:

- `noteID`
- `content`
- `authorID`
- `date`
- `customerID`

Relationship:

```text
Customer
   │
   └── Composition → CustomerNote
```
### ProductCategoryGroup

Groups product categories into broader customer segments.

Examples:

- Tech Enthusiast
- Accessories Buyer

### ProductCategory

Reference entity containing available product categories.

### InteractionMethod

Reference entity containing available interaction methods.

---

# 🔐 User Roles & Authorization

The application contains three main roles:

1. **CRM Admin**
2. **Sales Manager**
3. **Support Agent**

Authorization is implemented using **SAP XSUAA** and CAP `@restrict` annotations.

The application follows the principle of least privilege: each role receives only the permissions required for its responsibilities.

---

## 👑 CRM Admin

The CRM Admin has full access to the CRM system.

### Main responsibilities

The CRM Admin is responsible for managing the complete CRM system and has access to all customer management operations.

### Permissions

- Read customers
- Create customers
- Update customers
- Delete customers
- Read and create interactions
- Read and create feedback
- Access CRM reference data
- Perform administrative operations

### Customer actions

| Action | CRM Admin |
|---|:---:|
| Read Customer | ✅ |
| Create Customer | ✅ |
| Edit Customer | ✅ |
| Delete Customer | ✅ |

---

## 💼 Sales Manager

The Sales Manager works with customer information required for sales activities.

### Main responsibilities

The Sales Manager can maintain existing customer information and record customer-related activities, but does not have administrative or destructive permissions.

### Permissions

- Read customers
- Update customers
- Read interactions
- Create interactions
- Read feedback
- Create feedback

### Customer actions

| Action | Sales Manager |
|---|:---:|
| Read Customer | ✅ |
| Create Customer | ❌ |
| Edit Customer | ✅ |
| Delete Customer | ❌ |

The Sales Manager can therefore maintain customer information but cannot create or delete customer records.

---

## 🎧 Support Agent

The Support Agent has limited access focused on customer support.

### Main responsibilities

The Support Agent can view customer information and record support-related interactions.

The Support Agent cannot modify customer master data.

### Permissions

- Read customers
- Read feedback
- Read interactions
- Create interactions

### Customer actions

| Action | Support Agent |
|---|:---:|
| Read Customer | ✅ |
| Create Customer | ❌ |
| Edit Customer | ❌ |
| Delete Customer | ❌ |
| Create Interaction | ✅ |

For example:

```text
Customer contacts support
        ↓
Support Agent opens customer
        ↓
Support Agent creates Interaction
        ↓
Interaction is added to history
```

---

## 🔒 Authorization Matrix

| Operation | CRM Admin | Sales Manager | Support Agent |
|---|:---:|:---:|:---:|
| Read Customer | ✅ | ✅ | ✅ |
| Create Customer | ✅ | ❌ | ❌ |
| Update Customer | ✅ | ✅ | ❌ |
| Delete Customer | ✅ | ❌ | ❌ |
| Read Interactions | ✅ | ✅ | ✅ |
| Create Interaction | ✅ | ✅ | ✅ |
| Read Feedback | ✅ | ✅ | ✅ |
| Create Feedback | ✅ | ✅ | ❌ |
| Administrative access | ✅ | ❌ | ❌ |

The frontend hides actions that are not available to the current role.

At the same time, the backend independently validates every request using CAP authorization.

Therefore, hiding a button in the UI is not the security mechanism. The backend authorization is the actual security layer.

---

# 🖥 User Interface

The frontend uses **SAP Fiori Elements** and OData V4.

The main application contains:

- Customer List Report
- Customer Object Page
- Customer details
- Preferences
- Feedback history
- Interaction history
- Quick Insights
- Customer notes

---

# 👤 Customer Object Page

Every customer has a dedicated Object Page containing the relevant customer information.

The Object Page is divided into three main tabs.

## 1. Overview

Contains:

- Customer details
- Customer status
- Average rating
- Product category group
- Customer preferences
- Recent interactions

## 2. History

Contains:

- Interaction History
- Feedback History

## 3. Notes

Contains:

- Internal customer notes
- Author
- Date
- Note content

---

# 📋 Interaction History

The Interaction History table contains:

| Field | Description |
|---|---|
| Type | Interaction method |
| Date | Interaction date |
| Description | Interaction summary |
| Category | Related product category |

This allows employees to quickly understand the customer's previous activity.

---

# ⚡ Quick Insights

The Customer Object Page displays recent customer interactions.

The interactions are sorted by date, with the newest activity displayed first.

This gives employees immediate context when opening a customer profile.

---

# ⭐ Customer Rating

The application calculates the average customer rating from customer feedback.

Example:

```text
Feedback:
5
4
3

Average Rating:
4.0
```

The calculated average rating is displayed on the Customer Object Page.

---

# 🟢 Customer Classification

Customers can be automatically classified based on their activity and feedback.

Possible statuses include:

### Active

The customer has recent activity.

### Inactive

The customer has not had relevant activity for an extended period.

### At Risk

The customer has received low feedback ratings.

Example:

```text
Feedback rating < 3
        ↓
Customer status
      At Risk
```

Customer statuses are displayed using color-coded criticality indicators.

---

# 🎯 Customer Preferences

Customer preferences can be determined based on interaction history.

For example:

```text
Customer interactions:

Smartphone
Smartphone
Laptop
Smartphone

        ↓

Preference:
Smartphones
```

The detected preferences are displayed on the Customer Object Page.

---

# 🏷 Customer Category Groups

Customers can be grouped based on their product interests.

Example:

```text
Smartphones
Laptops
Tablets

      ↓

Tech Enthusiast
```

Another example:

```text
Phone Cases
Headphones
Chargers

      ↓

Accessories Buyer
```

The category group is displayed on the customer profile and can be used for filtering.

---

# 🔎 Filters

Customers can be filtered by:

- Customer status
- Product category group
- Average rating

Interactions can be filtered by interaction method.

Examples:

```text
Status = Active
```

```text
Category Group = Tech Enthusiast
```

```text
Average Rating > 4
```

---

# ⬇️ Value Helps

The application provides value helps for reference data.

Value helps are available for:

- Customer status
- Product category groups
- Product categories
- Interaction methods

Users can select readable values instead of entering technical codes manually.

---

# 📝 Draft-Enabled Editing

The CRM service is configured with:

```cds
@odata.draft.enabled
```

This enables draft functionality for editing customer information through SAP Fiori Elements.

---

# ⚙️ Business Logic

Business logic is implemented on the CAP service layer.

The project contains server-side handlers for:

- Customer lifecycle processing
- Customer status calculation
- Customer rating processing
- Customer preference detection
- Customer category grouping
- Customer note handling
- Interaction processing
- Recent interaction retrieval

The business logic is implemented on the backend rather than relying exclusively on frontend calculations.

---

# 🔗 OData Service

The main service is:

```text
CRMService
```

with the service path:

```text
/crm/
```

The service exposes:

```text
Customers
Preferences
Feedbacks
Interactions
RecentInteractions
CustomerNotes
CustomerStatusCodes
ProductCategoryGroups
ProductCategories
InteractionMethods
```

---

# ☁️ SAP BTP Architecture

The application is deployed to SAP Business Technology Platform.

The main cloud components are:

```text
SAP BTP
│
├── Cloud Foundry
│
├── Application Router
│
├── HTML5 Application Repository
│
├── XSUAA
│
└── SAP HANA Cloud
```

---

# 🔑 Authentication

Authentication and authorization are provided through SAP XSUAA.

After authentication, the user's assigned Role Collection determines which permissions are available in the CRM application.

The three application roles are:

```text
CRMAdmin
SalesManager
SupportAgent
```

These roles are assigned through corresponding BTP Role Collections.

---

# 💾 Database

The production database is **SAP HANA Cloud**.

The database model is defined using CDS in:

```text
db/schema.cds
```

The service model is defined in:

```text
srv/crm-service.cds
```

---

# 🚀 Running the Project on Another Computer

The project can be run by another developer or mentor after cloning the GitHub repository.

## 1. Prerequisites

Install:

- Node.js
- npm
- Git
- SAP CDS CLI
- Cloud Foundry CLI
- Cloud MTA Build Tool

For SAP BTP development, **SAP Business Application Studio** is recommended.

---

## 2. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd crm-microservice
```

---

## 3. Install Dependencies

From the project root:

```bash
npm install
```

The UI application has its own `package.json`, so install its dependencies as well:

```bash
cd app/crm-ui
npm install
cd ../..
```

---

## 4. Build the Project

Run:

```bash
cds build
```

A successful build should finish with:

```text
build completed
```

---

## 5. Run Locally

Start the CAP development server:

```bash
cds watch
```

The application will normally be available at:

```text
http://localhost:4004
```

The CRM OData service is available at:

```text
http://localhost:4004/odata/v4/crm/
```

> **Note:** Local execution is intended primarily for development. Full XSUAA authentication, BTP Role Collections, and the production SAP HANA Cloud environment require the corresponding SAP BTP configuration.

---

# ☁️ Deploying the Project to SAP BTP

If the mentor has access to the corresponding SAP BTP subaccount and the required services, the application can be deployed using the MTA deployment process.

## 1. Login to Cloud Foundry

```bash
cf login
```

Select the appropriate:

- API endpoint
- Organization
- Space

---

## 2. Build the MTA Archive

From the project root:

```bash
mbt build
```

This creates an `.mtar` archive in:

```text
mta_archives/
```

---

## 3. Deploy

Deploy the generated archive:

```bash
cf deploy mta_archives/<generated-file>.mtar
```

The deployment creates the application modules and required services defined in `mta.yaml`.

---

# 📋 Functional Requirements

The project implements the following requirements:

- [x] Customer management
- [x] Minimum three related entities
- [x] Compositions
- [x] Aggregations
- [x] Dedicated Customer Object Page
- [x] Customer details
- [x] Preferences
- [x] Feedback history
- [x] Interaction history
- [x] Quick Insights
- [x] Interaction History table
- [x] Value Helps
- [x] Draft-enabled editing
- [x] Authorization on launch
- [x] Three user roles
- [x] Backend authorization
- [x] Role-aware UI
- [x] Color-coded customer status
- [x] Custom filters
- [x] Customer rating calculation
- [x] Customer classification
- [x] Customer preference detection
- [x] Customer category grouping
- [x] Customer notes
- [x] Recent customer activity
- [x] OData V4 service
- [x] SAP HANA Cloud database
- [x] SAP XSUAA authentication
- [x] SAP BTP deployment

---

# 🗺 Possible Future Improvements

Potential extensions include:

- Marketing Campaign management
- Customer Tags
- Loyalty Programs
- Sales Order integration
- Advanced customer analytics
- Automated notifications
- Customer dashboards
- Advanced reporting
- Automated unit tests
- Integration tests
- Additional authorization roles

---

# 📚 References

- [SAP Cloud Application Programming Model](https://cap.cloud.sap/docs/)
- [SAP Fiori Elements](https://ui5.sap.com/)
- [SAPUI5](https://ui5.sap.com/)
- [SAP Business Technology Platform](https://www.sap.com/products/technology-platform.html)
- [SAP HANA Cloud](https://www.sap.com/products/technology-platform/cloud-database.html)
- [SAP XSUAA](https://help.sap.com/docs/btp/sap-business-technology-platform/authorization-and-trust-management-service)
- [SAP Business Application Studio](https://www.sap.com/products/technology-platform/business-application-studio.html)
