/*
Example: manual business mapping lookup
Purpose:
- classify Monaco workcenters into reporting columns s_*
- prefer the most specific rule by priority
*/

SELECT
    prod.sales_order_sk,
    prod.main_item_sk,
    map.target_column,
    SUM(prod.planned_qty * prod.unit_minutes + prod.setup_minutes) AS planned_minutes
FROM dwh.prod_order_routing_fact prod
LEFT JOIN dwh.machine_dim mach
    ON mach.machine_sk = prod.machine_sk
OUTER APPLY (
    SELECT TOP (1)
        m.target_column
    FROM dwh.workcenter_column_map m
    WHERE m.source_system = 'Monaco_Metrix'
      AND m.source_context = 'wz_technologia'
      AND m.is_active = 1
      AND m.source_name = mach.workcenter_name
      AND (
            m.machine_name_like IS NULL
            OR mach.machine_name LIKE m.machine_name_like
      )
    ORDER BY
        m.match_priority ASC,
        CASE WHEN m.machine_name_like IS NOT NULL THEN 0 ELSE 1 END
) map
WHERE prod.sales_order_sk <> 0
  AND map.target_column IS NOT NULL
GROUP BY
    prod.sales_order_sk,
    prod.main_item_sk,
    map.target_column;
