MODEL (
  name tcloud_tpcdi.customerincremental,
  kind VIEW,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.v_customerincremental
    

