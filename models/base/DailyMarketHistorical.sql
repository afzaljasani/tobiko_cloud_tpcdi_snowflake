MODEL (
  name tcloud_tpcdi.dailymarkethistorical,
  kind VIEW,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.v_dailymarkethistorical
    

