# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `sql_library`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `sql_library`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE sql_library;

USE sql_library;

CREATE TABLE books(isbn VARCHAR(20) PRIMARY KEY,
                    book_title VARCHAR(40),
                    category VARCHAR(25),
                    rental_price FLOAT,
                    status VARCHAR(15),
                    author VARCHAR(30),
                    publisher VARCHAR(40)
);

CREATE TABLE branch(
                        branch_id VARCHAR(20) PRIMARY KEY,
                        manager_id VARCHAR(20),
                        branch_address VARCHAR(40),
                        contact_no VARCHAR(20)
);

CREATE TABLE employees(
                        emp_id VARCHAR(20) PRIMARY KEY,
                        emp_name VARCHAR(30),
                        position VARCHAR(15),
                        salary FLOAT,
                        branch_id VARCHAR(15) -- FK
);


CREATE TABLE members(
                        member_id VARCHAR(20) PRIMARY KEY,
                        member_name	VARCHAR(30),
                        member_address VARCHAR(35),
                        reg_date DATE
);

CREATE TABLE issued_status(
                        issued_id VARCHAR(20) PRIMARY KEY,
                        issued_member_id VARCHAR(20), -- FK
                        issued_book_name VARCHAR(40),
                        issued_date DATE,	
                        issued_book_isbn VARCHAR(20), -- FK
                        issued_emp_id VARCHAR(20) -- FK
);

CREATE TABLE return_status(
                        return_id VARCHAR(20),
                        issued_id VARCHAR(20), -- FK		
                        return_book_name VARCHAR(40),
                        return_date DATE,
                        return_book_isbn VARCHAR(20) -- FK
);


-- ADD FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);


ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);


ALTER TABLE return_status
ADD CONSTRAINT fk_issued_stats
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


ALTER TABLE return_status
ADD CONSTRAINT fk_bookss
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);


SET FOREIGN_KEY_CHECKS = 0; 
TRUNCATE table return_status;
SET FOREIGN_KEY_CHECKS = 1;

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St' 
WHERE member_id='C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id, COUNT(issued_emp_id) FROM issued_status i
GROUP BY issued_emp_id
HAVING COUNT(issued_emp_id) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts AS
SELECT b.isbn, b.book_title, COUNT(st.issued_id) as no_issued FROM books b
JOIN issued_status st ON st.issued_book_isbn = b.isbn
GROUP BY 1,2;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'History';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price) as Total_Income, COUNT(*) FROM books b
JOIN issued_status st ON st.issued_book_isbn = b.isbn
GROUP BY 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e.emp_name, e.branch_id, b.manager_id, b.branch_address, em.emp_name as Manager FROM employees e
JOIN branch b ON e.branch_id = b.branch_id
JOIN employees em ON b.manager_id=em.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE book_over_5 AS
SELECT * FROM books
WHERE rental_price > 5;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

CREATE OR REPLACE PROCEDURE add_return_records(IN p_return_id VARCHAR(10),IN p_issued_id VARCHAR(10),IN p_book_quality VARCHAR(10))

DECLARE
            v_isbn VARCHAR(50);
            v_book_name VARCHAR(80);
    
BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    SELECT 'Inserted Successfully!' AS notice;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.

```sql

CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
SELECT issued_member_id from issued_status
WHERE issued_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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

-- Testing The function
CALL issue_book('IS14&', 'C108', '978-0-06-112008-4', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-06-112008-4'

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


1. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
2. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
3. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.
