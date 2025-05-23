MODEL (
  name sqlmesh_tpcdi.dimdate,
  kind FULL,
);

select *
from tpcdi.tpcdi_100_dbsql_100_stage.dimdate
;

