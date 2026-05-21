# Streamlit App

This is the third subproject in the larger manufacturing data platform case study.

Once the warehouse existed in SQL Server and the replicated layer was stable in Snowflake, the next step was simple to describe and much harder to get right: turn the model into something a non-technical stakeholder could actually use.

That is what this layer is about.

One of the reasons I went in this direction was practical, not just technical. I wanted the final analytical tool to live outside the VPN-bound SQL Server environment. Snowflake solved that part. Streamlit was the step that made the work visible.

## What I actually built

The current app runs inside Snowflake Streamlit and reads one prepared analytical source:
- `DWH_METRIXM.DWH.STREAMLITSOURCE`

The purpose of that source is to compare three perspectives of the same manufacturing case:
- `KALK`
- `TECHNOLOGIA`
- `RZECZYWISTE`

In practice, the app helps answer a few concrete questions:
- where actual time is drifting away from the quoted version
- where execution is heavier than the technological plan
- which clients and cases drive the biggest overrun
- which individual `ZS + indeks` combinations deserve a closer look

So this part is not meant to be a generic BI replacement. It is a focused diagnostic and analysis layer built on top of Snowflake.

## Why this part was harder than it looked

At first glance this looked like a UI task.

It turned out not to be one.

As soon as the app started showing comparisons side by side, it exposed problems that were still hidden in the reporting layer:
- `TECH` was joined too broadly in some cases
- `REG` was undercounting because it used the wrong join path
- some text keys behaved differently in Snowflake than in SQL Server because of trailing spaces
- some material prices were technically present in ERP, but not reliable enough to fully trust

That was an important lesson.

The Streamlit layer did not just visualize the model. It helped validate whether the model was actually believable.

## Main problems I ran into

### The first Streamlit impression looked too technical

The editor view in Snowflake shows code next to the app, which is fine for development and bad for a business audience.

The fix was simple once I understood the platform better:
- treat the developer/editor screen as a build environment
- treat the viewer URL as the real delivery channel
- force a wide layout so the app uses the full screen

### Cost and warehouse behavior mattered more than expected

One early version used cache TTL.

That looked harmless, but it kept the app active often enough to interfere with warehouse auto-suspend behavior. In practice, this was not just a coding detail. It was an operational cost issue.

The safer version was:
- load the dataset once
- cache it without TTL
- do the rest of the shaping in Python

That was only part of the solution, though.

I also decided to treat cost protection as part of the application design:
- use a dedicated `XS` warehouse for the app
- keep `AUTO_SUSPEND = 60`
- add `.streamlit/config.toml` with a short sleep timeout:

```toml
[snowflake]
[snowflake.sleep]
streamlitSleepTimeoutMinutes = 5
```

The goal was simple: if someone opened the app, left the browser tab open, and walked away for a few hours or overnight, the application should not quietly generate unnecessary Snowflake cost.

This was one of the most practical lessons in the whole project. In Snowflake Streamlit, idle behavior is not just an infrastructure setting. It is part of responsible app design.

### The app was only as good as the SQL underneath it

The biggest frontend lesson was that Streamlit would not rescue unstable semantics.

Before the UI could be trusted, I had to stabilize the Snowflake side:
- common scope across the three sources
- positional joins through production-order positions
- reporting filters for cooperation and paint-shop operations
- cleanup for text-key inconsistencies

That changed the role of this app. It became part of the validation process, not just the last presentation layer.

## How I approached the implementation

I deliberately kept the application SQL-first.

Snowflake owns the business grain and reporting semantics.
Python does only light shaping for presentation.

A small part of the current code shows that idea well:

```python
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
```

The point here is not the syntax itself. The point is the design choice:
- one prepared source in Snowflake
- one cached load into the app
- lightweight Python afterward

The second pattern that mattered was interactive drill-down without building a separate navigation system:

```python
event = st.dataframe(
    focus_df,
    use_container_width=True,
    hide_index=True,
    selection_mode="single-row",
    on_select="rerun",
)
```

That made it possible to keep the app simple while still supporting case-study style analysis inside the same screen.

## What I learned

A few things became very clear while building this layer:
- Streamlit in Snowflake can absolutely be business-facing, but only if you think in viewer mode, not editor mode.
- A visual app is a very effective way to expose hidden data-model problems.
- SQL-first architecture was the right choice here.
- Manual deployment was acceptable for the first working version.
- A simple app with clear semantics is more valuable than a prettier app with shaky logic.
- Cost optimization needs to be treated as part of the product, not as an afterthought.

I also learned that this layer adds value even when the numbers are uncomfortable. In a few cases, the app helped surface source-data issues rather than just present polished KPIs. That is a good outcome, not a failure.

## Current shape of the app

Right now the app is a solid MVP:
- it loads one Snowflake source
- it presents overview, trend, Pareto, and drill-down sections
- it supports case-based investigation
- it already works as both a reporting and validation tool

The main technical debt is that the code still lives in one larger `streamlit_app.py` file. That was reasonable for speed, but it is not where I would leave it long term.

## Next steps

The next sensible improvements are:
- split the app into smaller modules like `data.py`, `charts.py`, `sections.py`, and `app.py`
- clean up some text encoding and label issues
- move heavier filtering or aggregation back into Snowflake if the dataset grows
- keep refining the business logic as more case studies reveal edge cases

## Why this subproject matters

The SQL Server DWH solved the modeling problem.
The Snowflake layer solved the portability problem.
The Streamlit layer is where the platform had to prove that a real person could use it.

That is why I see it as a proper subproject, not just a visual extra at the end.
