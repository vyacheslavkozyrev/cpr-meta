# Schema Migrations — Skills Gap Analysis & Development Planning (0009)

## No Migrations in 0009

This feature adds no new tables and no new columns.

### Dependency on 0008

`positions.sort_order` is added by feature 0008 (Skills Taxonomy & Career Framework). No migration is required in 0009. Before implementation, verify the column exists:

```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'positions' AND column_name = 'sort_order';
```

If the column is absent, 0008 must be deployed first.
