/* ============================================================
    INDIVIDUAL ASSIGNMENT SUBMISSION

    STUDENT NAME : Leong Di Hao
    STUDENT ID : 2402175
    GROUP NUMBER : G010
    PROGRAMME : BS
    Submission date and time: 28 - 08 -2026
   ============================================================ */


/* Query 01 question:
   Display the order history of customers, including the customer name, order date, order status and total amount.
*/

SELECT 

    c.Customer_ID, 

    c.Cus_First_Name || ' ' || c.Cus_Last_Name AS Customer_Name, 

    o.Order_ID, 

    o.Order_Date, 

    o.Order_Status, 

    o.Total_Amount 

FROM CUSTOMER c 

JOIN ORDERS o 

    ON c.Customer_ID = o.Customer_ID 

ORDER BY 

    c.Customer_ID, 

    o.Order_Date; 


/* Query 02 question:
   Display the total number of non-cancelled orders and total purchase amount for customers with non-cancelled orders. 
*/

SELECT 

    c.Customer_ID, 

    c.Cus_First_Name || ' ' || c.Cus_Last_Name AS Customer_Name, 

    COUNT(o.Order_ID) AS Total_Orders, 

    SUM(o.Total_Amount) AS Total_Purchase_Amount 

FROM CUSTOMER c 

JOIN ORDERS o 

    ON c.Customer_ID = o.Customer_ID 

WHERE o.Order_Status <> 'Cancelled' 

GROUP BY 

    c.Customer_ID, 

    c.Cus_First_Name, 

    c.Cus_Last_Name 

ORDER BY 

    Total_Purchase_Amount DESC;


/* Stored Procedure 01 question:
   Update the status of a specified order. 
*/

CREATE OR REPLACE PROCEDURE Update_Order_Status ( 

    p_order_id   IN NUMBER, 

    p_new_status IN VARCHAR2 

) 

IS 

BEGIN 

    UPDATE ORDERS 

    SET Order_Status = p_new_status 

    WHERE Order_ID = p_order_id; 

  

    IF SQL%ROWCOUNT = 0 THEN 

        RAISE_APPLICATION_ERROR( 

            -20001, 

            'Order ID does not exist.' 

        ); 

    END IF; 

    COMMIT; 

END; 

/ 


/* Stored Procedure 02 question:
   Add a product item to an existing order. 
*/

CREATE OR REPLACE PROCEDURE Add_Order_Item ( 

    p_order_id   IN NUMBER, 

    p_product_id IN NUMBER, 

    p_quantity   IN NUMBER 

) 

IS 

    v_product_price PRODUCTS.Current_Price%TYPE; 

    v_order_count   NUMBER; 

    v_item_count    NUMBER; 

    v_subtotal      NUMBER(10,2); 

BEGIN 

    IF p_quantity <= 0 THEN 

        RAISE_APPLICATION_ERROR( 

            -20004, 

            'Quantity must be greater than zero.' 

        ); 

    END IF; 

    /* Check whether the order exists */ 

    SELECT COUNT(*) 

    INTO v_order_count 

    FROM ORDERS 

    WHERE Order_ID = p_order_id; 

    IF v_order_count = 0 THEN 

        RAISE_APPLICATION_ERROR( 

            -20005, 

            'Order ID does not exist.' 

        ); 

    END IF; 

    /* Check whether the product exists and obtain its current price */ 

    BEGIN 

        SELECT Current_Price 

        INTO v_product_price 

        FROM PRODUCTS 

        WHERE Product_ID = p_product_id; 

    EXCEPTION 

        WHEN NO_DATA_FOUND THEN 

            RAISE_APPLICATION_ERROR( 

                -20006, 

                'Product ID does not exist.' 

            ); 

    END; 

    /* Check whether the product is already in the order */ 

    SELECT COUNT(*) 

    INTO v_item_count 

    FROM ORDER_ITEM 

    WHERE Order_ID = p_order_id 

      AND Product_ID = p_product_id; 

    IF v_item_count > 0 THEN 

        RAISE_APPLICATION_ERROR( 

            -20007, 

            'Product already exists in this order.' 

        ); 

    END IF; 

    /* Calculate subtotal */ 

    v_subtotal := p_quantity * v_product_price; 

    /* Insert new order item */ 

    INSERT INTO ORDER_ITEM ( 

        Order_ID, 

        Product_ID, 

        Quantity, 

        Purchase_Price, 

        Subtotal 

    ) 

    VALUES ( 

        p_order_id, 

        p_product_id, 

        p_quantity, 

        v_product_price, 

        v_subtotal 

    ); 

    /* Update order total */ 

    UPDATE ORDERS 

    SET Total_Amount = Total_Amount + v_subtotal 

    WHERE Order_ID = p_order_id; 

    COMMIT; 

END; 

/


/* Function 01 question:
   Calculate the total purchase amount of a specified customer.
*/

CREATE OR REPLACE FUNCTION Get_Customer_Total_Spending ( 

    p_customer_id IN NUMBER 

) 

RETURN NUMBER 

IS 

    v_total_spending NUMBER(10,2); 

BEGIN 

    SELECT NVL(SUM(o.Total_Amount), 0) 

    INTO v_total_spending 

    FROM ORDERS o 

    WHERE o.Customer_ID = p_customer_id 

      AND o.Order_Status <> 'Cancelled'; 

    RETURN v_total_spending; 

END; 

/


/* Function 02 question:
   Count the number of orders placed by a specified customer. 
*/

CREATE OR REPLACE FUNCTION Count_Customer_Orders ( 

    p_customer_id IN NUMBER 

) 

RETURN NUMBER 

IS 

    v_order_count NUMBER; 

BEGIN 

    SELECT COUNT(*) 

    INTO v_order_count 

    FROM ORDERS 

    WHERE Customer_ID = p_customer_id 

      AND Order_Status <> 'Cancelled'; 

    RETURN v_order_count; 

END; 

/ 