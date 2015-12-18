create or replace package ILP_PK_TOPUP_UT is

  -- Author  : NATTAPORNCH
  -- Created : 12/16/2015 13:05:00 AM
  -- Purpose : Testing for ILP_PK_TOPUP

  PROCEDURE ut_setup;
  PROCEDURE ut_teardown;
  -- ilp_pk_topup.execute success it should return value is 0
  PROCEDURE ut_saveTopup_pass;
  -- ilp_pk_topup.execute it should return 2 when not found contract_id
  PROCEDURE ut_saveTopup_notFound;
  -- ilp_pk_topup.execute it should return 2 when not found contract_id
  PROCEDURE ut_saveTopup_polDtail_notFound;
  -- ilp_pk_topup.execute it should fail when error list more then 1 error.
  PROCEDURE ut_saveTopup_fail;

  -- Call all test
  PROCEDURE TEST;

end ILP_PK_TOPUP_UT;
