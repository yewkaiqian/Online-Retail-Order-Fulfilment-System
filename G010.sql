/* ============================================================
   COURSE CODE: UCCD2303  
   GROUP NUMBER: G010
   GROUP LEADER NAME & EMAIL: Liew Jia Min jiamin0313@1utar.my
   MEMBER 2 NAME: Leong Di Hao
   MEMBER 3 NAME: Ngu Jing Rong
   MEMBER 4 NAME: Yew Kai Qian
   Submission date and time (DD-MON-YY): 28-08-2026
   ============================================================ */
   
SET SQLBLANKLINES ON;

/* ========================================================================================================================
   DROP TABLES (reverse dependency order, for re-running script)
   ============================================================ */
BEGIN EXECUTE IMMEDIATE 'DROP TABLE SELF_PICKUP CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE STANDARD_DELIVERY CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE BANKING_PAYMENT CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE EWALLET_PAYMENT CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CARD_PAYMENT CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE SHIPMENT CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE PAYMENT CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ORDER_ITEM CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ORDERS CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE INVENTORY CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEE CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE PRODUCTS CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CUSTOMER CASCADE CONSTRAINTS PURGE'; 
EXCEPTION WHEN OTHERS THEN NULL; 
END;
/

/* ============================================================
   1. CUSTOMER
   ============================================================ */
CREATE TABLE CUSTOMER(
    CUSTOMER_ID        NUMBER(6)     NOT NULL,
    Cus_First_Name     VARCHAR2(50)  NOT NULL,
    Cus_Last_Name      VARCHAR2(50)  NOT NULL,
    Email              VARCHAR2(100) NOT NULL,
    Cus_Phone_Number   VARCHAR2(15)  NOT NULL,
    CONSTRAINT CUSTOMER_PK PRIMARY KEY  (CUSTOMER_ID),
    CONSTRAINT CUSTOMER_EMAIL_UK   UNIQUE (Email),
    CONSTRAINT CUSTOMER_EMAIL_CK   CHECK  (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT CUSTOMER_PHONE_UK   UNIQUE (Cus_Phone_Number)
);

/* ============================================================
   2. PRODUCTS
   ============================================================ */
CREATE TABLE PRODUCTS(
    Product_ID          NUMBER(6)     NOT NULL,
    Product_Name        VARCHAR2(100) NOT NULL,
    Category            VARCHAR2(50)  NOT NULL,
    Current_Price       NUMBER(10,2)  NOT NULL,
    Product_Description VARCHAR2(255),
    CONSTRAINT PRODUCTS_PK PRIMARY KEY (Product_ID),
    CONSTRAINT PRODUCTS_PRICE_CK   CHECK (Current_Price >= 0)
);

/* ============================================================
   3. INVENTORY (1:1 with PRODUCTS - UNIQUE(Product_ID) restored)
   ============================================================ */
CREATE TABLE INVENTORY(
    Inventory_ID        NUMBER(6)     NOT NULL,
    Product_ID          NUMBER(6)     NOT NULL,
    Stock_Quantity      NUMBER(5)     NOT NULL,
    Last_Updated_Date   DATE          NOT NULL,
    CONSTRAINT INVENTORY_PK PRIMARY         KEY (Inventory_ID),
    CONSTRAINT INVENTORY_PRODUCT_UK         UNIQUE (Product_ID),
    CONSTRAINT INVENTORY_PRODUCT_FK FOREIGN KEY (Product_ID) REFERENCES PRODUCTS(Product_ID),
    CONSTRAINT INVENTORY_STOCK_CK           CHECK (Stock_Quantity >= 0)
);

/* ============================================================
   4. ORDERS
   ============================================================ */
CREATE TABLE ORDERS(
    Order_ID                       NUMBER(6)     NOT NULL,
    Customer_ID                    NUMBER(6)     NOT NULL,
    Order_Date                     DATE          NOT NULL,
    Order_Status                   VARCHAR2(20)  NOT NULL,
    Total_Amount                   NUMBER(10,2)  NOT NULL,
    Recipient_First_Name           VARCHAR2(50)  NOT NULL,
    Recipient_Last_Name            VARCHAR2(50)  NOT NULL,
    Recipient_Phone_Number         VARCHAR2(15)  NOT NULL,
    Recipient_Street_Address       VARCHAR2(255) NOT NULL,
    Recipient_City                 VARCHAR2(50)  NOT NULL,
    Recipient_State                VARCHAR2(50)  NOT NULL,
    Recipient_Postcode             VARCHAR2(10)  NOT NULL,
    CONSTRAINT ORDERS_PK PRIMARY          KEY (Order_ID),
    CONSTRAINT ORDERS_CUSTOMER_FK FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(CUSTOMER_ID),
    CONSTRAINT ORDERS_STATUS_CK           CHECK (Order_Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT ORDERS_TOTAL_CK            CHECK (Total_Amount >= 0)
);

/* ============================================================
   5. ORDER_ITEM
   ============================================================ */
CREATE TABLE ORDER_ITEM(
    Order_ID           NUMBER(6)     NOT NULL,
    Product_ID         NUMBER(6)     NOT NULL,
    Quantity           NUMBER(5)     NOT NULL,
    Purchase_Price     NUMBER(10,2)  NOT NULL,
    Subtotal           NUMBER(10,2)  NOT NULL,
    CONSTRAINT ORDER_ITEM_PK PRIMARY         KEY (Order_ID, Product_ID),
    CONSTRAINT ORDER_ITEM_ORDER_FK FOREIGN   KEY (Order_ID) REFERENCES ORDERS(Order_ID) ON DELETE CASCADE,
    CONSTRAINT ORDER_ITEM_PRODUCT_FK FOREIGN KEY (Product_ID) REFERENCES PRODUCTS(Product_ID),
    CONSTRAINT ORDER_ITEM_QUANTITY_CK        CHECK (Quantity > 0),
    CONSTRAINT ORDER_ITEM_PRICE_CK           CHECK (Purchase_Price >= 0),
    CONSTRAINT ORDER_ITEM_SUBTOTAL_CK        CHECK (Subtotal >= 0)
);

/* ============================================================
   6. PAYMENT (1:1 with ORDERS - UNIQUE(Order_ID) restored)
   ============================================================ */
CREATE TABLE PAYMENT(
    Payment_ID         NUMBER(6)     NOT NULL,
    Order_ID           NUMBER(6)     NOT NULL,
    Payment_Date       DATE          NOT NULL,
    Payment_Method     VARCHAR2(20)  NOT NULL,
    Payment_Status     VARCHAR2(20)  NOT NULL,
    CONSTRAINT PAYMENT_PK PRIMARY       KEY (Payment_ID),
    CONSTRAINT PAYMENT_ORDER_UK         UNIQUE (Order_ID),
    CONSTRAINT PAYMENT_ORDER_FK FOREIGN KEY (Order_ID) REFERENCES ORDERS(Order_ID),
    CONSTRAINT PAYMENT_METHOD_CK        CHECK (Payment_Method IN ('CARD', 'EWALLET', 'FPX')),
    CONSTRAINT PAYMENT_STATUS_CK        CHECK (Payment_Status IN ('Pending', 'Completed', 'Failed'))
);
/* ---- 6a. CARD_PAYMENT ---- */
CREATE TABLE CARD_PAYMENT(
    Payment_ID         NUMBER(6)     NOT NULL,
    Card_Type          VARCHAR2(20)  NOT NULL,
    Card_Last4         VARCHAR2(4)   NOT NULL,
    Auth_Code          VARCHAR2(20)  NOT NULL,
    CONSTRAINT CARD_PAYMENT_PK PRIMARY KEY (Payment_ID),
    CONSTRAINT CARD_PAYMENT_FK FOREIGN KEY (Payment_ID) REFERENCES PAYMENT(Payment_ID) ON DELETE CASCADE,
    CONSTRAINT CARD_TYPE_CK            CHECK (Card_Type IN ('Visa', 'Mastercard','Debit Card','Other')),
    CONSTRAINT CARD_LAST4_CK           CHECK (LENGTH(Card_Last4) = 4)
);
/* ---- 6b. EWALLET_PAYMENT (fields renamed per group decision) ---- */
CREATE TABLE EWALLET_PAYMENT(
    Payment_ID         NUMBER(6)     NOT NULL,
    EWallet_Type       VARCHAR2(30)  NOT NULL,
    EWallet_Account    VARCHAR2(50)  NOT NULL,
    CONSTRAINT EWALLET_PAYMENT_PK PRIMARY KEY (Payment_ID),
    CONSTRAINT EWALLET_PAYMENT_FK FOREIGN KEY (Payment_ID) REFERENCES PAYMENT(Payment_ID) ON DELETE CASCADE,
    CONSTRAINT EWALLET_TYPE_CK            CHECK (EWallet_Type IN ('Touch n Go eWallet', 'GrabPay', 'ShopeePay', 'Boost', 'PayPal', 'Alipay', 'WeChat Pay','Other'))
);
/* ---- 6c. BANKING_PAYMENT ---- */
CREATE TABLE BANKING_PAYMENT(
    Payment_ID         NUMBER(6)     NOT NULL,
    Bank_Name          VARCHAR2(50)  NOT NULL,
    FPX_Reference_No   VARCHAR2(50)  NOT NULL,
    CONSTRAINT BANKING_PAYMENT_PK PRIMARY KEY (Payment_ID),
    CONSTRAINT BANKING_PAYMENT_FK FOREIGN KEY (Payment_ID) REFERENCES PAYMENT(Payment_ID) ON DELETE CASCADE,
    CONSTRAINT BANKING_NAME_CK            CHECK (Bank_Name IN('Maybank', 'CIMB Bank', 'Public Bank', 'RHB Bank', 'Hong Leong Bank', 'AmBank', 'UOB', 'OCBC Bank', 'HSBC', 'Standard Chartered Bank','Other'))
);

/* ============================================================
   7. EMPLOYEE
   ============================================================ */
CREATE TABLE EMPLOYEE(
    Employee_ID        NUMBER(6)     NOT NULL,
    Emp_First_Name     VARCHAR2(50)  NOT NULL,
    Emp_Last_Name      VARCHAR2(50)  NOT NULL,
    Emp_Position       VARCHAR2(50)  NOT NULL,
    Emp_Phone_Number   VARCHAR2(15)  NOT NULL,
    CONSTRAINT EMPLOYEE_PK PRIMARY  KEY (Employee_ID),
    CONSTRAINT EMPLOYEE_PHONE_UK    UNIQUE (Emp_Phone_Number),
    CONSTRAINT EMPLOYEE_PHONE_CK    CHECK (REGEXP_LIKE(Emp_Phone_Number, '^\+?\d{1,3}?[-.\s]?\(?\d{1,4}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}$'))
);

/* ============================================================
   8. SHIPMENT (1:1 with ORDERS - UNIQUE(Order_ID) restored)
   ============================================================ */
CREATE TABLE SHIPMENT(
    Shipment_ID        NUMBER(6)     NOT NULL,
    Order_ID           NUMBER(6)     NOT NULL,
    Employee_ID        NUMBER(6)     NOT NULL,
    Shipment_Date      DATE          NOT NULL,
    Shipment_Status    VARCHAR2(20)  NOT NULL,
    Delivery_Mode      VARCHAR2(20)  NOT NULL,
    CONSTRAINT SHIPMENT_PK PRIMARY KEY (Shipment_ID),
    CONSTRAINT SHIPMENT_ORDER_UK UNIQUE (Order_ID),
    CONSTRAINT SHIPMENT_ORDER_FK FOREIGN KEY (Order_ID) REFERENCES ORDERS(Order_ID),
    CONSTRAINT SHIPMENT_EMPLOYEE_FK FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEE(Employee_ID),
    CONSTRAINT SHIPMENT_STATUS_CK CHECK (Shipment_Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Returned')),
    CONSTRAINT SHIPMENT_DELIVERY_CK CHECK (Delivery_Mode IN ('STANDARD', 'PICKUP'))
);
/* ---- 8a. STANDARD_DELIVERY (Tracking_Number stays here, discriminator = 'STANDARD') ---- */
CREATE TABLE STANDARD_DELIVERY(
    Shipment_ID        NUMBER(6)     NOT NULL,
    Courier_Company    VARCHAR2(50)  NOT NULL,
    Estimated_Days     NUMBER(2)     NOT NULL,
    Tracking_Number    VARCHAR2(50)  NOT NULL,
    CONSTRAINT STANDARD_DELIVERY_PK PRIMARY KEY (Shipment_ID),
    CONSTRAINT STANDARD_DELIVERY_FK FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT(Shipment_ID) ON DELETE CASCADE,
    CONSTRAINT STANDARD_DAYS_CK CHECK (Estimated_Days > 0)
);
/* ---- 8b. SELF_PICKUP (discriminator = 'PICKUP') ---- */
CREATE TABLE SELF_PICKUP(
    Shipment_ID        NUMBER(6)     NOT NULL,
    Pickup_Store       VARCHAR2(100) NOT NULL,
    Collection_Code    VARCHAR2(20)  NOT NULL,
    Pickup_Deadline    DATE          NOT NULL,
    CONSTRAINT SELF_PICKUP_PK PRIMARY KEY (Shipment_ID),
    CONSTRAINT SELF_PICKUP_FK FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT(Shipment_ID) ON DELETE CASCADE
);

/* ========================================================================================================================
   INSERT TABLES AND RECORDS
   ======================================================================================================================== */
/* ============================================================
   1. CUSTOMER (10 records)
   ============================================================ */
INSERT INTO CUSTOMER VALUES (1, 'John', 'Doe', 'john.doe@gmail.com', '012-345-6781');
INSERT INTO CUSTOMER VALUES (2, 'Wei Ming', 'Tan', 'weiming@gmail.com', '012-345-6782');
INSERT INTO CUSTOMER VALUES (3, 'Alice', 'Johnson', 'alice.johnson@gmail.com', '012-345-6783');
INSERT INTO CUSTOMER VALUES (4, 'Kavitha', 'Raj', 'kavitha@gmail.com', '012-345-6784');
INSERT INTO CUSTOMER VALUES (5, 'Amirul', 'Hakin', 'amirul_12@gmail.com', '012-345-6785');
INSERT INTO CUSTOMER VALUES (6, 'David', 'Miller', 'david.miller@gmail.com', '012-345-6786');
INSERT INTO CUSTOMER VALUES (7, 'Xin Ying', 'Wong', 'xinying12@gmail.com', '012-345-6787');
INSERT INTO CUSTOMER VALUES (8, 'Zhi Hao', 'Lee', 'zhihao05@gmail.com', '012-345-6788');
INSERT INTO CUSTOMER VALUES (9, 'Aisyah', 'Ibrahim', 'aisyah@gmail.com', '012-345-6789');
INSERT INTO CUSTOMER VALUES (10, 'Hannah', 'Rodriguez', 'hannah.rodriguez@gmail.com', '012-345-6790');

/* ============================================================
   2. PRODUCTS (10 records)
   ============================================================ */
INSERT INTO PRODUCTS VALUES (1, 'Wireless Mouse', 'Electronics', 25.99, 'A high-precision wireless mouse with ergonomic design.');
INSERT INTO PRODUCTS VALUES (2, 'Bluetooth Headphones', 'Electronics', 59.99, 'Noise-cancelling over-ear headphones with long battery life.');
INSERT INTO PRODUCTS VALUES (3, 'Smartphone Stand', 'Accessories', 15.49, 'Adjustable stand for smartphones and tablets.');
INSERT INTO PRODUCTS VALUES (4, 'USB-C Hub', 'Electronics', 34.99, 'Multi-port USB-C hub with HDMI and USB 3.0 ports.');
INSERT INTO PRODUCTS VALUES (5, 'Portable Charger', 'Electronics', 29.99, 'Compact power bank with fast charging capabilities.');
INSERT INTO PRODUCTS VALUES (6, 'Gaming Keyboard', 'Electronics', 89.99, 'Mechanical keyboard with customizable RGB lighting.');
INSERT INTO PRODUCTS VALUES (7, '4K Monitor', 'Electronics', 299.99, '27-inch 4K UHD monitor with HDR support.');
INSERT INTO PRODUCTS VALUES (8, 'External Hard Drive', 'Electronics', 79.99, '1TB external hard drive with USB 3.0 connectivity.');
INSERT INTO PRODUCTS VALUES (9, 'Wireless Charger', 'Electronics', 19.99, 'Qi-certified wireless charging pad for smartphones.');
INSERT INTO PRODUCTS VALUES (10, 'Smartwatch', 'Electronics', 199.99, 'Water-resistant smartwatch with fitness tracking features.');

/* ============================================================
   3. INVENTORY (10 records - one row per product, 1:1 restored)
   ============================================================ */
INSERT INTO INVENTORY VALUES (1, 1, 100, TO_DATE('2026-07-01', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (2, 2, 50, TO_DATE('2026-07-02', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (3, 3, 200, TO_DATE('2026-07-03', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (4, 4, 75, TO_DATE('2026-07-04', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (5, 5, 150, TO_DATE('2026-07-05', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (6, 6, 80, TO_DATE('2026-07-06', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (7, 7, 60, TO_DATE('2026-07-07', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (8, 8, 180, TO_DATE('2026-07-08', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (9, 9, 90, TO_DATE('2026-07-09', 'YYYY-MM-DD'));
INSERT INTO INVENTORY VALUES (10, 10, 120, TO_DATE('2026-07-10', 'YYYY-MM-DD'));

/* ============================================================
   4. EMPLOYEE (10 records)
   ============================================================ */
INSERT INTO EMPLOYEE VALUES (1, 'Ah Chong', 'Lim',    'Warehouse Staff',   '0134567891');
INSERT INTO EMPLOYEE VALUES (2, 'Farah',    'Yusof',  'Shipping Officer',  '0134567892');
INSERT INTO EMPLOYEE VALUES (3, 'Ravi',     'Kumar',  'Warehouse Staff',   '0134567893');
INSERT INTO EMPLOYEE VALUES (4, 'Mei Ling', 'Chan',   'Shipping Officer',  '0134567894');
INSERT INTO EMPLOYEE VALUES (5, 'Daniel',   'Wong',   'Logistics Supervisor', '0134567895');
INSERT INTO EMPLOYEE VALUES (6, 'Siti', 'Aminah', 'Warehouse Staff', '0134567896');
INSERT INTO EMPLOYEE VALUES (7, 'Ahmad', 'Hafiz', 'Shipping Officer', '0134567897');
INSERT INTO EMPLOYEE VALUES (8, 'Nurul', 'Huda', 'Warehouse Staff', '0134567898');
INSERT INTO EMPLOYEE VALUES (9, 'Lim', 'Wei', 'Logistics Supervisor', '0134567899');
INSERT INTO EMPLOYEE VALUES (10, 'Tan', 'Chong', 'Shipping Officer', '0134567800');

/* ============================================================
   5. ORDERS (15 records)
   ============================================================ */
INSERT INTO ORDERS VALUES (1, 1, TO_DATE('2026-07-01','YYYY-MM-DD'),'Delivered',111.97,'John','Doe','012-3456781','No.12 Jalan Bukit Bintang','Kuala Lumpur','Wilayah Persekutuan Kuala Lumpur','55100');
INSERT INTO ORDERS VALUES (2, 2, TO_DATE('2026-07-02','YYYY-MM-DD'),'Delivered',59.99,'Wei Ming','Tan','012-3456782','No.25 Jalan SS15/4','Subang Jaya','Selangor','47500');
INSERT INTO ORDERS VALUES (3, 3, TO_DATE('2026-07-03','YYYY-MM-DD'),'Shipped',46.47,'Alice','Johnson','012-3456783','No.45 Jalan Tun Razak','Petaling Jaya','Selangor','47300');
INSERT INTO ORDERS VALUES (4, 4, TO_DATE('2026-07-04','YYYY-MM-DD'),'Delivered',34.99,'Kavitha','Raj','012-3456784','No.18 Lebuh Pantai','George Town','Penang','10300');
INSERT INTO ORDERS VALUES (5, 5, TO_DATE('2026-07-05','YYYY-MM-DD'),'Cancelled',29.99,'Amirul','Hakin','012-3456785','No.66 Jalan Ipoh','Ipoh','Perak','30000');
INSERT INTO ORDERS VALUES (6, 6, TO_DATE('2026-07-06','YYYY-MM-DD'),'Pending',199.99,'David','Miller','012-3456786','No.9 Jalan Tuanku Abdul Rahman','Kuantan','Pahang','25000');
INSERT INTO ORDERS VALUES (7, 7, TO_DATE('2026-07-07','YYYY-MM-DD'),'Processing',79.99,'Xin Ying','Wong','012-3456787','No.30 Jalan Lintas','Kota Kinabalu','Sabah','88300');
INSERT INTO ORDERS VALUES (8, 8, TO_DATE('2026-07-08','YYYY-MM-DD'),'Shipped',34.99,'Zhi Hao','Lee','012-3456788','No.88 Jalan Pending','Kuching','Sarawak','93450');
INSERT INTO ORDERS VALUES (9, 9, TO_DATE('2026-07-09','YYYY-MM-DD'),'Delivered',59.99,'Aisyah','Ibrahim','012-3456789','No.21 Jalan Sultan Yahya Petra','Kota Bharu','Kelantan','15150');
INSERT INTO ORDERS VALUES (10, 10, TO_DATE('2026-07-10','YYYY-MM-DD'),'Delivered',25.99,'Hannah','Rodriguez','012-3456790','No.77 Jalan Tok Lam','Kuala Terengganu','Terengganu','20100');
INSERT INTO ORDERS VALUES (11, 1, TO_DATE('2026-07-11','YYYY-MM-DD'),'Pending',15.49,'John','Doe','012-3456781','No.12 Jalan Bukit Bintang','Kuala Lumpur','Wilayah Persekutuan Kuala Lumpur','55100');
INSERT INTO ORDERS VALUES (12, 2, TO_DATE('2026-07-12','YYYY-MM-DD'),'Pending',89.99,'Wei Ming','Tan','012-3456782','No.25 Jalan SS15/4','Subang Jaya','Selangor','47500');
INSERT INTO ORDERS VALUES (13, 3, TO_DATE('2026-07-13','YYYY-MM-DD'),'Pending',299.99,'Alice','Johnson','012-3456783','No.45 Jalan Tun Razak','Petaling Jaya','Selangor','47300');
INSERT INTO ORDERS VALUES (14, 4, TO_DATE('2026-07-14','YYYY-MM-DD'),'Processing',79.99,'Kavitha','Raj','012-3456784','No.18 Lebuh Pantai','George Town','Penang','10300');
INSERT INTO ORDERS VALUES (15, 5, TO_DATE('2026-07-15','YYYY-MM-DD'),'Pending',19.99,'Amirul','Hakin','012-3456785','No.66 Jalan Ipoh','Ipoh','Perak','30000');

/* ============================================================
   6. ORDER_ITEM (16 records)
   ============================================================ */
INSERT INTO ORDER_ITEM VALUES (1, 1, 2, 25.99, 51.98);
INSERT INTO ORDER_ITEM VALUES (1, 2, 1, 59.99, 59.99);
INSERT INTO ORDER_ITEM VALUES (2, 2, 1, 59.99, 59.99);
INSERT INTO ORDER_ITEM VALUES (3, 3, 3, 15.49, 46.47);
INSERT INTO ORDER_ITEM VALUES (4, 4, 1, 34.99, 34.99);
INSERT INTO ORDER_ITEM VALUES (5, 5, 1, 29.99, 29.99);
INSERT INTO ORDER_ITEM VALUES (6, 10, 1, 199.99, 199.99);
INSERT INTO ORDER_ITEM VALUES (7, 8, 1, 79.99, 79.99);
INSERT INTO ORDER_ITEM VALUES (8, 4, 1, 34.99, 34.99);
INSERT INTO ORDER_ITEM VALUES (9, 2, 1, 59.99, 59.99);
INSERT INTO ORDER_ITEM VALUES (10, 1, 1, 25.99, 25.99);
INSERT INTO ORDER_ITEM VALUES (11, 3, 1, 15.49, 15.49);
INSERT INTO ORDER_ITEM VALUES (12, 6, 1, 89.99, 89.99);
INSERT INTO ORDER_ITEM VALUES (13, 7, 1, 299.99, 299.99);
INSERT INTO ORDER_ITEM VALUES (14, 8, 1, 79.99, 79.99);
INSERT INTO ORDER_ITEM VALUES (15, 9, 1, 19.99, 19.99);

/* ============================================================
   7. PAYMENT (15 records: 5 CARD + 5 EWALLET + 5 FPX)
   ============================================================ */
-- CARD payments (Payment_ID 1-5)
INSERT INTO PAYMENT VALUES (1,  1,  TO_DATE('2026-07-01', 'YYYY-MM-DD'), 'CARD', 'Completed');
INSERT INTO PAYMENT VALUES (2,  2,  TO_DATE('2026-07-02', 'YYYY-MM-DD'), 'CARD', 'Completed');
INSERT INTO PAYMENT VALUES (3,  3,  TO_DATE('2026-07-03', 'YYYY-MM-DD'), 'CARD', 'Completed');
INSERT INTO PAYMENT VALUES (4,  4,  TO_DATE('2026-07-04', 'YYYY-MM-DD'), 'CARD', 'Completed');
INSERT INTO PAYMENT VALUES (5,  5,  TO_DATE('2026-07-05', 'YYYY-MM-DD'), 'CARD', 'Completed');
-- EWALLET payments (Payment_ID 6-10)
INSERT INTO PAYMENT VALUES (6,  6,  TO_DATE('2026-07-06', 'YYYY-MM-DD'), 'EWALLET', 'Completed');
INSERT INTO PAYMENT VALUES (7,  7,  TO_DATE('2026-07-07', 'YYYY-MM-DD'), 'EWALLET', 'Completed');
INSERT INTO PAYMENT VALUES (8,  8,  TO_DATE('2026-07-08', 'YYYY-MM-DD'), 'EWALLET', 'Completed');
INSERT INTO PAYMENT VALUES (9,  9,  TO_DATE('2026-07-09', 'YYYY-MM-DD'), 'EWALLET', 'Completed');
INSERT INTO PAYMENT VALUES (10, 10, TO_DATE('2026-07-10', 'YYYY-MM-DD'), 'EWALLET', 'Completed');
-- FPX / banking payments (Payment_ID 11-15)
INSERT INTO PAYMENT VALUES (11, 11, TO_DATE('2026-07-11', 'YYYY-MM-DD'), 'FPX', 'Pending');
INSERT INTO PAYMENT VALUES (12, 12, TO_DATE('2026-07-12', 'YYYY-MM-DD'), 'FPX', 'Pending');
INSERT INTO PAYMENT VALUES (13, 13, TO_DATE('2026-07-13', 'YYYY-MM-DD'), 'FPX', 'Pending');
INSERT INTO PAYMENT VALUES (14, 14, TO_DATE('2026-07-14', 'YYYY-MM-DD'), 'FPX', 'Failed');
INSERT INTO PAYMENT VALUES (15, 15, TO_DATE('2026-07-15', 'YYYY-MM-DD'), 'FPX', 'Pending');

/*  ------7a. CARD_PAYMENT (5 records) ------*/
INSERT INTO CARD_PAYMENT VALUES (1, 'Visa',       '4321', 'AUTH1001');
INSERT INTO CARD_PAYMENT VALUES (2, 'Mastercard', '8765', 'AUTH1002');
INSERT INTO CARD_PAYMENT VALUES (3, 'Visa',       '2468', 'AUTH1003');
INSERT INTO CARD_PAYMENT VALUES (4, 'Mastercard', '1357', 'AUTH1004');
INSERT INTO CARD_PAYMENT VALUES (5, 'Visa',       '9988', 'AUTH1005');
/*  ------7b. EWALLET_PAYMENT (5 records)------*/
INSERT INTO EWALLET_PAYMENT VALUES (6,  'Touch n Go eWallet', 'TNG20260706001');
INSERT INTO EWALLET_PAYMENT VALUES (7,  'GrabPay',            'GRB20260707002');
INSERT INTO EWALLET_PAYMENT VALUES (8,  'Boost',              'BST20260708003');
INSERT INTO EWALLET_PAYMENT VALUES (9,  'Touch n Go eWallet', 'TNG20260709004');
INSERT INTO EWALLET_PAYMENT VALUES (10, 'GrabPay',            'GRB20260710005');
/*------7c. BANKING_PAYMENT (5 records) */
INSERT INTO BANKING_PAYMENT VALUES (11, 'Maybank',      'FPX20260711001');
INSERT INTO BANKING_PAYMENT VALUES (12, 'CIMB Bank',    'FPX20260712002');
INSERT INTO BANKING_PAYMENT VALUES (13, 'Public Bank',  'FPX20260713003');
INSERT INTO BANKING_PAYMENT VALUES (14, 'Maybank',      'FPX20260714004');
INSERT INTO BANKING_PAYMENT VALUES (15, 'RHB Bank',     'FPX20260715005');

/* ============================================================
   8. SHIPMENT (15 records - matches ORDERS/PAYMENT for dataset consistency: 8 STANDARD + 7 PICKUP)
   ============================================================ */
INSERT INTO SHIPMENT VALUES (1, 1, 1, TO_DATE('2026-07-02', 'YYYY-MM-DD'), 'Delivered', 'STANDARD');
INSERT INTO SHIPMENT VALUES (2, 2, 2, TO_DATE('2026-07-03', 'YYYY-MM-DD'), 'Delivered', 'STANDARD');
INSERT INTO SHIPMENT VALUES (3, 3, 3, TO_DATE('2026-07-04', 'YYYY-MM-DD'), 'Shipped',   'STANDARD');
INSERT INTO SHIPMENT VALUES (4, 4, 4, TO_DATE('2026-07-05', 'YYYY-MM-DD'), 'Delivered', 'STANDARD');
INSERT INTO SHIPMENT VALUES (5, 5, 5, TO_DATE('2026-07-06', 'YYYY-MM-DD'), 'Returned',  'STANDARD');
INSERT INTO SHIPMENT VALUES (6, 6, 6, TO_DATE('2026-07-07', 'YYYY-MM-DD'), 'Pending',   'PICKUP');
INSERT INTO SHIPMENT VALUES (7, 7, 7, TO_DATE('2026-07-08', 'YYYY-MM-DD'), 'Processing','PICKUP');
INSERT INTO SHIPMENT VALUES (8, 8, 8, TO_DATE('2026-07-09', 'YYYY-MM-DD'), 'Shipped',   'PICKUP');
INSERT INTO SHIPMENT VALUES (9, 9, 9, TO_DATE('2026-07-10', 'YYYY-MM-DD'), 'Delivered', 'PICKUP');
INSERT INTO SHIPMENT VALUES (10, 10, 10, TO_DATE('2026-07-11', 'YYYY-MM-DD'), 'Delivered', 'PICKUP');
INSERT INTO SHIPMENT VALUES (11, 11, 1, TO_DATE('2026-07-12', 'YYYY-MM-DD'), 'Pending',   'STANDARD');
INSERT INTO SHIPMENT VALUES (12, 12, 2, TO_DATE('2026-07-13', 'YYYY-MM-DD'), 'Pending',   'STANDARD');
INSERT INTO SHIPMENT VALUES (13, 13, 3, TO_DATE('2026-07-14', 'YYYY-MM-DD'), 'Pending',   'PICKUP');
INSERT INTO SHIPMENT VALUES (14, 14, 4, TO_DATE('2026-07-15', 'YYYY-MM-DD'), 'Processing','STANDARD');
INSERT INTO SHIPMENT VALUES (15, 15, 5, TO_DATE('2026-07-16', 'YYYY-MM-DD'), 'Pending',   'PICKUP');
/* ------ 8a. STANDARD_DELIVERY (8 records - Shipment_ID 1-5,11,12,14)------ */
INSERT INTO STANDARD_DELIVERY VALUES (1, 'DHL', 5, 'DHL20260702001');
INSERT INTO STANDARD_DELIVERY VALUES (2, 'JNT Express', 2, 'JT20260703002');
INSERT INTO STANDARD_DELIVERY VALUES (3, 'Pos Laju', 7, 'POS20260704003');
INSERT INTO STANDARD_DELIVERY VALUES (4, 'JNT Express', 2, 'JT20260705004');
INSERT INTO STANDARD_DELIVERY VALUES (5, 'DHL', 5, 'DHL20260706005');
INSERT INTO STANDARD_DELIVERY VALUES (11, 'Pos Laju', 7, 'POS20260712011');
INSERT INTO STANDARD_DELIVERY VALUES (12, 'DHL', 5, 'DHL20260713012');
INSERT INTO STANDARD_DELIVERY VALUES (14, 'JNT Express', 2, 'JT20260715014');
/* ------8b. SELF_PICKUP (7 records - Shipment_ID 6-10,13,15)------ */
INSERT INTO SELF_PICKUP VALUES (6, 'Kuala Lumpur Store', 'PICK20260707006', TO_DATE('2026-07-14', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (7, 'Petaling Jaya Store', 'PICK20260708007', TO_DATE('2026-07-15', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (8, 'Penang Store', 'PICK20260709008', TO_DATE('2026-07-16', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (9, 'Johor Bahru Store', 'PICK20260710009', TO_DATE('2026-07-17', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (10, 'Kota Kinabalu Store', 'PICK20260711010', TO_DATE('2026-07-18', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (13, 'Kuching Store', 'PICK20260714013', TO_DATE('2026-07-21', 'YYYY-MM-DD'));
INSERT INTO SELF_PICKUP VALUES (15, 'Ipoh Store', 'PICK20260716015', TO_DATE('2026-07-23', 'YYYY-MM-DD'));

COMMIT;