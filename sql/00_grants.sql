-- Run once as SYSTEM in the pluggable DB:
--   docker exec -i ps-oracle sqlplus -s system/<password>@FREEPDB1 < sql/00_grants.sql
-- PS already has CONNECT + RESOURCE (roles). A stored procedure runs with the
-- owner's DIRECT privileges only (roles are disabled), so P_COPY_EMPLOYEE needs
-- CREATE TABLE granted directly to create MyEmployee_update.
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO ps;
SELECT privilege FROM dba_sys_privs WHERE grantee = 'PS' ORDER BY privilege;
