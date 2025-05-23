MODEL (
  name tcloud_tpcdi.dimbroker,
  kind FULL,
);



SELECT

  cast(employeeid as BIGINT) brokerid,
  cast(managerid as BIGINT) managerid,
  employeefirstname firstname,
  employeelastname lastname,
  employeemi middleinitial,
  employeebranch branch,
  employeeoffice office,
  employeephone phone,
  true iscurrent,
  12 batchid,
  (SELECT min(to_date(datevalue)) as effectivedate FROM tcloud_tpcdi.DimDate) effectivedate,
  date('9999-12-31') enddate,
  concat(brokerid, '-', enddate) as sk_brokerid
FROM  tpcdi.tpcdi_100_dbsql_100_stage.v_hr
WHERE employeejobcode = 314


