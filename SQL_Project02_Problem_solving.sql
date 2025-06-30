-- Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

SELECT * FROM books;

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


-- Update an Existing Member's Adress

SELECT * FROM members;

UPDATE members
SET member_address = '125 Main St' 
WHERE member_id='C101'; -- If we don't specify position where we want to change, it will change the data of whole column.


-- Delete a Record from the issued Status Table
-- Objective: Delete the rocord with issued_id = 'IS014' form the issued table

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- Retrieve All Books issued by Specific Employee
-- Objektive Select all books issued by the employee with emp_id='E101'

SELECT * FROM issued_status
WHERE issued_emp_id='E101';

SELECT * FROM issued_status
WHERE issued_emp_id='E104';


-- List Members Who have issued more than one book
-- Objective: Use Group by to find members who have issued more than one book.

SELECT issued_emp_id, COUNT(issued_emp_id) FROM issued_status i
GROUP BY issued_emp_id
HAVING COUNT(issued_emp_id) > 1;


-- Create summary tables: Used CTAS to generate new tables based on query results
-- each book and total_book_issued_cnt

CREATE TABLE book_cnts AS
SELECT b.isbn, b.book_title, COUNT(st.issued_id) as no_issued FROM books b
JOIN issued_status st ON st.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_cnts;


-- Retrive all books in a specific Category:

SELECT * FROM books
WHERE category='History';


-- find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price) as Total_Income, COUNT(*) FROM books b
JOIN issued_status st ON st.issued_book_isbn = b.isbn
GROUP BY 1;


-- List Members who Registered in the last 180 days
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - 180;


-- List Employees with their Branch Manager's name and their Branch details:
select * from employees;

SELECT e.emp_name, e.branch_id, b.manager_id, b.branch_address, em.emp_name as Manager FROM employees e
JOIN branch b ON e.branch_id = b.branch_id
JOIN employees em ON b.manager_id=em.emp_id;


-- Create table of books with Rental price above a certain Threshold
CREATE TABLE book_over_5 AS
SELECT * FROM books
WHERE rental_price > 5;

SELECT * FROM book_over_5;


-- Retrieve the List of Books Not yet Returned
SELECT * FROM return_status;
SELECT * FROM issued_status;

SELECT * FROM issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;


-- Advance SQL
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
select * from members;

SELECT m.member_id, m.member_name, ist.issued_book_name, ist.issued_date, rs.return_date, CURRENT_DATE - ist.issued_date as Overdue FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books b ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL;


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
SELECT * FROM issued_status;
SELECT * FROM return_status;

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'No'
WHERE isbn= '978-0-451-52994-2';

-- Manually adding return details:
INSERT INTO return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn)
VALUES('RS119', 'IS130', NULL, CURRENT_DATE(), NULL);

UPDATE books
SET status = 'NO'
WHERE isbn= '978-0-451-52994-2';

-- Store Procedures:
DROP PROCEDURE IF EXISTS add_return_records;

DELIMITER $$
CREATE PROCEDURE add_return_records(IN p_return_id VARCHAR(15), IN p_issued_id VARCHAR(15))

BEGIN
    DECLARE v_isbn VARCHAR(20) default 0;
    DECLARE v_book_name VARCHAR(50) default NULL;
    
-- Inserting into returns based on user input
	INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES (p_return_id, p_issued_id, CURRENT_DATE);


	SELECT issued_book_isbn, issued_book_name  INTO v_isbn, v_book_name FROM issued_status
    WHERE issued_id = issued_id;

    
	UPDATE books
    SET status='Yes'
    WHERE isbn= v_isbn;
    
END$$
DELIMITER ;

SELECT * FROM issued_status;

CALL add_return_records('RS119', 'IS130');


/*
Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of book issued,
the number of books returned, and total revenue generated from book rentals.
*/


SELECT * FROM branch;
SELECT * FROM issued_status;
SELECT * FROM employees;
SELECT * FROM books;
SELECT * FROM return_status;

CREATE TABLE branch_reports
AS
SELECT b.branch_id, b.manager_id, SUM(s.rental_price) as Total_Revenue,
COUNT(ist.issued_id) as Number_Book_Issued,
COUNT(rs.return_id) as Number_Book_Return FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books s ON ist.issued_book_isbn = s.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;




-- Create a Table of Active Members
-- Use the CREATE TABLE AS statement to create a new table active_members containing numbers who have issued
-- at least one book in the last 6 months

SELECT * FROM issued_status;

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES('IS141', 'C11', 'The Great Gatsby', '2025-03-15', '978-0-553-29698-2', 'E106');


CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
SELECT issued_member_id from issued_status
WHERE issued_date >= DATE_SUB(CURDATE(), INTERVAL 45 MONTH)
);

SELECT * FROM active_members;



-- Find Employees with the Most Book issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name,
-- number of books processed, and their branch.

SELECT * FROM issued_status;
SELECT * FROM employees;


SELECT ist.issued_emp_id, e.emp_name, e.branch_id, COUNT(ist.issued_id) AS No_of_Issues FROM issued_status ist
JOIN employees e ON ist.issued_emp_id = e.emp_id
GROUP BY 1;



/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued,
and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
the procedure should return an error message indicating that the book is currently not available.

*/

DROP PROCEDURE IF EXISTS issue_book;

DELIMITER $$
CREATE PROCEDURE issue_book(IN p_issued_id VARCHAR(20),
                            IN p_issued_member_id VARCHAR(20),	
                            IN p_issued_book_isbn VARCHAR(20),
                            IN p_issued_emp_id VARCHAR(20)
)
BEGIN
DECLARE v_status VARCHAR(15);
 
	SELECT status INTO v_status FROM books
    WHERE isbn = p_issued_book_isbn;
    
    IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
        
        SELECT 'Insert successful' AS notice;
        
    ELSE
	SELECT 'FAILED, Unavailable Book' AS notice;
    
    END IF;


END $$
DELIMITER ;


SELECT * FROM books;
SELECT * FROM issued_status
WHERE issued_id = 'IS145';

DELETE FROM issued_status
WHERE issued_id = 'IS145';

-- 978-0-06-112008-4 -- YES
-- 978-0-307-58837-1 -- NO
CALL issue_book('IS14&', 'C108', '978-0-307-58837-1', 'E104');