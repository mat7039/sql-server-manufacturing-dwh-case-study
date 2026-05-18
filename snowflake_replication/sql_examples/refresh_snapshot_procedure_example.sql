/*
Example: procedure-driven snapshot refresh
Purpose:
- centralize TRUNCATE + COPY logic
- keep local orchestration simple
*/

CREATE OR REPLACE PROCEDURE DWH_METRIXM.DWH.SP_REFRESH_DWH_SNAPSHOT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    v_sql STRING;
BEGIN
    FOR rec IN (
        SELECT column1 AS table_name
        FROM VALUES
            ('DATE_DIM'),
            ('CUSTOMER_DIM'),
            ('GOODS_ISSUE_FACT')
    )
    DO
        v_sql := 'TRUNCATE TABLE DWH_METRIXM.DWH.' || rec.table_name;
        EXECUTE IMMEDIATE v_sql;

        v_sql := 'COPY INTO DWH_METRIXM.DWH.' || rec.table_name ||
                 ' FROM @DWH_METRIXM.DWH.DWH_LOAD_STAGE/' || LOWER(rec.table_name) || '/' ||
                 ' PATTERN = ''.*' || LOWER(rec.table_name) || '\.csv''' ||
                 ' FORCE = TRUE ON_ERROR = ''ABORT_STATEMENT''';
        EXECUTE IMMEDIATE v_sql;
    END FOR;

    RETURN 'Snapshot refresh finished';
END;
$$;
