# GoOutside Retail Analytics

## Project Overview

This project was completed as a retail analytics case study using Google BigQuery, Google Sheets, Connected Sheets, and Looker Studio.

The objective was to transform transactional retail sales data into stakeholder-focused reporting solutions covering:

- Retail partnership performance
- Financial performance
- Product and market analysis

The final solution combines SQL-based analytical views, Connected Sheets reporting, and an executive dashboard to support data-driven decision making.

---

## Business Objectives

### Retail Partnerships

- Understand market composition across countries
- Identify concentrated versus competitive markets
- Determine whether growth efforts should focus on retailer acquisition or increasing sales volume from existing retailers
- Analyze retailer performance across markets

### Finance

- Monitor revenue, profit, and margin performance
- Evaluate the effectiveness of sales channels
- Identify underperforming order methods
- Support profitability analysis

### Marketing

- Understand regional product preferences
- Identify top-performing product categories and brands
- Support targeted marketing and assortment strategies

---

## Key Findings

### Market Structure

- 562 retailers operating across 21 countries
- Most markets are highly concentrated, with the top three retailers controlling the majority of sales
- The United States was the only clearly competitive market

### Product Preferences

Top revenue-generating product categories globally:

1. Eyewear
2. Woods
3. Watches

Country-level analysis revealed substantial variation in product preferences, highlighting opportunities for localized marketing and assortment strategies.

### Financial Performance

- Revenue and profit increased consistently between 2015 and 2017
- The 2018 reporting period contains only partial-year data
- Profitability varied considerably across product categories and sales channels

### Sales Channels

Most active channels:

1. Web
2. Telephone
3. Email

Potential phase-out candidates:

- Fax
- Mail
- Special

due to relatively low transaction volumes and revenue contribution.

---

## Dashboard Deliverables

### Executive Dashboard

**File:** `GoOutside_Strategic_KPIs_dashboard.pdf`

The dashboard contains three stakeholder-focused reporting pages:

#### Finance

Key metrics:

- Revenue
- Profit
- Profit Margin
- Revenue by Channel
- Revenue by Product Line
- Monthly Performance Trends

#### Marketing

Key metrics:

- Revenue by Product Category
- Revenue by Brand
- Product Preferences by Country
- Product Mix Analysis

#### Retail Partnerships

Key metrics:

- Market Share by Retailer
- Market Concentration
- Retailer Rankings
- Retailer Counts by Market
- Growth Targets
- Revenue Trends

---

## Presentation

**File:** `GoOutside Data Strategy.pptx`

The presentation covers:

- Business requirements
- Data exploration
- Data modeling
- SQL view design
- Dashboard development
- Key findings
- Business recommendations

---

## Dataset

The project uses four relational datasets:

### daily_sales

Transactional sales data containing:

- Retailer code
- Product number
- Order method code
- Date
- Quantity
- Unit price
- Unit sale price

### retailers

Retailer information:

- Retailer code
- Retailer name
- Retailer type
- Country

### products

Product information:

- Product line
- Product type
- Product name
- Product brand
- Product color
- Unit cost
- Unit price

### methods

Sales channel information:

- Order method code
- Order method type

---

## Data Source

The original datasets can be downloaded here:

https://drive.google.com/drive/folders/12YM2eys4xaEFUawBCOC8d7jY31zOFplE?usp=sharing

---

## Data Model

The project follows a simple star-schema design:

```text
daily_sales
│
├── retailer_code ───── retailers
├── product_number ──── products
└── order_method_code ─ methods
```

Relationships:

- retailers → one-to-many
- products → one-to-many
- methods → one-to-many

The `daily_sales` table serves as the central fact table.

---

## Project Architecture

```text
CSV Files
    ↓
Google BigQuery
    ↓
Analytical SQL Views
    ↓
Connected Sheets
    ↓
Looker Studio Dashboard
```

---

## SQL Views

The repository contains a single SQL file:

**File:** `gooutside_views.sql`

The file contains all analytical views used throughout the project.

### Finance View

Provides:

- Revenue
- Cost
- Profit
- Profit Margin

Aggregated by:

- Month
- Product Line
- Sales Channel

### Partnerships View

Provides:

- Retailer Performance
- Country Information
- Revenue
- Units Sold
- Time Dimensions

Used for trend analysis and operational reporting.

### Partnerships Full View

Provides:

- Market Share
- Retailer Rankings
- Market Concentration
- Revenue Targets
- Retailer Growth Targets

Used for strategic market assessment.

### Marketing View

Provides:

- Product Performance
- Brand Performance
- Product Type Performance
- Country-Level Product Preferences

Used for marketing and product analysis.

---

## Technologies Used

- SQL
- Google BigQuery
- Google Sheets
- Connected Sheets
- Looker Studio

---

## Repository Contents

```text
gooutside-retail-analytics/
│
├── README.md
│
├── gooutside_views.sql
│
├── GoOutside_Strategic_KPIs_dashboard.pdf
│
└── GoOutside Data Strategy.pptx
```

---

## How to Reproduce the Project

### 1. Download the Dataset

Download the CSV files from:

https://drive.google.com/drive/folders/12YM2eys4xaEFUawBCOC8d7jY31zOFplE?usp=sharing

### 2. Create a BigQuery Dataset

Create a dataset in BigQuery.

Example:

```text
goutside
```

### 3. Import the Tables

Upload the four CSV files as:

```text
daily_sales
retailers
products
methods
```

### 4. Create Analytical Views

Open:

```text
gooutside_views.sql
```

Run the SQL statements in BigQuery.

This creates all analytical views required for reporting and dashboarding.

### 5. Connect to Google Sheets

Create Connected Sheets from the BigQuery views.

Suggested reporting sheets:

- Finance
- Marketing
- Retail Partnerships

Use pivot tables and filters for ad-hoc analysis.

### 6. Build Dashboard

Connect the BigQuery views directly to Looker Studio and recreate the dashboard pages using the provided presentation and dashboard examples.

---

## Future Improvements

Potential future enhancements include:

- Automated ETL pipelines
- Forecasting models
- Retailer segmentation
- Product recommendation analysis
- Incremental data processing
- Data quality monitoring
- Automated KPI alerts

---

## Disclaimer

This project was created as an educational and portfolio case study. The original dataset is provided separately and is not owned by the repository author.
