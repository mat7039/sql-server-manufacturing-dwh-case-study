/*
Example: fact load with historical dimension lookup
Purpose:
- load a transactional fact
- resolve surrogate keys using business date in a valid_from/valid_to range
*/

INSERT INTO dwh.goods_issue_fact (
    sales_order_sk,
    item_sk,
    issue_date_sk,
    sales_order_number,
    item_number,
    issue_qty,
    issue_value_pln
)
SELECT
    COALESCE(so.sales_order_sk, 0) AS sales_order_sk,
    COALESCE(i.item_sk, 0) AS item_sk,
    COALESCE(dd.date_sk, 0) AS issue_date_sk,
    s.sales_order_number,
    s.item_number,
    s.issue_qty,
    s.issue_value_pln
FROM stg.goods_issue_fact_src s
LEFT JOIN dwh.date_dim dd
    ON dd.[date] = s.issue_date
LEFT JOIN dwh.sales_order_dim so
    ON so.sales_order_key = s.sales_order_number
   AND so.is_active = 1
LEFT JOIN dwh.items_dim i
    ON i.item_number = s.item_number
   AND CAST(s.issue_date AS datetime2(0)) >= i.valid_from
   AND CAST(s.issue_date AS datetime2(0)) < i.valid_to;
