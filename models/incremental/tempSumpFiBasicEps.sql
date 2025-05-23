MODEL (
  name sqlmesh_tpcdi.tempsumpfibasicseps,
  kind FULL,
);


SELECT
  sk_companyid,
  fi_qtr_start_date,
  sum(fi_basic_eps) OVER (PARTITION BY companyid ORDER BY fi_qtr_start_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) - fi_basic_eps sum_fi_basic_eps
FROM sqlmesh_tpcdi.financial
JOIN sqlmesh_tpcdi.dimcompany
  USING (sk_companyid);