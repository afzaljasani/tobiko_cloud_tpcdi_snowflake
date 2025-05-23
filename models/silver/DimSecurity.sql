MODEL (
  name tcloud_tpcdi.dimsecurity,
  kind FULL,
  audits (
    NOT_NULL_NON_BLOCKING(columns = (sk_companyid))
)
);
SELECT 

  Symbol,
  issue,
  status,
  Name,
  exchangeid,
  sk_companyid,
  sharesoutstanding,
  firsttrade,
  firsttradeonexchange,
  Dividend,
  if(enddate = date('9999-12-31'), True, False) iscurrent,
  1 batchid,
  effectivedate,
  concat(exchangeid, '-', effectivedate) as sk_securityid, 
  enddate
FROM (
  SELECT 
    fws.Symbol,
    fws.issue,
    fws.status,
    fws.Name,
    fws.exchangeid,
    dc.sk_companyid,
    fws.sharesoutstanding,
    fws.firsttrade,
    fws.firsttradeonexchange,
    fws.Dividend,
    if(fws.effectivedate < dc.effectivedate, dc.effectivedate, fws.effectivedate) effectivedate,
    if(fws.enddate > dc.enddate, dc.enddate, fws.enddate) enddate
  FROM (
    SELECT 
      fws.* except(Status, conameorcik),
      nvl(string(try_cast(conameorcik as bigint)), conameorcik) conameorcik,
      s.ST_NAME as status,
      coalesce(
        lead(effectivedate) OVER (
          PARTITION BY symbol
          ORDER BY effectivedate),
        date('9999-12-31')
      ) enddate
    FROM (
      SELECT
        recdate AS effectivedate,
    trim(substring(value, 1, 15)) AS Symbol,
    trim(substring(value, 16, 6)) AS issue,
    trim(substring(value, 22, 4)) AS Status,
    trim(substring(value, 26, 70)) AS Name,
    trim(substring(value, 96, 6)) AS exchangeid,
    cast(substring(value, 102, 13) as BIGINT) AS sharesoutstanding,
    to_date(substring(value, 115, 8), 'yyyyMMdd') AS firsttrade,
    to_date(substring(value, 123, 8), 'yyyyMMdd') AS firsttradeonexchange,
    cast(substring(value, 131, 12) AS DOUBLE) AS Dividend,
    trim(substring(value, 143, 60)) AS conameorcik
      FROM tcloud_tpcdi.finwire
      WHERE rectype = 'SEC'
      ) fws
    JOIN tcloud_tpcdi.statustype s
      ON s.ST_ID = fws.status
    ) fws
  JOIN (
    SELECT 
      sk_companyid,
      name conameorcik,
      EffectiveDate,
      EndDate
    FROM tcloud_tpcdi.dimcompany
    UNION ALL
    SELECT 
      sk_companyid,
      cast(companyid as string) conameorcik,
      EffectiveDate,
      EndDate
    FROM tcloud_tpcdi.dimcompany
  ) dc 
  ON
    fws.conameorcik = dc.conameorcik 
    AND fws.EffectiveDate < dc.EndDate
    AND fws.EndDate > dc.EffectiveDate
) fws
WHERE effectivedate != enddate