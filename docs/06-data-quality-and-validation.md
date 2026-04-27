# Data Quality and Validation

The warehouse included a lightweight validator that checked:
- row counts
- missing required business keys
- invalid date ranges
- unexpected duplicates in selected staging objects

Validation results were persisted for audit and run diagnostics.

This helped catch:
- source structure changes
- extract regressions
- broken key logic before facts were loaded
