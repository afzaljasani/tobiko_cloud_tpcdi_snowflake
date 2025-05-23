MODEL (
  name tcloud_tpcdi.factwatches,
  kind FULL,
  audits (
    NOT_NULL_NON_BLOCKING(columns = (sk_securityid, sk_customerid))
)
);

SELECT
  c.sk_customerid sk_customerid,
  s.sk_securityid sk_securityid,
  sk_dateid_dateplaced,
  sk_dateid_dateremoved,
  wh.batchid
FROM (
  SELECT * EXCEPT(w_dts)
  FROM (
    SELECT
      customerid,
      symbol,
      coalesce(sk_dateid_dateplaced, last_value(sk_dateid_dateplaced) IGNORE NULLS OVER (
        PARTITION BY customerid, symbol ORDER BY w_dts)) sk_dateid_dateplaced,
      coalesce(sk_dateid_dateremoved, last_value(sk_dateid_dateremoved) IGNORE NULLS OVER (
        PARTITION BY customerid, symbol ORDER BY w_dts)) sk_dateid_dateremoved,
      coalesce(dateplaced, last_value(dateplaced) IGNORE NULLS OVER (
        PARTITION BY customerid, symbol ORDER BY w_dts)) dateplaced,
      w_dts,
      coalesce(batchid, last_value(batchid) IGNORE NULLS OVER (
        PARTITION BY customerid, symbol ORDER BY w_dts)) batchid
    FROM ( 
      SELECT 
        wh.w_c_id customerid,
        wh.w_s_symb symbol,
        if(w_action = 'ACTV', d.sk_dateid, null) sk_dateid_dateplaced,
        if(w_action = 'CNCL', d.sk_dateid, null) sk_dateid_dateremoved,
        if(w_action = 'ACTV', d.datevalue, null) dateplaced,
        wh.w_dts,
        batchid 
      FROM (
        SELECT * FROM tpcdi.tpcdi_100_dbsql_100_stage.v_watchhistory
        UNION ALL
        SELECT *  FROM tcloud_tpcdi.watchincremental) wh
      JOIN tcloud_tpcdi.dimdate d
        ON d.datevalue = date(wh.w_dts)))
  QUALIFY ROW_NUMBER() OVER (PARTITION BY customerid, symbol ORDER BY w_dts desc) = 1) wh
-- Converts to LEFT JOINs if this is run as DQ EDITION. On some higher Scale Factors, a small number of Security symbols or Customer IDs "may" be missing from DimSecurity/DimCustomer, causing audit check failures. 
--${dq_left_flg} 
LEFT JOIN tcloud_tpcdi.dimsecurity s 
  ON 
    s.symbol = wh.symbol
    AND wh.dateplaced >= s.effectivedate 
    AND wh.dateplaced < s.enddate
--${dq_left_flg} 
LEFT JOIN tcloud_tpcdi.dimcustomer c 
  ON
    wh.customerid = c.customerid
    AND wh.dateplaced >= c.effectivedate 
    AND wh.dateplaced < c.enddate
