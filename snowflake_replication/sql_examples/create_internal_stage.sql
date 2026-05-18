/*
Example: internal stage for replicated DWH snapshots
Purpose:
- keep one stage for the replicated warehouse
- inherit CSV settings directly from the stage
*/

CREATE OR REPLACE STAGE DWH_METRIXM.DWH.DWH_LOAD_STAGE
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        RECORD_DELIMITER = '\n'
        SKIP_HEADER = 0
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        NULL_IF = ('NULL', 'null', '')
        EMPTY_FIELD_AS_NULL = TRUE
        ENCODING = 'UTF8'
        TRIM_SPACE = TRUE
        DATE_FORMAT = 'AUTO'
        TIMESTAMP_FORMAT = 'AUTO'
    );
