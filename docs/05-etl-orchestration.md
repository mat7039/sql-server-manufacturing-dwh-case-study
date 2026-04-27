# ETL Orchestration

The ETL process was orchestrated in SQL Server Agent.

High-level flow:
1. truncate staging
2. load staging
3. run lightweight validator
4. transform dimensions
5. transform facts

This was intentionally simple at first:
- one job
- one schedule
- easy to debug

The design left room for future separation by domain or refresh frequency.
