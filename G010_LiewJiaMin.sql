/* ============================================================
    INDIVIDUAL ASSIGNMENT SUBMISSION

    STUDENT NAME : Liew Jia Min
    STUDENT ID : 2402265
    GROUP NUMBER : G010
    PROGRAMME : BS
    Submission date and time: 28 - 08 -2026
   ============================================================ */

/* Query 1 question:
   Display all completed payments together with the related order and customer details.
*/

SELECT
    p.Payment_ID,
    p.Payment_Date,
    p.Payment_Method,
    p.Payment_Status,
    o.Order_ID,
    o.Total_Amount,
    c.Cus_First_Name || ' ' || c.Cus_Last_Name AS Customer_Name
FROM PAYMENT p
JOIN ORDERS o
    ON p.Order_ID = o.Order_ID
JOIN CUSTOMER c
    ON o.Customer_ID = c.Customer_ID
WHERE p.Payment_Status = 'Completed'
ORDER BY p.Payment_Date DESC;


/* Query 2 question:
   Display all card payments together with their card payment details.
*/

SELECT
    p.Payment_ID,
    p.Order_ID,
    p.Payment_Date,
    p.Payment_Status,
    cp.Card_Type,
    cp.Card_Last4,
    cp.Auth_Code
FROM PAYMENT p
JOIN CARD_PAYMENT cp
    ON p.Payment_ID = cp.Payment_ID
ORDER BY p.Payment_ID;


/* Stored Procedure 1 question:
   Create a procedure to add a new e-wallet payment for a specified order.
*/

CREATE OR REPLACE PROCEDURE Add_EWallet_Payment (
    p_payment_id       IN NUMBER,
    p_order_id         IN NUMBER,
    p_payment_status   IN VARCHAR2,
    p_ewallet_type     IN VARCHAR2,
    p_ewallet_account  IN VARCHAR2
)
IS
BEGIN
    INSERT INTO PAYMENT (
        Payment_ID,
        Order_ID,
        Payment_Date,
        Payment_Method,
        Payment_Status
    )
    VALUES (
        p_payment_id,
        p_order_id,
        SYSDATE,
        'EWALLET',
        p_payment_status
    );
    INSERT INTO EWALLET_PAYMENT (
        Payment_ID,
        EWallet_Type,
        EWallet_Account
    )
    VALUES (
        p_payment_id,
        p_ewallet_type,
        p_ewallet_account
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(
        'E-wallet payment added successfully.'
    );
END;
/

/* Stored Procedure 2 question:
   Create a procedure to display the payment history of a specified customer.
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE Print_Customer_Payment_History (
    p_customer_id IN NUMBER
)
IS
    CURSOR payment_cursor IS
        SELECT
            p.Payment_ID,
            p.Payment_Date,
            p.Payment_Method,
            p.Payment_Status,
            o.Total_Amount
        FROM PAYMENT p
        JOIN ORDERS o
            ON p.Order_ID = o.Order_ID
        WHERE o.Customer_ID = p_customer_id
        ORDER BY p.Payment_Date;

    v_payment_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Payment History for Customer ID: ' || p_customer_id
    );

    FOR payment_record IN payment_cursor LOOP

        DBMS_OUTPUT.PUT_LINE(
            'Payment ID: ' || payment_record.Payment_ID ||
            ' | Date: ' ||
            TO_CHAR(payment_record.Payment_Date, 'DD-MON-YYYY') ||
            ' | Method: ' || payment_record.Payment_Method ||
            ' | Status: ' || payment_record.Payment_Status ||
            ' | Amount: RM' || payment_record.Total_Amount
        );

        v_payment_count := v_payment_count + 1;

    END LOOP;

    IF v_payment_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'No payment records found for this customer.'
        );
    END IF;
END;
/

/* Function 1 question:
   Create a function to count the number of completed payments for a specified payment method.
*/

CREATE OR REPLACE FUNCTION Count_Completed_Payments (
    p_payment_method IN VARCHAR2
)
RETURN NUMBER
IS
    v_payment_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_payment_count
    FROM PAYMENT
    WHERE Payment_Method = UPPER(p_payment_method)
    AND Payment_Status = 'Completed';

    RETURN v_payment_count;
END;
/

/* Function 2 question:
   Create a function to return the bank name of a specified FPX payment.
*/

CREATE OR REPLACE FUNCTION Get_Payment_Bank (
    p_payment_id IN NUMBER
)
RETURN VARCHAR2
IS
    v_bank_name VARCHAR2(100);
BEGIN
    SELECT Bank_Name
    INTO v_bank_name
    FROM BANKING_PAYMENT
    WHERE Payment_ID = p_payment_id;

    RETURN v_bank_name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Banking payment not found.';
END;
/