MODEL (
  name sqlmesh_tpcdi.dimtime,
  kind FULL,
);

select *
from tpcdi.tpcdi_100_dbsql_100_stage.dimtime
;

