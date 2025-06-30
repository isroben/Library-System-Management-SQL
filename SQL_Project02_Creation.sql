CREATE DATABASE sql_library;
DROP DATABASE sql_project02;

USE sql_library;
DROP TABLE IF EXISTS books;

CREATE TABLE books(
					isbn VARCHAR(20) PRIMARY KEY,
                    book_title VARCHAR(40),
                    category VARCHAR(25),
                    rental_price FLOAT,
                    status VARCHAR(15),
                    author VARCHAR(30),
                    publisher VARCHAR(40)
);
-- ALTER TABLE books
-- ALTER COLUMN book_title TYPE VARCHAR(75);

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

DROP TABLE IF EXISTS members;

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

SELECT * FROM books;


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
