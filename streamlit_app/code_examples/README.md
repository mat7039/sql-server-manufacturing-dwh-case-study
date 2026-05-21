# Code Examples

This folder keeps a few short snippets from the working Snowflake Streamlit app.

I moved them here on purpose. In the main `README.md` I wanted to explain the project like a person, not turn it into a wall of implementation details.

These are not full application files. They are trimmed excerpts that show a few decisions that mattered in practice:
- reading one prepared source from Snowflake instead of scattering business logic across the UI
- using inline drill-down inside the same page instead of building heavy navigation
- treating cost protection as part of the application design

Files in this folder:
- [`01_sql_first_data_load.py`](./01_sql_first_data_load.py)
- [`02_inline_case_selection.py`](./02_inline_case_selection.py)
- [`03_cost_safe_streamlit_config.toml`](./03_cost_safe_streamlit_config.toml)
