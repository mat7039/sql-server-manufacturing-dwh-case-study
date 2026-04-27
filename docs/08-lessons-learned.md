# Lessons Learned

Key lessons from the implementation:

- the hardest part was not writing SQL, but defining correct grain
- source history and business history are not always the same thing
- customer and entity matching often require curated alias rules
- unknown rows are worth keeping because they preserve load stability
- early validation saves time later
- a simple first orchestration is better than an over-engineered one
