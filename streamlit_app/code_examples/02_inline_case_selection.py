st.caption("Select a row to open a case-study view for the chosen item.")
selection = st.dataframe(
    client_detail,
    use_container_width=True,
    hide_index=True,
    selection_mode="single-row",
    on_select="rerun",
    key="risk_drill_table",
)

selected_rows = selection.selection.rows if selection.selection.rows else []
if selected_rows:
    row_idx = selected_rows[0]
    zs = client_detail.iloc[row_idx]["ZS"]
    indeks = client_detail.iloc[row_idx]["indeks"]
    scope_key = f"{zs} | {indeks}"
    st.divider()
    _render_case_study_content(df, scope_key)
