The database documentation pages are generated from the Django object-relational model (ORM) of the `seazit` app. SEAZIT data tables and materialized views (`mvw_seazit_*`) are read-only to Django (`managed = False`).

Regenerating these pages requires a database connection; maintainers use the script in the internal deployment repository.
