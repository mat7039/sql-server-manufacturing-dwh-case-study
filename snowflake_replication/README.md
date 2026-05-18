# Snowflake Replication

This is the second subproject in the larger manufacturing data platform case study.

Once the SQL Server warehouse was stable enough, the next step was not to rebuild everything in the cloud from scratch. The first useful step was much simpler: replicate the analytical layer into Snowflake in a way that was predictable, easy to test, and realistic to operate from an on-prem environment.

That is what this part covers.

## What I actually built

The replication approach is snapshot-based.

I export the current state of the on-prem DWH, upload it into a Snowflake internal stage, and then refresh replicated tables in Snowflake from those files.

At this stage I deliberately chose something practical over something flashy.

The pipeline has three steps:

1. export all `dwh.*` tables from SQL Server to CSV
2. upload the files into a Snowflake internal stage
3. refresh Snowflake tables through `TRUNCATE + COPY INTO`

In the working version, that is implemented as:
- a PowerShell exporter for all warehouse tables
- a Python uploader for the Snowflake stage
- a Snowflake stored procedure that refreshes the replicated tables
- and a local wrapper that chains the whole sequence together

## Why I chose snapshot replication first

The source warehouse itself was already built around full refresh patterns in several places. Because of that, jumping straight into CDC would have been misleading. It would look more advanced on paper, but it would not actually match the behavior of the source layer very well.

So I treated this as a first clean migration step:
- get the warehouse data into Snowflake reliably
- keep the logic easy to reason about
- validate row counts and behavior
- and only then think about whether a more incremental model is worth it

## High-level flow

```mermaid
flowchart LR
    A["SQL Server DWH"] --> B["CSV snapshot export"]
    B --> C["Local current folder"]
    C --> D["Snowflake internal stage"]
    D --> E["Stored procedure refresh"]
    E --> F["Snowflake replicated tables"]
```

## Main design decisions

### CSV instead of Parquet

I considered Parquet, but for the first working version CSV was the better fit.

Not because Parquet is worse, but because the real bottleneck here was not file format elegance. It was getting a stable and understandable pipeline in place from an on-prem SQL Server environment. CSV made that easier to explain, easier to inspect, and easier to automate quickly.

### One table, one file

Each table is exported to its own file and uploaded under its own stage prefix.

That keeps the automation simple:
- each table has one current snapshot file
- each stage prefix maps cleanly to one target table
- reruns are easier to reason about

### Stored procedure for refresh

Instead of spreading refresh logic across many separate commands, I wrapped the load into a Snowflake stored procedure that iterates through the replicated tables and runs:
- `TRUNCATE TABLE`
- `COPY INTO`

That made the orchestration a lot cleaner from the Windows side.

### Key-pair authentication

For the local automation I moved away from password-based login and switched to key-pair authentication for the technical Snowflake user.

This is still a lightweight setup, but it is much better than hardcoding or passing passwords around in scripts.

## What I tested

I did not stop at just defining the objects in Snowflake.

The flow was tested in pieces:
- export from SQL Server into CSV snapshots
- upload of current snapshots into Snowflake stage
- manual `COPY INTO` on sample tables
- full DDL generation for all warehouse tables
- refresh through a Snowflake procedure
- local authentication through key-pair auth for the technical loader user

That last part mattered more than it may sound. I did not want the whole pipeline to depend on a plaintext password sitting in a script just because it was the fastest way to make the first run work.

## What is in scope here

This subproject covers:
- export format and file layout
- stage design
- Snowflake DDL for replicated tables
- `COPY INTO` loading pattern
- refresh procedure
- local wrapper that ties export, upload, and refresh together

## Operational shape

The final local automation flow is intentionally simple:

1. generate a fresh SQL Server snapshot
2. upload that snapshot into Snowflake stage
3. call one refresh procedure in Snowflake

I preferred that over a more fragmented setup with many small moving parts. It is easier to reason about, easier to retry, and easier to explain.

## What is not in scope yet

A few things are intentionally not treated as "done" here:
- CDC
- infrastructure as code
- cloud-native orchestration
- monitoring beyond the basic operational checks needed for first runs

Those are all reasonable next steps, but I did not want to pretend they were already part of the first working version.

## Why this part matters in the overall project

This layer is what turns the warehouse from a single-environment solution into something portable.

The SQL Server DWH solved the modeling problem. The Snowflake replication starts solving the platform problem. That is why I see it as its own subproject rather than just a deployment detail.
