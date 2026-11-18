# SQL notes

Notes for the SQL reading questions. The answers to Q1 to Q6 are in `sql/ps_oracle.sql`.

## SQL, PL/SQL and the types of statements

SQL is the language used to work with a relational database. You say what data you want, and the database decides how to get it. PL/SQL is Oracle's programming language around SQL. It adds variables, IF, loops and exception handling, and lets you store code in the database as functions, procedures, packages and triggers.

| Type | Purpose | Examples |
|---|---|---|
| DDL (Data Definition) | Create, change or remove objects | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DML (Data Manipulation) | Work with the rows | `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `SELECT` |
| DCL (Data Control) | Give or remove permissions | `GRANT`, `REVOKE` |
| TCL (Transaction Control) | Save or undo DML changes | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

`DELETE` is DML: it can have a WHERE and can be rolled back. `TRUNCATE` is DDL: it removes all rows at once and cannot be rolled back.

## Types of JOINs

- **INNER JOIN:** only rows that match in both tables.
- **LEFT OUTER JOIN:** all rows from the left table, plus the matching rows from the right (NULL when there is no match).
- **RIGHT OUTER JOIN:** the opposite of LEFT.
- **FULL OUTER JOIN:** all rows from both tables.
- **CROSS JOIN:** every row combined with every row.
- **SELF JOIN:** a table joined to itself. I used it in Q2 to get each employee's manager.
- **NATURAL JOIN / USING:** joins on columns with the same name.

## RDBMS and NoSQL, functions, constraints and indexes

**RDBMS** (Oracle, PostgreSQL, MySQL, SQL Server) stores data in tables with a fixed structure, linked by keys, and supports ACID transactions (Atomic, Consistent, Isolated, Durable). It fits banking and payment data, where correctness matters most.

**NoSQL** databases have a flexible structure and are built to scale over many servers. The main types are document (MongoDB), key-value (Redis), wide-column (Cassandra) and graph (Neo4j). They often accept "eventual consistency" in exchange for speed, so they fit things like caches, sessions and logs.

**Aggregation functions:** `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, used with `GROUP BY`. `WHERE` filters rows before grouping, and `HAVING` filters the groups after (Q3 uses both).

**Date functions (Oracle):** `SYSDATE`, `ADD_MONTHS`, `MONTHS_BETWEEN`, `LAST_DAY`, `NEXT_DAY`, `TRUNC`, `EXTRACT(YEAR FROM d)`, `TO_CHAR(d, 'DD/MM/YYYY')`, `TO_DATE`.

**String functions:** `UPPER`, `LOWER`, `INITCAP`, `LENGTH`, `SUBSTR`, `INSTR`, `||` or `CONCAT`, `TRIM`, `LPAD`, `RPAD`, `REPLACE`, and for NULLs `NVL`, `NVL2`, `COALESCE`.

**Constraints** stop bad data from getting in:

- PRIMARY KEY: unique and not null, one per table
- NOT NULL: the column must have a value
- UNIQUE: no duplicates
- FOREIGN KEY: the value must exist in the parent table
- CHECK: a condition that must be true, for example `SALARY > 0`

**Indexes** are sorted structures (usually B-tree) that let the database find rows without reading the whole table. They make SELECT and JOIN faster but make INSERT and UPDATE a bit slower. Oracle creates an index for every primary key and unique constraint, but not for foreign keys, so I added indexes on `DEPT_ID`, `MANAGER_ID` and `JOB_ID`.
