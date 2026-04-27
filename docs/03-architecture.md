# Architecture

The warehouse followed a simple but production-friendly structure:

- `stg`
  - source-aligned extracts
  - minimal business reshaping
  - data quality validation point

- `dwh`
  - conformed dimensions
  - fact tables with surrogate keys
  - explicit SCD decisions

- orchestration
  - SQL Agent job
  - extract
  - validate
  - transform dimensions
  - transform facts

This separation made debugging and model evolution much easier.
