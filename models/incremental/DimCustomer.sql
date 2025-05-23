MODEL (
  name tcloud_tpcdi.dimcustomer,
  kind FULL,
  audits (
    NOT_NULL_NON_BLOCKING(columns = (
      tier
    )),
    ACCEPTED_VALUES_NON_BLOCKING(column = tier, is_in = ('1', '2', '3'))
  )
);

SELECT
  c.sk_customerid,
  c.customerid,
  c.taxid,
  c.status,
  c.lastname,
  c.firstname,
  c.middleinitial,
  IF(c.gender IN ('M', 'F'), c.gender, 'U') AS gender,
  c.tier,
  c.dob,
  c.addressline1,
  c.addressline2,
  c.postalcode,
  c.city,
  c.stateprov,
  c.country,
  c.phone1,
  c.phone2,
  c.phone3,
  c.email1,
  c.email2,
  r_nat.TX_NAME AS nationaltaxratedesc,
  r_nat.TX_RATE AS nationaltaxrate,
  r_lcl.TX_NAME AS localtaxratedesc,
  r_lcl.TX_RATE AS localtaxrate,
  p.agencyid,
  p.creditrating,
  p.networth,
  p.marketingnameplate,
  c.iscurrent,
  c.batchid,
  c.effectivedate,
  c.enddate
FROM tcloud_tpcdi.DimCustomerStg AS c
LEFT JOIN tcloud_tpcdi.TaxRate AS r_lcl
  ON c.LCL_TX_ID = r_lcl.TX_ID
LEFT JOIN tcloud_tpcdi.TaxRate AS r_nat
  ON c.NAT_TX_ID = r_nat.TX_ID
LEFT JOIN tcloud_tpcdi.prospect AS p
  ON UPPER(p.lastname) = UPPER(c.lastname)
  AND UPPER(p.firstname) = UPPER(c.firstname)
  AND UPPER(p.addressline1) = UPPER(c.addressline1)
  AND UPPER(COALESCE(p.addressline2, '')) = UPPER(COALESCE(c.addressline2, ''))
  AND UPPER(p.postalcode) = UPPER(c.postalcode)