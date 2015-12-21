create or replace package ILP_PK_TOPUP_UT is

  -- Author  : NATTAPORNCH
  -- Created : 12/16/2015 13:05:00 AM
  -- Purpose : Testing for ILP_PK_TOPUP

  PROCEDURE ut_setup;
  PROCEDURE ut_teardown;
  -- test get param.
  PROCEDURE ut_getParam;
  -- test get request_id.
  PROCEDURE ut_getRequestId;
  -- test get contract_id.
  PROCEDURE ut_getContractId;
  -- test get getPolPreAllc xml from subscribe_param.
  PROCEDURE ut_getPolPreAllc;
  -- test get data policy_prem_alloc.
  PROCEDURE ut_getPolicyPremAllocList;

  -- test ilp_pk_topup.saveTopup success it should return value is 0.
  PROCEDURE ut_saveTopup_pass;
  -- test save data to ilp_t_pol_detail.
  PROCEDURE ut_savePremToPolDetail;

  -- test ilp_pk_topup.savePolPremAlloc.
  PROCEDURE ut_saveTopup_notFound;
  -- ilp_pk_topup.saveTopup it should return 2 when not found policy_detail by process_id.
  PROCEDURE ut_saveTopup_polDtail_notFound;
  -- ilp_pk_topup.saveTopup it should return 2 when not found premium_allocate by process_id.
  PROCEDURE ut_saveTopup_premAllc_notFound;
  -- ilp_pk_topup.saveTopup it should fail when error list more then 1 error.
  -- PROCEDURE ut_saveTopup_fail;

  -- test save data into ilp_t_pol_detail.
  PROCEDURE ut_savePolPremAlloc;

  -- test validate success premium amount;
  PROCEDURE ut_validatePremiumAmount_succ;
  -- test validate fail  premium amount;
  PROCEDURE ut_validatePremiumAmount_fail;
  -- Call all test
  PROCEDURE TEST;

end ILP_PK_TOPUP_UT;
