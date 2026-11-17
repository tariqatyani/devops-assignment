-- =====================================================================
--  Part 2 - SQL / PL-SQL on Oracle Database Free (23ai, Docker)
--  Run as the application user, e.g.:
--    docker exec -i ps-oracle sqlplus -s ps/<password>@FREEPDB1 < sql/ps_oracle.sql
--  Run 00_grants.sql once first (as SYSTEM).
--  The script is re-runnable: it drops its own objects first.
-- =====================================================================
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100
SET FEEDBACK ON
COLUMN employee_name   FORMAT A16
COLUMN department_name FORMAT A16
COLUMN manager_name    FORMAT A16
COLUMN gender          FORMAT A8
COLUMN university      FORMAT A45
COLUMN job_title       FORMAT A12
COLUMN ename           FORMAT A12

-- ---------------------------------------------------------------------
-- Clean-up (ignore "table/view does not exist" errors on first run)
-- ---------------------------------------------------------------------
BEGIN
  FOR o IN (SELECT object_name, object_type FROM user_objects
            WHERE object_name IN ('EMP','MYEMPLOYEE_UPDATE','MYEMPLOYEE','JOB',
                                  'MYDEPARTMENT','GENDER','UNIVERSITY',
                                  'F_HR_QUERY','P_COPY_EMPLOYEE')) LOOP
    IF o.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE ' || o.object_name || ' CASCADE CONSTRAINTS PURGE';
    ELSIF o.object_type IN ('VIEW','FUNCTION','PROCEDURE') THEN
      EXECUTE IMMEDIATE 'DROP ' || o.object_type || ' ' || o.object_name;
    END IF;
  END LOOP;
END;
/

-- =====================================================================
-- Q1: Tables with PK, NOT NULL, FK and CHECK constraints
--     Extra (allowed by the task): JOB table, MyEmployee.JOB_ID and
--     MyEmployee.MANAGER_ID - needed for Q2 (manager) and Q3 (job title).
-- =====================================================================
CREATE TABLE Gender (
  Gender_ID  NUMBER(2)     CONSTRAINT gender_pk PRIMARY KEY,
  Name       VARCHAR2(10)  CONSTRAINT gender_name_nn NOT NULL,
  CONSTRAINT gender_name_uk UNIQUE (Name),
  CONSTRAINT gender_name_ck CHECK (Name IN ('Male', 'Female'))
);

CREATE TABLE University (
  ID    NUMBER(4)      CONSTRAINT university_pk PRIMARY KEY,
  Name  VARCHAR2(100)  CONSTRAINT university_name_nn NOT NULL,
  CONSTRAINT university_name_uk UNIQUE (Name),
  CONSTRAINT university_id_ck   CHECK (ID > 0)
);

CREATE TABLE MyDepartment (
  Dept_ID  NUMBER(4)     CONSTRAINT mydept_pk PRIMARY KEY,
  Name     VARCHAR2(50)  CONSTRAINT mydept_name_nn NOT NULL,
  CONSTRAINT mydept_name_uk UNIQUE (Name),
  CONSTRAINT mydept_id_ck   CHECK (Dept_ID > 0)
);

CREATE TABLE Job (
  Job_ID     NUMBER(4)     CONSTRAINT job_pk PRIMARY KEY,
  Job_Title  VARCHAR2(50)  CONSTRAINT job_title_nn NOT NULL,
  CONSTRAINT job_title_uk UNIQUE (Job_Title),
  CONSTRAINT job_id_ck    CHECK (Job_ID > 0)
);

CREATE TABLE MyEmployee (
  ID             NUMBER(6)     CONSTRAINT myemp_pk PRIMARY KEY,
  LAST_NAME      VARCHAR2(50)  CONSTRAINT myemp_last_nn  NOT NULL,
  FIRST_NAME     VARCHAR2(50)  CONSTRAINT myemp_first_nn NOT NULL,
  HIRE_DATE      DATE          CONSTRAINT myemp_hire_nn  NOT NULL,
  USERID         NUMBER(6),
  SALARY         NUMBER(10,2)  CONSTRAINT myemp_sal_nn   NOT NULL,
  DEPT_ID        NUMBER(4)     CONSTRAINT myemp_dept_nn  NOT NULL,
  Gender_ID      NUMBER(2)     CONSTRAINT myemp_gender_nn NOT NULL,
  University_ID  NUMBER(4),                      -- optional: not everyone has a degree
  EMP_IMAGE      BLOB,
  JOB_ID         NUMBER(4)     CONSTRAINT myemp_job_nn   NOT NULL,   -- extra
  MANAGER_ID     NUMBER(6),                                          -- extra (NULL = top boss)
  CONSTRAINT myemp_userid_uk   UNIQUE (USERID),
  CONSTRAINT myemp_sal_ck      CHECK (SALARY > 0),
  CONSTRAINT myemp_mgr_ck      CHECK (MANAGER_ID <> ID),
  CONSTRAINT myemp_dept_fk     FOREIGN KEY (DEPT_ID)       REFERENCES MyDepartment (Dept_ID),
  CONSTRAINT myemp_gender_fk   FOREIGN KEY (Gender_ID)     REFERENCES Gender (Gender_ID),
  CONSTRAINT myemp_univ_fk     FOREIGN KEY (University_ID) REFERENCES University (ID),
  CONSTRAINT myemp_job_fk      FOREIGN KEY (JOB_ID)        REFERENCES Job (Job_ID),
  CONSTRAINT myemp_mgr_fk      FOREIGN KEY (MANAGER_ID)    REFERENCES MyEmployee (ID)
);

-- Indexes on foreign-key columns (Oracle does not create them automatically)
CREATE INDEX myemp_dept_ix ON MyEmployee (DEPT_ID);
CREATE INDEX myemp_mgr_ix  ON MyEmployee (MANAGER_ID);
CREATE INDEX myemp_job_ix  ON MyEmployee (JOB_ID);

-- ---------------------------------------------------------------------
-- Sample data
-- ---------------------------------------------------------------------
INSERT INTO Gender VALUES (1, 'Male');
INSERT INTO Gender VALUES (2, 'Female');

INSERT INTO University VALUES (1, 'University of Jordan');
INSERT INTO University VALUES (2, 'Jordan University of Science and Technology');
INSERT INTO University VALUES (3, 'Princess Sumaya University for Technology');
INSERT INTO University VALUES (4, 'Hashemite University');

INSERT INTO MyDepartment VALUES (10, 'Administration');
INSERT INTO MyDepartment VALUES (20, 'IT');
INSERT INTO MyDepartment VALUES (30, 'Sales');
INSERT INTO MyDepartment VALUES (40, 'HR');

INSERT INTO Job VALUES (1, 'President');
INSERT INTO Job VALUES (2, 'Manager');
INSERT INTO Job VALUES (3, 'Analyst');
INSERT INTO Job VALUES (4, 'Clerk');
INSERT INTO Job VALUES (5, 'Salesman');

-- Columns: ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY, DEPT_ID,
--          Gender_ID, University_ID, EMP_IMAGE, JOB_ID, MANAGER_ID
-- Managers are inserted before the people who report to them (self-FK).
INSERT INTO MyEmployee VALUES (1,  'Khalil',  'Ahmad',  DATE '1980-10-10', 1001, 5000, 10, 1, 1,    NULL, 1, NULL);
INSERT INTO MyEmployee VALUES (2,  'Haddad',  'Rami',   DATE '1986-05-24', 1002, 3000, 20, 1, 2,    NULL, 2, 1);
INSERT INTO MyEmployee VALUES (3,  'Tiger',   'SCOTT',  DATE '1987-09-09', 1003, 3000, 20, 1, 3,    NULL, 3, 2);
INSERT INTO MyEmployee VALUES (4,  'Nasser',  'Sara',   DATE '1990-03-15', 1004, 2800, 20, 2, 1,    NULL, 3, 2);
INSERT INTO MyEmployee VALUES (5,  'Yousef',  'Lina',   DATE '2001-02-20', 1005, 2850, 30, 2, 4,    NULL, 2, 1);
INSERT INTO MyEmployee VALUES (6,  'Saleh',   'Omar',   DATE '1995-07-01', 1006, 1600, 30, 1, 2,    NULL, 5, 5);
INSERT INTO MyEmployee VALUES (7,  'Odeh',    'Khaled', DATE '2010-01-10', 1007, 1250, 30, 1, 3,    NULL, 5, 5);
INSERT INTO MyEmployee VALUES (8,  'Ali',     'Huda',   DATE '2015-11-01', 1008, 1100, 40, 2, 1,    NULL, 4, 2);
INSERT INTO MyEmployee VALUES (9,  'Fares',   'Yazan',  DATE '2020-06-12', 1009,  950, 10, 1, NULL, NULL, 4, 1);
COMMIT;

-- Show that the constraints really work (each statement must FAIL):
PROMPT
PROMPT === Constraint tests (all 4 inserts below are expected to fail) ===
-- (comments go on their own line: SQL*Plus ignores a ';' followed by a comment)
PROMPT -- CHECK: negative salary
INSERT INTO MyEmployee (ID, LAST_NAME, FIRST_NAME, HIRE_DATE, SALARY, DEPT_ID, Gender_ID, JOB_ID)
  VALUES (99, 'Test', 'Neg', SYSDATE, -5, 10, 1, 4);
PROMPT -- FOREIGN KEY: department 77 does not exist
INSERT INTO MyEmployee (ID, LAST_NAME, FIRST_NAME, HIRE_DATE, SALARY, DEPT_ID, Gender_ID, JOB_ID)
  VALUES (99, 'Test', 'NoDept', SYSDATE, 500, 77, 1, 4);
PROMPT -- PRIMARY KEY: ID 1 already exists
INSERT INTO MyEmployee (ID, LAST_NAME, FIRST_NAME, HIRE_DATE, SALARY, DEPT_ID, Gender_ID, JOB_ID)
  VALUES (1, 'Test', 'DupId', SYSDATE, 500, 10, 1, 4);
PROMPT -- NOT NULL: gender without a name
INSERT INTO Gender VALUES (3, NULL);

-- =====================================================================
-- Q2: Employee name, salary, department, manager, gender, university
--     LEFT JOINs keep employees without a manager / university.
-- =====================================================================
PROMPT
PROMPT === Q2 ===
SELECT e.FIRST_NAME || ' ' || e.LAST_NAME AS employee_name,
       e.SALARY,
       d.Name                             AS department_name,
       m.FIRST_NAME || ' ' || m.LAST_NAME AS manager_name,
       g.Name                             AS gender,
       u.Name                             AS university
FROM        MyEmployee   e
JOIN        MyDepartment d ON d.Dept_ID   = e.DEPT_ID
JOIN        Gender       g ON g.Gender_ID = e.Gender_ID
LEFT JOIN   MyEmployee   m ON m.ID        = e.MANAGER_ID
LEFT JOIN   University   u ON u.ID        = e.University_ID
ORDER BY e.ID;

-- =====================================================================
-- Q3: Total monthly salary per job title, only where the total > 2500,
--     excluding sales employees (WHERE filters rows, HAVING filters groups).
-- =====================================================================
PROMPT
PROMPT === Q3 ===
SELECT j.Job_Title     AS job_title,
       SUM(e.SALARY)   AS total_monthly_salary
FROM   MyEmployee e
JOIN   Job        j ON j.Job_ID = e.JOB_ID
WHERE  UPPER(j.Job_Title) NOT LIKE '%SALES%'
GROUP  BY j.Job_Title
HAVING SUM(e.SALARY) > 2500
ORDER  BY total_monthly_salary DESC;

-- =====================================================================
-- Q4: The given SELECT on the SCOTT EMP table (annual salary per employee)
--     has four errors:
--       1. The SCOTT EMP table has no column "salary" - it is SAL.
--       2. "x" is not an operator in SQL - multiplication is "*".
--       3. An alias that contains a space must be in double quotes:
--          "ANNUAL SALARY" (or use one word, e.g. ANNUAL_SALARY).
--       4. The ";" before FROM ends the statement too early - there must
--          be only one ";", at the very end.
--     Corrected:
--        SELECT empno, ename, sal * 12 "ANNUAL SALARY" FROM emp;
--     To run it here, EMP is a small SCOTT-style view on MyEmployee.
-- =====================================================================
CREATE VIEW emp AS
  SELECT ID AS empno, UPPER(FIRST_NAME) AS ename, SALARY AS sal FROM MyEmployee;

PROMPT
PROMPT === Q4 (corrected statement) ===
SELECT empno, ename, sal * 12 "ANNUAL SALARY" FROM emp;

-- =====================================================================
-- Q5: F_HR_QUERY - name and hire date of everyone hired after SCOTT.
--     A function returns one value, so it returns a SYS_REFCURSOR
--     (a pointer to a result set). The name defaults to SCOTT.
-- =====================================================================
CREATE OR REPLACE FUNCTION F_HR_QUERY (p_name IN VARCHAR2 DEFAULT 'SCOTT')
  RETURN SYS_REFCURSOR
IS
  v_hire_date  MyEmployee.HIRE_DATE%TYPE;
  v_result     SYS_REFCURSOR;
BEGIN
  SELECT HIRE_DATE INTO v_hire_date
  FROM   MyEmployee
  WHERE  UPPER(FIRST_NAME) = UPPER(p_name);

  OPEN v_result FOR
    SELECT FIRST_NAME || ' ' || LAST_NAME AS employee_name,
           TO_CHAR(HIRE_DATE, 'DD/MM/YYYY') AS hired_on
    FROM   MyEmployee
    WHERE  HIRE_DATE > v_hire_date
    ORDER  BY MyEmployee.HIRE_DATE;   -- sort by the real DATE, not the text
  RETURN v_result;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ' || p_name || ' not found');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20002, 'More than one employee called ' || p_name);
END F_HR_QUERY;
/
SHOW ERRORS FUNCTION F_HR_QUERY

PROMPT
PROMPT === Q5: employees hired after SCOTT (09/09/1987) ===
VARIABLE rc REFCURSOR
EXEC :rc := F_HR_QUERY('SCOTT');
PRINT rc

-- =====================================================================
-- Q6: P_COPY_EMPLOYEE - copy all MyEmployee rows into MyEmployee_update.
--     First run: creates the table (CREATE TABLE ... AS SELECT).
--     Later runs: empties it and copies again, so it never fails with
--     "name is already used" and never duplicates rows.
--     Dynamic SQL is needed because the table may not exist at compile time.
--     Needs a DIRECT "GRANT CREATE TABLE" (see 00_grants.sql): privileges that
--     come from a role (RESOURCE) are switched off inside a stored procedure.
-- =====================================================================
CREATE OR REPLACE PROCEDURE P_COPY_EMPLOYEE
IS
  v_count  NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'MYEMPLOYEE_UPDATE';

  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE MyEmployee_update AS SELECT * FROM MyEmployee';
    DBMS_OUTPUT.PUT_LINE('Table MyEmployee_update created.');
  ELSE
    EXECUTE IMMEDIATE 'TRUNCATE TABLE MyEmployee_update';
    EXECUTE IMMEDIATE 'INSERT INTO MyEmployee_update SELECT * FROM MyEmployee';
    DBMS_OUTPUT.PUT_LINE('Table MyEmployee_update refreshed.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM MyEmployee_update' INTO v_count;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE(v_count || ' rows copied from MyEmployee.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('P_COPY_EMPLOYEE failed: ' || SQLERRM);
    RAISE;
END P_COPY_EMPLOYEE;
/
SHOW ERRORS PROCEDURE P_COPY_EMPLOYEE

PROMPT
PROMPT === Q6: run twice (create, then refresh) ===
EXEC P_COPY_EMPLOYEE
EXEC P_COPY_EMPLOYEE

COLUMN first_name FORMAT A10
COLUMN last_name  FORMAT A10
SELECT ID, FIRST_NAME, LAST_NAME, TO_CHAR(HIRE_DATE, 'DD/MM/YYYY') AS hire_date, SALARY
FROM   MyEmployee_update ORDER BY ID;
