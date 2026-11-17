# SQL – theory notes

## SQL vs PL/SQL
- **SQL** is the language for talking to a relational database. It says *what* data you want
  (`SELECT ... WHERE ...`) and the database decides how to get it. One statement at a time.
- **PL/SQL** is Oracle's programming language wrapped around SQL. It adds variables, `IF`, loops,
  exceptions, and lets you save code in the database as **functions**, **procedures**, **packages**
  and **triggers**. Good for logic that would otherwise mean many round trips from an application.

## Kinds of SQL statements
| Group | Meaning | Examples |
|---|---|---|
| **DDL** – Data Definition | Create / change / remove objects. Auto-commits in Oracle. | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` |
| **DML** – Data Manipulation | Work with the rows inside tables. | `INSERT`, `UPDATE`, `DELETE`, `MERGE` (and `SELECT`, sometimes called DQL) |
| **DCL** – Data Control | Who may do what. | `GRANT`, `REVOKE` |
| **TCL** – Transaction Control | Finish or undo DML. | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

`DELETE` vs `TRUNCATE`: `DELETE` is DML, can have a `WHERE`, and can be rolled back. `TRUNCATE` is DDL,
removes all rows at once, is very fast, and cannot be rolled back.

## JOIN types
- **INNER JOIN** – only rows that match in both tables.
- **LEFT (OUTER) JOIN** – all rows from the left table, plus matches from the right (NULL if none).
  Used in Q2 so the president (no manager) and an employee with no university still show up.
- **RIGHT (OUTER) JOIN** – the mirror of LEFT.
- **FULL (OUTER) JOIN** – all rows from both sides, matched where possible.
- **CROSS JOIN** – every row × every row (Cartesian product).
- **SELF JOIN** – a table joined to itself, e.g. employee → manager in the same table (Q2).
- **NATURAL JOIN / USING** – join on columns that have the same name (handy, but fragile).
- Also: equi-join (`=`) vs non-equi-join (e.g. `BETWEEN` on salary grades).

## RDBMS vs NoSQL
- **RDBMS** (Oracle, PostgreSQL, MySQL, SQL Server): data lives in tables with a fixed schema, tables are
  linked by keys, you query with SQL, and you get **ACID** transactions (Atomic, Consistent, Isolated,
  Durable). Strong for money and records where correctness matters. Usually scales *up* (a bigger server).
- **NoSQL** ("not only SQL"): flexible or no schema, built to scale *out* over many servers. Main types:
  - document (MongoDB)
  - key-value (Redis)
  - wide-column (Cassandra)
  - graph (Neo4j)

  Often trades strict consistency for speed and availability ("eventual consistency"). Good for big,
  fast-changing or unstructured data such as caches, sessions, logs and catalogs.

## Aggregate functions
Work on a group of rows and return one value: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
(+ `LISTAGG`, `STDDEV`). Used with `GROUP BY`. `WHERE` filters rows **before** grouping; `HAVING`
filters groups **after** (Q3 uses both). `COUNT(*)` counts rows; `COUNT(col)` skips NULLs.

## Date functions (Oracle)
`SYSDATE`, `SYSTIMESTAMP`, `ADD_MONTHS(d, n)`, `MONTHS_BETWEEN(d1, d2)`, `LAST_DAY(d)`,
`NEXT_DAY(d, 'FRIDAY')`, `TRUNC(d)`, `EXTRACT(YEAR FROM d)`, `TO_CHAR(d, 'DD/MM/YYYY')`,
`TO_DATE('09/09/1987', 'DD/MM/YYYY')`. Subtracting two dates gives a number of days.

## String functions
`UPPER`, `LOWER`, `INITCAP`, `LENGTH`, `SUBSTR`, `INSTR`, `CONCAT` / `||`, `TRIM`, `LTRIM`, `RTRIM`,
`LPAD`, `RPAD`, `REPLACE`, `REGEXP_LIKE`, `REGEXP_REPLACE`. Null helpers: `NVL`, `NVL2`, `COALESCE`,
`NULLIF`, plus `DECODE` and `CASE`.

## Constraints
Rules the database enforces so bad data can't get in:
- **PRIMARY KEY** – unique and not null; identifies a row (one per table).
- **NOT NULL** – the column must have a value.
- **UNIQUE** – no duplicates (NULLs allowed).
- **FOREIGN KEY** – the value must exist in the parent table (e.g. `DEPT_ID` → `MyDepartment`).
- **CHECK** – a condition that must be true (e.g. `SALARY > 0`).

## Indexes
An index is a sorted structure (normally a B-tree) that lets the DB find rows without reading the whole
table – like the index at the back of a book.
- They speed up `WHERE` and `JOIN`, but slow down `INSERT`/`UPDATE`/`DELETE` a little and use disk space.
- PK and UNIQUE constraints create an index automatically. Foreign keys do **not**, so in the script
  I added indexes on `DEPT_ID`, `MANAGER_ID` and `JOB_ID`.
- Other types: bitmap (low-cardinality columns), function-based (`UPPER(name)`), composite (several columns).
