MODEL (
  name sqlmesh_tpcdi.taxrate,
  kind FULL,
);

select *
from tpcdi.tpcdi_100_dbsql_100_stage.taxrate
;

