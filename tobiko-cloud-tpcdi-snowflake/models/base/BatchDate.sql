MODEL (
  name sqlmesh_tpcdi.batchdate,
  kind FULL,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.v_batchdate