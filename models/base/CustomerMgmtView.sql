MODEL (
  name tcloud_tpcdi.customermgmtview,
  kind VIEW,
);

select
    *
from tpcdi.tpcdi_100_dbsql_100_stage.customermgmt
    
