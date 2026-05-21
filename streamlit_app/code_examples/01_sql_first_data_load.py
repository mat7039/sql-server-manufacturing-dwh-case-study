import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(
    page_title="MM - Controlling",
    layout="wide",
    initial_sidebar_state="collapsed",
)


@st.cache_data(show_spinner=False)
def load_source_data() -> pd.DataFrame:
    session = get_active_session()
    return _prepare_dataframe(
        session.sql("SELECT * FROM DWH_METRIXM.DWH.STREAMLITSOURCE").to_pandas()
    )
