An end to end E commerce data platform project simulating a pipeline from raw transactional data to analytical warehouse, real time streaming, SQL transformations, and data quality monitoring.

-------------------------------------------------------------------------------------------------------------------------------

## Prerequisites

- Docker Desktop installed and running
- Python 3.11+
- Git

-------------------------------------------------------------------------------------------------------------------------------

## Architecture

┌─────────────────────────────────────────────────────────────────┐
│                        Data Sources                             │
│   OLTP PostgreSQL (orders, users, products, clickstream)        │
└────────────────────────┬────────────────────────────────────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
   Batch (Airflow)              Streaming (Kafka)
   runs daily                   real time events
          │                             │
          └──────────────┬──────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                   Warehouse Schema                              │
│   fact_orders + dim_users, dim_products, dim_date, dim_location │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                   dbt Transformation Layer                      │
│   staging → intermediate → marts (revenue, funnel, products)    │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                   Data Quality & Monitoring                     │
│   Great Expectations checks + Pipeline health monitoring        │
└─────────────────────────────────────────────────────────────────┘


-------------------------------------------------------------------------------------------------------------------------------

## Tech Stack

 Layer	                      Tool	                                  Version
---------------          ----------------------                     -------------
Source DB	                PostgreSQL	                                15
Orchestration	            Apache Airflow	                            2.8.1
Streaming	                Apache Kafka	                            7.5.0
Transformation	            dbt Core	                                1.7.0
Data Quality	            Great Expectations	                        latest
Language	                Python	                                    3.14
Containers	                Docker Compose	


-------------------------------------------------------------------------------------------------------------------------------

## Phases
------------

Phase 1 - Foumdation and Modeling

- Designed normalized OLTP schema (6 tables)
- Designed star schema warehouse (fact_orders + 4 dimensions)
- Generated 140,000+ rows of synthetic data using Python Faker
- PostgreSQL running in Docker with automatic schema init

What it does: Defines two PostgreSQL schemas 
    - One for the app (OLTP - Online Transaction Processing).
    - One for analytics (OLAP - Online Analytical Processing/warehouse).

