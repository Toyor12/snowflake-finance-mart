# Snowflake Finance Data Mart for Power BI Reporting

A dimensional data warehouse project that transforms raw e-commerce data into finance-ready data marts, built on the same architecture pattern used by modern cloud analytics platforms: **Azure Blob Storage → Snowflake → dbt → Power BI**.

## Architecture

```
Azure Blob Storage (raw CSVs)
        │  external stage + COPY INTO
        ▼
Snowflake RAW schema
        │  dbt
        ▼
staging (views, cleaned + typed)
        │
intermediate (business logic, payment reconciliation)
        │
marts (Kimball star schema, tables)
        │  DirectQuery / Import
        ▼
Power BI (semantic model + report)
```

## Data model (star schema)

| Model | Grain | Purpose |
|---|---|---|
| `dim_customer` | one row per customer | customer attributes for slicing |
| `dim_product` | one row per product | product category dimension |
| `dim_date` | one row per day | generated date spine for time intelligence |
| `fct_sales` | one row per order item | sales line detail: price, freight, gross value |
| `fct_revenue` | one row per order | finance view with payment reconciliation and mismatch flag |

## Data quality

Tests run on every `dbt build`:

- `not_null` and `unique` on all primary keys
- `relationships` (referential integrity) from facts to dimensions
- `accepted_values` on order status
- unique combination test on the fact grain (`order_id`, `order_item_id`)
- payment variance check: `fct_revenue.has_payment_mismatch` flags orders where payments do not reconcile with item values

## Business KPIs surfaced in Power BI

- Gross revenue and freight revenue by month, category and state
- Average order value and items per order
- Payment mix (credit card, boleto, voucher) and installment behaviour
- Revenue reconciliation: payment variance monitoring for finance
- Delivered vs. canceled revenue impact

## Setup

1. Create a Snowflake trial account and run `snowflake_setup.sql` (replace the Azure storage account and SAS token placeholders).
2. Upload the [Olist e-commerce CSVs](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) to an Azure Blob container named `olist-raw`.
3. Copy `profiles.yml.example` to `~/.dbt/profiles.yml` and set the environment variables.
4. `dbt deps && dbt build`
5. Connect Power BI to the `marts` schema and build the report on the star schema.

## Stack

Snowflake · dbt · SQL · Azure Blob Storage · Power BI · GitHub Actions (sqlfluff lint)
