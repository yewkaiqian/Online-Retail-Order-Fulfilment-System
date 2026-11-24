/* ============================================================
    INDIVIDUAL ASSIGNMENT SUBMISSION

    STUDENT NAME : Yew Kai Qian
    STUDENT ID : 2402661
    GROUP NUMBER : G010
    PROGRAMME : BS
    Submission date and time: 28 - 08 -2026
   ============================================================ */


/* Query 1 question:
   Display all shipments together with the employee assigned to handle each shipment.
*/

SELECT
    s.Shipment_ID,
    s.Order_ID,
    s.Shipment_Date,
    s.Shipment_Status,
    e.Employee_ID,
    e.Emp_First_Name || ' ' || e.Emp_Last_Name AS Employee_Name
FROM SHIPMENT s
JOIN EMPLOYEE e
    ON s.Employee_ID = e.Employee_ID
ORDER BY s.Shipment_ID;


/* Query 2 question:
   Display all standard delivery shipments together with
   their courier company, tracking number and estimated
   delivery days.
*/

SELECT
    s.Shipment_ID,
    s.Order_ID,
    s.Shipment_Date,
    s.Shipment_Status,
    s.Delivery_Mode,
    sd.Courier_Company,
    sd.Tracking_Number,
    sd.Estimated_Days
FROM SHIPMENT s
JOIN STANDARD_DELIVERY sd
    ON s.Shipment_ID = sd.Shipment_ID
ORDER BY s.Shipment_ID;


/* Stored procedure 1 question:
   Create a procedure to update the shipment status of
   a specified shipment.
*/

CREATE OR REPLACE PROCEDURE Update_Shipment_Status (
    p_shipment_id IN NUMBER,
    p_new_status  IN VARCHAR2
)
IS
BEGIN
    UPDATE SHIPMENT
    SET Shipment_Status = p_new_status
    WHERE Shipment_ID = p_shipment_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Shipment ID does not exist.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Shipment status updated successfully.');
        COMMIT;
    END IF;
END;
/


/* Stored procedure 2 question:
   Create a procedure to assign an employee to
   a specified shipment.
*/

CREATE OR REPLACE PROCEDURE Assign_Employee_To_Shipment (
    p_shipment_id IN NUMBER,
    p_employee_id IN NUMBER
)
IS
    v_employee_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_employee_count
    FROM EMPLOYEE
    WHERE Employee_ID = p_employee_id;

    IF v_employee_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID does not exist.');
    ELSE
        UPDATE SHIPMENT
        SET Employee_ID = p_employee_id
        WHERE Shipment_ID = p_shipment_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Shipment ID does not exist.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Employee assigned successfully.');
            COMMIT;
        END IF;
    END IF;
END;
/


/* Function 1 question:
   Create a function to calculate the estimated delivery
   date for a standard delivery shipment.
*/

CREATE OR REPLACE FUNCTION Get_Estimated_Delivery_Date (
    p_shipment_id IN NUMBER
)
RETURN DATE
IS
    v_shipment_date  DATE;
    v_estimated_days NUMBER;
BEGIN
    SELECT s.Shipment_Date,
           sd.Estimated_Days
    INTO v_shipment_date,
         v_estimated_days
    FROM SHIPMENT s
    JOIN STANDARD_DELIVERY sd
        ON s.Shipment_ID = sd.Shipment_ID
    WHERE s.Shipment_ID = p_shipment_id;

    RETURN v_shipment_date + v_estimated_days;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/


/* Function 2 question:
   Create a function to count the number of shipments
   handled by a specified employee.
*/

CREATE OR REPLACE FUNCTION Count_Employee_Shipments (
    p_employee_id IN NUMBER
)
RETURN NUMBER
IS
    v_shipment_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_shipment_count
    FROM SHIPMENT
    WHERE Employee_ID = p_employee_id;

    RETURN v_shipment_count;
END;
/