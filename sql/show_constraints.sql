-- List constraints on the Part 2 tables (P=primary key, R=foreign key, U=unique, C=check / not null)
SET LINESIZE 150 PAGESIZE 100
COLUMN table_name      FORMAT A14
COLUMN constraint_name FORMAT A20
COLUMN type            FORMAT A4
COLUMN condition       FORMAT A35
COLUMN references      FORMAT A14
SELECT c.table_name, c.constraint_name, c.constraint_type AS type,
       c.search_condition_vc AS condition, r.table_name AS references
FROM   user_constraints c
LEFT   JOIN user_constraints r ON r.constraint_name = c.r_constraint_name
WHERE  c.table_name IN ('MYEMPLOYEE','MYDEPARTMENT','GENDER','UNIVERSITY','JOB')
ORDER  BY c.table_name, c.constraint_type, c.constraint_name;
