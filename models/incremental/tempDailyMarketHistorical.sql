MODEL (
  name sqlmesh_tpcdi.tempdailymarkethistorical,
  kind FULL,
);


SELECT
  dmh.*,
  sk_dateid,
  min(dm_low) OVER (
    PARTITION BY dm_s_symb
    ORDER BY dm_date ASC ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
  ) fiftytwoweeklow,
  max(dm_high) OVER (
    PARTITION by dm_s_symb
    ORDER BY dm_date ASC ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
  ) fiftytwoweekhigh
FROM (
  SELECT * FROM sqlmesh_tpcdi.dailymarkethistorical
  UNION ALL
  SELECT * except(fiftytwoweekhigh, sk_fiftytwoweekhighdate, 
  fiftytwoweeklow, sk_fiftytwoweeklowdate) FROM sqlmesh_tpcdi.dailymarketincremental) dmh
JOIN sqlmesh_tpcdi.dimdate d 
  ON d.datevalue = dm_date