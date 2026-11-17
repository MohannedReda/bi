# Olist Delivery Performance Analysis

**Team Track:** Delivery Performance – Team F  
**Database:** Olist_Delivery_Performance  
**Dataset:** Brazilian E-Commerce Public Dataset by Olist  
**Tools:** SQL Server, SSMS, Microsoft Excel

---

## 1. Project Overview

This project analyzes delivery performance in the Brazilian e-commerce market using the Olist dataset.

The main goal is to evaluate delivery efficiency, identify geographical areas with delivery problems, compare seller performance, and understand the factors associated with delivery delays.

The project uses SQL Server for data preparation and analysis, and Microsoft Excel to present key performance indicators and analytical findings through an interactive dashboard.

## 2. Business Use Case

Delivery performance directly affects customer satisfaction and the overall e-commerce experience.

Late deliveries may indicate operational problems related to geographical coverage, seller performance, or transportation processes.

This project aims to provide data-driven insights that help identify delivery issues and support better operational decisions.

### Key Business Objectives

- Measure overall delivery performance.
- Identify states with higher delivery delay rates.
- Monitor monthly delivery performance trends.
- Evaluate seller delivery performance.
- Compare within-state and cross-state deliveries.
- Analyze the relationship between order size and delivery performance.
- Understand how delivery delays relate to customer ratings.

## 3. Project Track and Research Questions

**Selected Track:** Team F – Delivery Performance

The project addresses 12 analytical questions.

### General Analysis

| ID | Research Question |
|---|---|
| G1 | How many orders were placed, and what is their status? |
| G2 | How do sales change from month to month? |
| G3 | Which delivered orders have missing review records? |

### Delivery Performance Analysis

| ID | Research Question |
|---|---|
| F1 | Where are delivery problems concentrated? |
| F2 | Is delivery performance improving over time? |
| F3 | Which orders took longer than similar orders? |
| F4 | Which sellers serve higher-delay states? |
| F5 | How do within-state and cross-state orders compare? |
| F6 | Which regional problems persist across periods? |
| F7 | How do ratings differ between on-time and late orders? |

### Additional Analysis

| ID | Research Question |
|---|---|
| O1.1 | How does order size affect average delivery time? |
| O1.2 | How does order size affect late delivery rate? |

## 4. Analysis Scope

### Dataset

The analysis uses the Brazilian E-Commerce Public Dataset by Olist.

The database contains seven tables:

- `olist_orders`
- `olist_customers`
- `olist_order_items`
- `olist_products`
- `olist_sellers`
- `olist_order_payments`
- `olist_order_reviews`

The geolocation table is excluded.

### Time Period

January 1, 2017 – August 31, 2018.

The analysis period is based on the order purchase timestamp.

### Key Metrics

| Metric | Definition |
|---|---|
| Total Orders | Total number of orders in the selected period |
| Delivered Orders | Number of orders with delivered status |
| Average Delivery Days | Average time between purchase and actual delivery |
| Late Delivery Rate | Percentage of delivered orders delivered after the estimated date |
| Monthly Sales | Sum of product item prices grouped by month |
| Review Score | Customer rating from 1 to 5 |

## 5. Tools and Technologies

| Tool | Purpose |
|---|---|
| Microsoft SQL Server | Database management and SQL analysis |
| SQL Server Management Studio (SSMS) | Query execution and data validation |
| Microsoft Excel | Dashboard creation and data visualization |
| GitHub | Project version control and documentation |

### Versions

| Software | Version |
|---|---|
| SQL Server | [Insert version] |
| SSMS | [Insert version] |
| Microsoft Excel | [Insert version] |

## 6. Repository Structure

```text
Olist_Delivery_Performance/
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_validation.sql
│   ├── 03_general_analysis.sql
│   ├── 04_delivery_analysis.sql
│   ├── 05_additional_analysis.sql
│   └── 06_excel_exports.sql
│
├── docs/
│   ├── ER_Diagram.png
│   ├── Data_Dictionary.xlsx
│   ├── SQL_Coverage_Map.xlsx
│   └── Setup_and_Refresh_Guide.md
│
├── results/
│   ├── G1_Order_Status.csv
│   ├── G2_Monthly_Sales.csv
│   ├── G3_Missing_Reviews.csv
│   └── ...
│
├── dashboard/
│   ├── Track_F_Delivery_Dashboard.xlsx
│   └── Dashboard_Preview.png
│
├── report/
│   └── Track_F_Findings.pdf
│
└── README.md
```

## 7. Setup Instructions

### Prerequisites

- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Microsoft Excel.
- Olist dataset downloaded from Kaggle.

### Database Setup

1. Download the Olist dataset.
2. Extract the CSV files.
3. Create the `Olist_Delivery_Performance` database.
4. Import the seven required CSV files into SQL Server.
5. Verify the imported tables and their column data types.
6. Review the database relationships.
7. Execute the validation scripts.

### Running the Analysis

Execute the SQL scripts in the following order:

| Order | Script | Purpose |
|---|---|---|
| 1 | `01_schema.sql` | Database and table schema reference |
| 2 | `02_validation.sql` | Data validation and quality checks |
| 3 | `03_general_analysis.sql` | General analysis questions G1–G3 |
| 4 | `04_delivery_analysis.sql` | Delivery analysis questions F1–F7 |
| 5 | `05_additional_analysis.sql` | Additional questions O1.1–O1.2 |
| 6 | `06_excel_exports.sql` | Prepare results for Excel |

**Note:** Update the script names and execution order if the final repository uses different filenames. The schema script must contain the actual schema definitions or clearly document the setup process.

## 8. Dashboard Preview

The Excel dashboard presents the main delivery performance KPIs and visualizations.

**Dashboard Screenshot:**

![Dashboard Preview](dashboard/Dashboard_Preview.png)

**Excel Workbook:** `dashboard/Track_F_Delivery_Dashboard.xlsx`

The dashboard is designed to highlight:

- Total Orders.
- Delivered Orders.
- Average Delivery Days.
- Late Delivery Rate.
- Monthly Delivery Performance.
- Delivery Performance by State.
- Seller Performance.
- Within-State vs Cross-State Delivery.

## 9. Headline Findings

This section summarizes the most important findings from the SQL analysis and Excel dashboard.

### Key Findings

**Finding 1 – Delivery Performance:**  
[Insert the main finding about overall delivery performance.]

**Finding 2 – Geographical Distribution:**  
[Insert the states or regions with the most significant delivery problems.]

**Finding 3 – Monthly Trends:**  
[Insert the main trend observed in monthly delivery performance.]

**Finding 4 – Seller Performance:**  
[Insert the main finding about seller-related delivery delays.]

**Finding 5 – Customer Experience:**  
[Insert the relationship observed between delivery delays and customer ratings.]

### Key Recommendations

1. [Insert the highest-priority operational recommendation.]
2. [Insert the second recommendation.]
3. [Insert the third recommendation.]

*All findings and recommendations should be supported by actual SQL results.*

## 10. Limitations

- The analysis is limited to the available Olist dataset and its historical period.
- The geolocation table is excluded.
- Delivery-time analysis focuses on delivered orders with valid delivery dates.
- The dataset does not provide complete real-time transportation tracking information.
- Some comparisons may be affected by differences in order size, seller distribution, and geographical coverage.
- The analysis identifies patterns and associations but does not establish causation.
- Seller-level and order-item-level analysis must account for differences in data granularity.

## 11. Source Attribution

### Dataset

Brazilian E-Commerce Public Dataset by Olist.

Source: Kaggle

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

### Technologies

- Microsoft SQL Server
- SQL Server Management Studio
- Microsoft Excel
- GitHub

SQL queries, transformations, dashboard calculations, and analytical findings should be reviewed and documented by the project team.

External tutorials, references, and tools used during development should be credited here.

## 12. Team Contributions

| Team Member | Contribution |
|---|---|
| [Member 1] | [Actual contribution] |
| [Member 2] | [Actual contribution] |
| [Member 3] | [Actual contribution] |
| [Member 4] | [Actual contribution] |

*Team contributions should accurately reflect the work performed by each member.*

---

**Project:** Olist Delivery Performance Analysis  
**Track:** Team F – Delivery Performance  
**Database:** Olist_Delivery_Performance
