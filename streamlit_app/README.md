# Streamlit App

This is the planned third subproject in the larger manufacturing data platform case study.

The SQL Server warehouse organizes the data. The Snowflake replication makes that analytical layer easier to reuse. The Streamlit application is meant to be the point where the work becomes directly visible to end users.

I have not documented the full application implementation here yet, because this part is still the next step rather than finished work.

What I want this layer to do is fairly straightforward:
- sit directly on top of Snowflake
- make a few high-value analytical flows easier to use
- reduce the need to jump between raw tables and ad hoc SQL

In other words, this is the product-facing part of the same overall project.

When this section is expanded, it will focus on:
- app structure
- how data is queried from Snowflake
- how the UI supports actual analysis instead of just showing charts
- and what changed once the data platform work met real business use
