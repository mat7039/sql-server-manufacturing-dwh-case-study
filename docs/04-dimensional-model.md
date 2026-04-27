# Dimensional Model

The model used a Kimball-style approach:
- conformed dimensions
- role-playing date keys
- surrogate keys in `dwh`
- unknown rows for resilient fact loading

Examples of dimensions used in the project:
- date
- customer
- production order
- machine
- material
- sales order
- work instruction
- item

Examples of facts:
- offers
- sales orders
- goods issue
- goods receipt
- material consumption
- production routing plan
- production routing registrations
