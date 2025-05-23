MODEL (
  name sqlmesh_tpcdi.prospectraw,
  kind VIEW,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.v_prospect
    

