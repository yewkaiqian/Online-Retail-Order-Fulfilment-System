# Online Retail Order Fulfilment System

## Overview

The Online Retail Order Fulfilment System is a relational database project developed using Oracle SQL and PL/SQL. It is designed to manage the order fulfilment process of an online retail business, from customer order placement and inventory management to payment verification and shipment tracking.

The database consists of 13 interconnected tables and incorporates Entity-Relationship (ER) modelling, Enhanced Entity-Relationship (EER) modelling, relational database constraints, SQL queries, stored procedures and functions to support business operations and maintain data integrity.

## Key Features

- **Customer Management:** Maintain customer information, order history and spending records.
- **Product Management:** Manage product information, categories and pricing.
- **Inventory Management:** Monitor stock availability, restock products and generate low-stock reports.
- **Order Management:** Manage order items, order statuses and transaction records.
- **Payment Management:** Support credit/debit card, e-wallet and FPX payment records.
- **Shipment Management:** Support standard courier delivery and self-pickup, track shipment statuses and calculate estimated delivery dates.
- **Employee Management:** Assign employees to shipments and monitor their shipment workload.

## Technical Implementation

- Entity-Relationship Diagram (ERD)
- Enhanced Entity-Relationship Diagram (EERD)
- Supertype and subtype specialisation
- Relational database schema design
- Primary, foreign and composite keys
- Entity and referential integrity constraints
- SQL joins and aggregate functions
- PL/SQL stored procedures and functions
- Exception handling and transaction management

## Technologies Used

- Oracle Database
- SQL
- PL/SQL

## Repository Structure

| File | Description |
|---|---|
| `G010.sql` | Main database schema, constraints and sample records |
| `G010_LeongDiHao.sql` | Customer and order management operations |
| `G010_LiewJiaMin.sql` | Payment management operations |
| `G010_NguJingRong.sql` | Product and inventory management operations |
| `G010_YewKaiQian.sql` | Shipment and employee management operations |
| `Report.pdf` | Detailed project documentation, ERD, EERD, business rules and data dictionary |

## Contributors

| Contributor | Database Design and Implementation | Individual SQL/PLSQL Module |
|---|---|---|
| Leong Di Hao | Scope of work and data dictionary | Customer and order management |
| Liew Jia Min | Database tables, sample records and SQL schema | Payment management |
| Ngu Jing Rong | Database redesign and EER modelling | Product and inventory management |
| Yew Kai Qian | ER modelling and relationship design | Shipment and employee management |

Each member implemented two SQL queries, two PL/SQL stored procedures and two PL/SQL functions for their respective module.

## Getting Started

### Prerequisites

- Oracle Database
- Oracle SQL Developer or another compatible Oracle SQL client

### Execution

1. Clone or download this repository.
2. Establish a connection to an Oracle database.
3. Execute `G010.sql` to create the database tables and populate the sample records.
4. Execute the individual SQL scripts to create the corresponding stored procedures and functions.
5. Run the SQL queries and test the PL/SQL procedures and functions.

## Project Documentation

The project report provides detailed documentation of the database development process, including:

- Business requirements, rules and assumptions
- Entity-Relationship Diagram (ERD)
- Enhanced Entity-Relationship Diagram (EERD)
- Entity specialisation and generalisation
- Data dictionary
- Database tables and sample records
- SQL schema and integrity constraints
- Individual SQL and PL/SQL implementations

Refer to `Project_Report.pdf` for the complete technical documentation.

## Project Background

This project was developed collaboratively by four undergraduate students at Universiti Tunku Abdul Rahman (UTAR) as part of the Database Technology coursework.

- **Course:** UCCD2303 – Database Technology
- **Trimester:** June 2026
- **Project Type:** Academic Group Project
- **Group:** G010

This project is intended for educational purposes and demonstrates the practical application of relational database design, SQL and PL/SQL in an online retail business environment.
