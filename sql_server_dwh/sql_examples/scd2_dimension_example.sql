/*
Example: forward-only SCD2 dimension load
Purpose:
- close previous active version when tracked attributes changed
- insert a new active version
*/

WITH current_source AS (
    SELECT
        material_number,
        material_name,
        default_supplier,
        lead_time_days
    FROM stg.material_src
),
active_target AS (
    SELECT
        material_sk,
        material_key,
        material_name,
        default_supplier,
        lead_time_days
    FROM dwh.material_dim
    WHERE is_active = 1
)
UPDATE d
SET
    d.valid_to = @as_of_dts,
    d.is_active = 0,
    d.updated_dts = sysdatetime()
FROM dwh.material_dim d
INNER JOIN active_target t
    ON t.material_sk = d.material_sk
INNER JOIN current_source s
    ON s.material_number = t.material_key
WHERE
    ISNULL(t.material_name, '') <> ISNULL(s.material_name, '')
    OR ISNULL(t.default_supplier, '') <> ISNULL(s.default_supplier, '')
    OR ISNULL(t.lead_time_days, -1) <> ISNULL(s.lead_time_days, -1);

INSERT INTO dwh.material_dim (
    material_key,
    material_name,
    default_supplier,
    lead_time_days,
    valid_from,
    valid_to,
    is_active,
    is_unknown
)
SELECT
    s.material_number,
    s.material_name,
    s.default_supplier,
    s.lead_time_days,
    @as_of_dts,
    CAST('9999-12-31' AS datetime2(0)),
    1,
    0
FROM current_source s
LEFT JOIN dwh.material_dim d
    ON d.material_key = s.material_number
   AND d.is_active = 1
WHERE d.material_sk IS NULL
   OR ISNULL(d.material_name, '') <> ISNULL(s.material_name, '')
   OR ISNULL(d.default_supplier, '') <> ISNULL(s.default_supplier, '')
   OR ISNULL(d.lead_time_days, -1) <> ISNULL(s.lead_time_days, -1);
