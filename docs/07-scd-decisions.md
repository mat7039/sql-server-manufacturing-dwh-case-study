# SCD Decisions

The project deliberately mixed `SCD1` and `SCD2`.

Typical rationale:
- `SCD1`
  - when only current business state mattered
  - or when source history was unreliable

- `SCD2`
  - when business interpretation changed over time
  - and there was a meaningful timeline to preserve

Important project lesson:
- not every technically versioned source should become a 1:1 `SCD2` dimension
- some sources required business compression to remove meaningless technical versions
