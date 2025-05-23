MODEL (
  name sqlmesh_tpcdi.dimaccount,
  kind FULL,
  audits (
    NOT_NULL_NON_BLOCKING(columns = (sk_customerid, sk_brokerid))
)
);

SELECT
  
  a.accountid,
  b.sk_brokerid,
  a.sk_customerid,
  a.accountdesc,
  a.TaxStatus,
  a.status,
  a.batchid,
  a.effectivedate,
  concat(a.accountid, '-', a.effectivedate) as sk_accountid,
  a.enddate,
  '4' as new_column
FROM (
  SELECT
    a.* except(effectivedate, enddate, customerid),
    c.sk_customerid,
    iff(a.effectivedate < c.effectivedate, c.effectivedate, a.effectivedate) effectivedate,
    iff(a.enddate > c.enddate, c.enddate, a.enddate) enddate
  FROM (
    SELECT *
    FROM (
      SELECT
        accountid,
        customerid,
        coalesce(accountdesc, last_value(accountdesc) IGNORE NULLS OVER (
          PARTITION BY accountid ORDER BY update_ts)) accountdesc,
        coalesce(taxstatus, last_value(taxstatus) IGNORE NULLS OVER (
          PARTITION BY accountid ORDER BY update_ts)) taxstatus,
        coalesce(brokerid, last_value(brokerid) IGNORE NULLS OVER (
          PARTITION BY accountid ORDER BY update_ts)) brokerid,
        coalesce(status, last_value(status) IGNORE NULLS OVER (
          PARTITION BY accountid ORDER BY update_ts)) status,
        date(update_ts) effectivedate,
        nvl(lead(date(update_ts)) OVER (PARTITION BY accountid ORDER BY update_ts), date('9999-12-31')) enddate,
        batchid
      FROM (
        SELECT
          accountid,
          customerid,
          accountdesc,
          taxstatus,
          brokerid,
          status,
          update_ts,
          1 batchid
        FROM sqlmesh_tpcdi.customermgmtview c
        WHERE ActionType NOT IN ('UPDCUST', 'INACT')
        UNION ALL
        SELECT
          accountid,
          a.customerid,
          accountDesc,
          TaxStatus,
          a.brokerid,
          st_name as status,
          TO_TIMESTAMP(bd.batchdate) update_ts,
          a.batchid
        FROM sqlmesh_tpcdi.accountincremental a
        JOIN sqlmesh_tpcdi.batchdate bd
          ON a.batchid = bd.batchid
        JOIN sqlmesh_tpcdi.statustype st 
          ON a.status = st.st_id
      ) a
    ) a
    WHERE a.effectivedate < a.enddate
  ) a
  FULL OUTER JOIN sqlmesh_tpcdi.dimcustomerstg c 
    ON 
      a.customerid = c.customerid
      AND c.enddate > a.effectivedate
      AND c.effectivedate < a.enddate
) a
LEFT JOIN sqlmesh_tpcdi.dimbroker b 
  ON a.brokerid = b.brokerid;
