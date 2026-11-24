SET DEFINE OFF
SET SCAN OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET LINESIZE 100
SET PAGESIZE 100
SET FEEDBACK ON
SET ECHO OFF
SET VERIFY OFF
COLUMN Product_ID           HEADING 'ID'          FORMAT 9999
COLUMN Product_Name         HEADING 'PRODUCT NAME'      FORMAT A22
COLUMN Category             HEADING 'CATEGORY'    FORMAT A12
COLUMN Current_Price        HEADING 'PRICE'       FORMAT 9990.00
COLUMN Stock_Quantity       HEADING 'STOCK'       FORMAT 99999
COLUMN Total_Units_Sold     HEADING 'SOLD'        FORMAT 99999
COLUMN Total_Revenue        HEADING 'REVENUE'     FORMAT 999990.00
COLUMN Units_Sold           HEADING 'SOLD'        FORMAT 99999
COLUMN Stock_Value          HEADING 'STOCK VALUE' FORMAT 999,990.00
COLUMN Stock_Status         HEADING 'STATUS'      FORMAT A11
COLUMN Book_Stock           HEADING 'BOOK'        FORMAT 99999
COLUMN Available_Stock      HEADING 'AVAILABLE'   FORMAT 99999
COLUMN Reserved_Units       HEADING 'RESERVED'    FORMAT 99999
COLUMN Lifetime_Revenue     HEADING 'LIFETIME'    FORMAT 999990.00
COLUMN Week1_Revenue        HEADING 'WEEK 1'      FORMAT 999990.00
COLUMN Revenue              HEADING 'REVENUE'     FORMAT 999990.00
COLUMN Action               HEADING 'ACTION'      FORMAT A16
COLUMN Invalid_Product_Test HEADING 'RESULT'      FORMAT 99999
COLUMN Stock_Before         HEADING 'STOCK BEFORE' FORMAT 99999
COLUMN Stock_After          HEADING 'STOCK AFTER'  FORMAT 99999

/* ============================================================
    INDIVIDUAL ASSIGNMENT SUBMISSION

    STUDENT NAME : Ngu Jing Rong
    STUDENT ID : 2402705
    GROUP NUMBER : G010
    PROGRAMME : BS
    Submission date and time: 28 - 08 -2026
   ============================================================ */


PROMPT
PROMPT ==========================================================================
PROMPT   PART B - NGU JING RONG (MEMBER 3) - PRODUCT AND INVENTORY MODULE
PROMPT ==========================================================================
PROMPT


PROMPT
PROMPT ==========================================================================
PROMPT   QUERY 1 : Product Sales Performance Report
PROMPT ==========================================================================
PROMPT


SELECT  p.Product_ID,
        p.Product_Name,
        p.Category,
        p.Current_Price,
        i.Stock_Quantity,
        NVL(SUM(CASE WHEN o.Order_Status <> 'Cancelled'
                     THEN oi.Quantity END), 0)              AS Total_Units_Sold,
        NVL(SUM(CASE WHEN o.Order_Status <> 'Cancelled'
                     THEN oi.Subtotal END), 0)              AS Total_Revenue
FROM        PRODUCTS   p
INNER JOIN  INVENTORY  i  ON i.Product_ID = p.Product_ID
LEFT  JOIN  ORDER_ITEM oi ON oi.Product_ID = p.Product_ID
LEFT  JOIN  ORDERS     o  ON o.Order_ID    = oi.Order_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category,
         p.Current_Price, i.Stock_Quantity
ORDER BY Total_Revenue DESC, p.Product_ID;


PROMPT
PROMPT ==========================================================================
PROMPT   QUERY 2 : Slow-Moving and Non-Moving Stock Report
PROMPT ==========================================================================
PROMPT


SELECT  p.Product_ID,
        p.Product_Name,
        p.Category,
        i.Stock_Quantity,
        NVL(SUM(CASE WHEN o.Order_Status <> 'Cancelled'
                     THEN oi.Quantity END), 0)                 AS Units_Sold,
        ROUND(i.Stock_Quantity * p.Current_Price, 2)           AS Stock_Value,
        CASE WHEN NVL(SUM(CASE WHEN o.Order_Status <> 'Cancelled'
                              THEN oi.Quantity END), 0) = 0
             THEN 'NON-MOVING'
             ELSE 'SLOW-MOVING'
        END                                                    AS Stock_Status
FROM        PRODUCTS   p
INNER JOIN  INVENTORY  i  ON i.Product_ID = p.Product_ID
LEFT  JOIN  ORDER_ITEM oi ON oi.Product_ID = p.Product_ID
LEFT  JOIN  ORDERS     o  ON o.Order_ID    = oi.Order_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category,
         i.Stock_Quantity, p.Current_Price
HAVING  NVL(SUM(CASE WHEN o.Order_Status <> 'Cancelled'
                     THEN oi.Quantity END), 0)
        <
        (  SELECT AVG(t.Units)
           FROM ( SELECT p2.Product_ID,
                         NVL(SUM(CASE WHEN o2.Order_Status <> 'Cancelled'
                                      THEN oi2.Quantity END), 0) AS Units
                  FROM       PRODUCTS   p2
                  LEFT JOIN  ORDER_ITEM oi2 ON oi2.Product_ID = p2.Product_ID
                  LEFT JOIN  ORDERS     o2  ON o2.Order_ID    = oi2.Order_ID
                  GROUP BY p2.Product_ID ) t )
ORDER BY Stock_Value DESC;


PROMPT
PROMPT ==========================================================================
PROMPT   PROCEDURE 1 : SP_RESTOCK_PRODUCT
PROMPT ==========================================================================
PROMPT


CREATE OR REPLACE PROCEDURE SP_RESTOCK_PRODUCT (
    p_product_id  IN  PRODUCTS.Product_ID%TYPE,
    p_qty_added   IN  NUMBER,
    p_new_stock   OUT INVENTORY.Stock_Quantity%TYPE
)
IS
    v_product_name  PRODUCTS.Product_Name%TYPE;
    v_old_stock     INVENTORY.Stock_Quantity%TYPE;
    e_invalid_qty   EXCEPTION;
BEGIN
    IF p_qty_added IS NULL OR p_qty_added <= 0 THEN
        RAISE e_invalid_qty;
    END IF;

    SELECT p.Product_Name, i.Stock_Quantity
      INTO v_product_name, v_old_stock
      FROM PRODUCTS  p
      JOIN INVENTORY i ON i.Product_ID = p.Product_ID
     WHERE p.Product_ID = p_product_id;

    UPDATE INVENTORY
       SET Stock_Quantity    = Stock_Quantity + p_qty_added,
           Last_Updated_Date = SYSDATE
     WHERE Product_ID = p_product_id;

    p_new_stock := v_old_stock + p_qty_added;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('--- RESTOCK SUCCESSFUL ---');
    DBMS_OUTPUT.PUT_LINE('Product ID    : ' || p_product_id);
    DBMS_OUTPUT.PUT_LINE('Product Name  : ' || v_product_name);
    DBMS_OUTPUT.PUT_LINE('Stock Before  : ' || v_old_stock);
    DBMS_OUTPUT.PUT_LINE('Quantity Added: ' || p_qty_added);
    DBMS_OUTPUT.PUT_LINE('Stock After   : ' || p_new_stock);

EXCEPTION
    WHEN e_invalid_qty THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Restock quantity must be a positive number.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Product ID ' || p_product_id || ' does not exist in PRODUCTS/INVENTORY.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003,
            'Unexpected error during restock: ' || SQLERRM);
END;
/


PROMPT
PROMPT ==========================================================================
PROMPT   PROCEDURE 2 : SP_LOW_STOCK_REPORT
PROMPT ==========================================================================
PROMPT


CREATE OR REPLACE PROCEDURE SP_LOW_STOCK_REPORT (
    p_threshold IN NUMBER DEFAULT 100
)
IS
    CURSOR c_low_stock IS
        SELECT p.Product_ID,
               p.Product_Name,
               p.Category,
               i.Stock_Quantity,
               p.Current_Price,
               ROUND(i.Stock_Quantity * p.Current_Price, 2) AS Stock_Value
          FROM PRODUCTS  p
          JOIN INVENTORY i ON i.Product_ID = p.Product_ID
         WHERE i.Stock_Quantity < p_threshold
         ORDER BY i.Stock_Quantity ASC;

    v_count       NUMBER       := 0;
    v_total_value NUMBER(12,2) := 0;
BEGIN
    IF p_threshold IS NULL OR p_threshold <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Threshold must be a positive number.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('=', 67, '='));
    DBMS_OUTPUT.PUT_LINE('LOW STOCK ALERT REPORT  (threshold < '
                         || p_threshold || ' units)');
    DBMS_OUTPUT.PUT_LINE('Generated on : '
                         || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 67, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('ID', 5)  || RPAD('PRODUCT NAME', 26)
                      || RPAD('CATEGORY', 15) || LPAD('STOCK', 7)
                      || LPAD('VALUE(RM)', 14));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 67, '-'));

    FOR r IN c_low_stock LOOP
        v_count       := v_count + 1;
        v_total_value := v_total_value + r.Stock_Value;

        DBMS_OUTPUT.PUT_LINE(
              RPAD(TO_CHAR(r.Product_ID), 5)
           || RPAD(SUBSTR(r.Product_Name, 1, 24), 26)
           || RPAD(r.Category, 15)
           || LPAD(TO_CHAR(r.Stock_Quantity), 7)
           || LPAD(TO_CHAR(r.Stock_Value, '999,990.00'), 14));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 67, '-'));

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No product is below the threshold. '
                          || 'Stock level is healthy.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Products requiring restock : ' || v_count);
        DBMS_OUTPUT.PUT_LINE('Total value at risk (RM)   : '
                          || TO_CHAR(v_total_value, '999,990.00'));
    END IF;
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 67, '='));
END;
/


PROMPT
PROMPT ==========================================================================
PROMPT   FUNCTION 1 : FN_GET_AVAILABLE_STOCK
PROMPT ==========================================================================
PROMPT

CREATE OR REPLACE FUNCTION FN_GET_AVAILABLE_STOCK (
    p_product_id IN PRODUCTS.Product_ID%TYPE
)
RETURN NUMBER
IS
    v_stock     INVENTORY.Stock_Quantity%TYPE;
    v_reserved  NUMBER := 0;
BEGIN
    SELECT i.Stock_Quantity
      INTO v_stock
      FROM INVENTORY i
     WHERE i.Product_ID = p_product_id;

    SELECT NVL(SUM(oi.Quantity), 0)
      INTO v_reserved
      FROM ORDER_ITEM oi
      JOIN ORDERS     o ON o.Order_ID = oi.Order_ID
     WHERE oi.Product_ID  = p_product_id
       AND o.Order_Status IN ('Pending', 'Processing');

    RETURN v_stock - v_reserved;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
END;
/


PROMPT
PROMPT ==========================================================================
PROMPT   FUNCTION 2 : FN_GET_PRODUCT_REVENUE
PROMPT ==========================================================================
PROMPT


CREATE OR REPLACE FUNCTION FN_GET_PRODUCT_REVENUE (
    p_product_id IN PRODUCTS.Product_ID%TYPE,
    p_start_date IN DATE DEFAULT NULL,
    p_end_date   IN DATE DEFAULT NULL
)
RETURN NUMBER
IS
    v_revenue     NUMBER(12,2) := 0;
    v_product_cnt NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_product_cnt
      FROM PRODUCTS
     WHERE Product_ID = p_product_id;

    IF v_product_cnt = 0 THEN
        RETURN -1;
    END IF;

    SELECT NVL(SUM(oi.Subtotal), 0)
      INTO v_revenue
      FROM ORDER_ITEM oi
      JOIN ORDERS     o ON o.Order_ID = oi.Order_ID
     WHERE oi.Product_ID  = p_product_id
       AND o.Order_Status <> 'Cancelled'
       AND o.Order_Date   >= NVL(p_start_date, o.Order_Date)
       AND o.Order_Date   <= NVL(p_end_date,   o.Order_Date);

    RETURN v_revenue;
END;
/



PROMPT
PROMPT ==========================================================================
PROMPT   SECTION 4 : TESTS AND DEMONSTRATION
PROMPT ==========================================================================

VARIABLE v_result NUMBER


PROMPT
PROMPT >>> 4.1  F1 : book stock versus true available stock
PROMPT
SELECT p.Product_ID,
       p.Product_Name,
       i.Stock_Quantity                         AS Book_Stock,
       FN_GET_AVAILABLE_STOCK(p.Product_ID)     AS Available_Stock,
       i.Stock_Quantity
         - FN_GET_AVAILABLE_STOCK(p.Product_ID) AS Reserved_Units
FROM   PRODUCTS  p
JOIN   INVENTORY i ON i.Product_ID = p.Product_ID
ORDER  BY p.Product_ID;


PROMPT
PROMPT >>> 4.2  F1 : product does not exist, expect sentinel -1
PROMPT
SELECT FN_GET_AVAILABLE_STOCK(999) AS Invalid_Product_Test FROM DUAL;


PROMPT
PROMPT >>> 4.3  F2 : lifetime revenue versus revenue for 01-07 July 2026
PROMPT
SELECT p.Product_ID,
       p.Product_Name,
       FN_GET_PRODUCT_REVENUE(p.Product_ID)  AS Lifetime_Revenue,
       FN_GET_PRODUCT_REVENUE(p.Product_ID,
                              TO_DATE('2026-07-01','YYYY-MM-DD'),
                              TO_DATE('2026-07-07','YYYY-MM-DD'))
                                             AS Week1_Revenue
FROM   PRODUCTS p
ORDER  BY Lifetime_Revenue DESC;


PROMPT
PROMPT >>> 4.4  Both functions combined into one management view
PROMPT
SELECT p.Product_Name,
       FN_GET_AVAILABLE_STOCK(p.Product_ID)  AS Available_Stock,
       FN_GET_PRODUCT_REVENUE(p.Product_ID)  AS Revenue,
       CASE WHEN FN_GET_AVAILABLE_STOCK(p.Product_ID) < 60
            THEN 'RESTOCK NEEDED' ELSE 'OK' END AS Action
FROM   PRODUCTS p
ORDER  BY Available_Stock ASC;


PROMPT
PROMPT >>> 4.5  P2 : threshold 100 supplied explicitly
PROMPT
EXEC SP_LOW_STOCK_REPORT(100)


PROMPT
PROMPT >>> 4.6  P2 : argument omitted, DEFAULT 100 applies
PROMPT
EXEC SP_LOW_STOCK_REPORT


PROMPT
PROMPT >>> 4.7  P2 : threshold 10, no rows, healthy message
PROMPT
EXEC SP_LOW_STOCK_REPORT(10)


PROMPT
PROMPT >>> 4.8  P2 : invalid threshold, expect ORA-20010
PROMPT
EXEC SP_LOW_STOCK_REPORT(-1)


PROMPT
PROMPT >>> 4.9  P1 : negative quantity, expect ORA-20001
PROMPT
EXEC SP_RESTOCK_PRODUCT(1, -5, :v_result)


PROMPT
PROMPT >>> 4.10 Proof the failed call above left the table untouched (expect 100)
PROMPT
SELECT Product_ID, Stock_Quantity
FROM   INVENTORY
WHERE  Product_ID = 1;


PROMPT
PROMPT >>> 4.11 P1 : product does not exist, expect ORA-20002
PROMPT
EXEC SP_RESTOCK_PRODUCT(999, 10, :v_result)


PROMPT
PROMPT ==========================================================================
PROMPT   4.12  P1 : SUCCESSFUL RESTOCK - THIS STEP MODIFIES THE DATA
PROMPT         Product 2 receives 30 additional units.
PROMPT         Re-run STEP 1 to reset before demonstrating again.
PROMPT ==========================================================================
PROMPT
SELECT Product_ID, Stock_Quantity AS Stock_Before
FROM   INVENTORY
WHERE  Product_ID = 2;

EXEC SP_RESTOCK_PRODUCT(2, 30, :v_result)

PROMPT
PROMPT >>> OUT parameter returned to the caller
PROMPT
PRINT v_result

PROMPT
PROMPT >>> Confirmation that the row was updated (Stock Before + 30)
PROMPT
SELECT Product_ID, Stock_Quantity AS Stock_After
FROM   INVENTORY
WHERE  Product_ID = 2;


PROMPT
PROMPT ==========================================================================
PROMPT   END OF PART B - NGU JING RONG
PROMPT ==========================================================================
PROMPT
