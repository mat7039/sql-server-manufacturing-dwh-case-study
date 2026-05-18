/*
Example: refresh one replicated table from stage
Purpose:
- keep one current CSV per table under its own stage prefix
- force reload of the latest snapshot file
*/

TRUNCATE TABLE DWH_METRIXM.DWH.CUSTOMER_DIM;

COPY INTO DWH_METRIXM.DWH.CUSTOMER_DIM
FROM @DWH_METRIXM.DWH.DWH_LOAD_STAGE/customer_dim/
PATTERN = '.*customer_dim\.csv'
FORCE = TRUE
ON_ERROR = 'ABORT_STATEMENT';
