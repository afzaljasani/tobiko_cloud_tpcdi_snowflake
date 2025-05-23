MODEL (
  name sqlmesh_tpcdi.factcashbalances,
  kind FULL,
  audits (
    NOT_NULL(columns = (sk_accountid))
)
);


SELECT
  a.sk_customerid, 
  a.sk_accountid, 
  d.sk_dateid, 
  sum(account_daily_total) OVER (partition by c.accountid order by c.datevalue) cash,
  c.batchid
FROM (
  SELECT 
    ct_ca_id accountid,
    to_date(ct_dts) datevalue,
    sum(ct_amt) account_daily_total,
    batchid
  FROM (
    SELECT * except(ct_name)
    FROM tpcdi.tpcdi_100_dbsql_100_stage.v_cashtransactionhistory
    UNION ALL
    SELECT * 
    FROM sqlmesh_tpcdi.cashtransactionincremental
  )
  GROUP BY
    accountid,
    datevalue,
    batchid) c 
JOIN sqlmesh_tpcdi.dimdate d 
  ON c.datevalue = d.datevalue
-- Converts to LEFT JOIN if this is run as DQ EDITION. On some higher Scale Factors, a small number of Account IDs are missing from DimAccount, causing audit check failures. 
 LEFT JOIN sqlmesh_tpcdi.dimaccount a
  ON 
    c.accountid = a.accountid
    AND c.datevalue >= a.effectivedate 
    AND c.datevalue < a.enddate 
