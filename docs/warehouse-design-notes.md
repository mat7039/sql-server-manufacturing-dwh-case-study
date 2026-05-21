# Warehouse Design Notes

This note is here for the person who wants a bit more context than the main README gives, but not a mini book.

The public version of this project started as a SQL Server warehouse case study. Later it grew into a bigger story with Snowflake replication and a Streamlit layer, but the warehouse was still the part everything else depended on. If the model was weak, the cloud layer would only move weak logic somewhere else. If the grain was wrong, the application would only visualize the wrong answer faster.

That is why this part mattered so much.

## What problem I was really solving

The visible problem was reporting.

The real problem was that useful analysis depended too much on local system knowledge and one-off SQL. The data existed, but it was scattered across commercial and production processes, shaped differently in each place, and not very forgiving if someone did not already know how the source systems behaved.

I wanted a layer that was more stable than ad hoc querying:
- repeatable refreshes
- clearer grain
- less report-by-report reinvention
- and enough structure that later work in Snowflake and Streamlit would not be built on top of guesswork

## What the source landscape looked like

The source side mixed a few different kinds of data:
- ERP-style commercial data
- manufacturing and production execution data
- smaller helper lookups maintained outside the main transactional flow

That meant the hard part was rarely just selecting columns. It was understanding where time meant document time, where it meant process time, where current state was enough, and where history actually mattered. It also meant accepting that similarly named entities across systems were not automatically the same thing.

## How I structured the warehouse

I kept the structure simple on purpose.

There was a `stg` layer for source-aligned extracts and a `dwh` layer for analytical tables. I did not want a very clever architecture that would look good on a diagram and be annoying to debug in daily use.

The rough flow was:
1. truncate staging
2. load staging
3. run a lightweight validator
4. transform dimensions
5. transform facts

That orchestration ran through SQL Server Agent. It was not glamorous, but it was easy to understand and easy to troubleshoot.

## How I thought about the model

The model followed a practical Kimball-style approach:
- conformed dimensions
- surrogate keys in `dwh`
- facts at explicit business grain
- unknown rows where they helped keep loads stable instead of failing noisily

The dimensions included things like date, customer, item, sales order, production order, machine, material, and work instruction. The facts covered offers, sales orders, goods issue, goods receipt, material consumption, planned production routing, and registered production routing.

What mattered more than naming the pattern was getting the grain right. That was the real work.

## SCD decisions were not mechanical

I used both `SCD1` and `SCD2`, but not because I wanted to tick a methodology box.

Some entities only needed current business state. Some technically had history, but the source-side versioning was too noisy or too operational to be worth preserving as-is. Other entities genuinely changed in ways that mattered analytically over time, so `SCD2` made sense there.

One of the stronger lessons from the warehouse phase was that source history and business history are not automatically the same thing.

## Validation mattered more than I expected

I added a lightweight validation layer fairly early. It checked things like:
- row counts
- missing required business keys
- invalid date ranges
- suspicious duplicates in a few sensitive staging objects

That was one of the more practical decisions in the project. It helped catch broken extracts and source-side changes before they spread into facts and reports. It also made the refresh process feel a lot less fragile.

## What turned out to be genuinely hard

A few things were harder than they looked at first:
- choosing the right grain before building too much on the wrong one
- separating source-shaped extraction from business-shaped modeling
- deciding where historical behavior mattered and where it only created noise
- dealing with imperfect entity matching across systems
- keeping the warehouse simple enough to operate without making it simplistic

That last point mattered a lot. I was not trying to build the most elaborate warehouse possible. I was trying to build one that would hold up in repeated day-to-day use.

## What this part taught me

The warehouse phase taught me that good analytical design is usually less about writing a fancy query and more about making a series of careful judgment calls:
- where to trust the source
- where to normalize
- where to preserve ambiguity
- where to make the model stricter than the raw system

It also taught me that small defensive choices add up:
- unknown rows
- validation before fact loads
- keeping orchestration simple
- not overcommitting to history where the source does not support it well

Those decisions do not always look dramatic in isolation, but together they are what make the model usable.

## What I left out of the public version

This repository is a portfolio version, not a company backup.

So I intentionally left out or generalized:
- real company names
- exact source database names where that would reveal too much
- customer-specific matching rules
- full production SQL for sensitive transforms
- operational details that are useful internally but unnecessary for an external reviewer

What I wanted to keep visible instead was the part that actually shows engineering judgment:
- how the warehouse was structured
- how grain was chosen
- how refreshes were organized
- and how this layer became the base for Snowflake and Streamlit later on

## Bottom line

The warehouse was the least visible part of the final platform, but it was also the part that decided whether the rest of the project would be trustworthy.

Snowflake made the model portable.
Streamlit made it usable.
But SQL Server DWH was where the analytical shape of the project was actually formed.
