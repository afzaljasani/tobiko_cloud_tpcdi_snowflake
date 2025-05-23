MODEL (
  name sqlmesh_tpcdi.accountincremental,
  kind VIEW,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.v_accountincremental
    

