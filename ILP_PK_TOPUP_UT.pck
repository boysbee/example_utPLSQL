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

  -- test get getPolPreAllc xml from subscribe_param.
  PROCEDURE ut_getPoldetail;

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
  --PROCEDURE ut_saveTopup_fail;

  -- test save data into ilp_t_pol_detail.
  PROCEDURE ut_savePolPremAlloc;

  -- test validate success premium amount;
  PROCEDURE ut_validatePremiumAmount_succ;
  -- test validate fail  premium amount;
  PROCEDURE ut_validatePrmAmount_fail;
  -- Call all test
  PROCEDURE test;

end ILP_PK_TOPUP_UT;
/
create or replace package body ILP_PK_TOPUP_UT is
  mUpdateUser     CONSTANT VARCHAR2(10) := 'unittest';
  mNotFoundProcId CONSTANT INTEGER := 9000;
  mNotFoundPolD   CONSTANT INTEGER := 9001;

  mSuccProcId        CONSTANT INTEGER := 9999;
  mSuccParamId       CONSTANT INTEGER := 9999;
  mSuccPolDParamId   CONSTANT INTEGER := 10000;
  mSuccPolPrmParamId CONSTANT INTEGER := 10001;
  mSuccReqParamId    CONSTANT INTEGER := 10002;

  cntIDParamName     CONSTANT VARCHAR2(20) := 'CONTRACT_ID';
  reqIDParamName     CONSTANT VARCHAR2(20) := 'REQUEST_ID';
  polDParamName      CONSTANT VARCHAR2(20) := 'POL_DETAIL';
  prmAllcParamName   CONSTANT VARCHAR2(20) := 'POL_PREM_ALLOC';
  mSuccCntIDParamVal CONSTANT VARCHAR2(100) := '9999999';

  mSuccReqIDParamVal CONSTANT VARCHAR2(100) := '9999999';

  mSuccPrmAllcVal CONSTANT VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
          <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>99999999</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>2</FUND_ID>
      <SEQ>1</SEQ>
      <PERCENT_INVEST>70</PERCENT_INVEST>
   </ROW>   
   <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>99999999</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>5</FUND_ID>
      <SEQ>2</SEQ>
      <PERCENT_INVEST>20</PERCENT_INVEST>
   </ROW>
   <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>99999999</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>9</FUND_ID>
      <SEQ>3</SEQ>
      <PERCENT_INVEST>10</PERCENT_INVEST>
   </ROW>   
</ROWSET>';

  mSuccPolDParamVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
   <ROW>
      <APPLICATION_ID>99999999</APPLICATION_ID>
      <AUTO_REBALANCE_FLAG>Y</AUTO_REBALANCE_FLAG>
      <AUTO_REBALANCE_MONTH>6</AUTO_REBALANCE_MONTH>
      <DEDUCT_DIVIDEND_FUND>Y</DEDUCT_DIVIDEND_FUND>
      <POLICY_NO>9999999999</POLICY_NO>
      <CONTRACT_ID>9999999</CONTRACT_ID>
   </ROW>
</ROWSET>';

  mFailProcessId   INTEGER := 9998;
  mFailValidProcId INTEGER := -4000;
  mFailParamId     INTEGER := 9998;

  mPIDNotFoundPremAllc INTEGER := 9002;

  mFailPrmAllcValidPid NUMBER := -4001;
  mFailCntValidPid     NUMBER := -4002;
  mFailCntID           NUMBER := -4003;
  mFailPolDParamId     NUMBER := -4005;

  mFailPolDParamVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
   <ROW>
      <APPLICATION_ID>99999999</APPLICATION_ID>
      <AUTO_REBALANCE_FLAG>Y</AUTO_REBALANCE_FLAG>
      <AUTO_REBALANCE_MONTH>6</AUTO_REBALANCE_MONTH>
      <DEDUCT_DIVIDEND_FUND>Y</DEDUCT_DIVIDEND_FUND>
      <POLICY_NO>9999999999</POLICY_NO>
      <CONTRACT_ID>1000000</CONTRACT_ID>
   </ROW>
</ROWSET>';

  mFailPrmAllcVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
          <ROW>
      <CONTRACT_ID>1000000</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>2</FUND_ID>
      <SEQ>1</SEQ>
      <PERCENT_INVEST>40</PERCENT_INVEST>
   </ROW>   
   <ROW>
      <CONTRACT_ID>1000000</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>5</FUND_ID>
      <SEQ>2</SEQ>
      <PERCENT_INVEST>20</PERCENT_INVEST>
   </ROW>
   <ROW>
      <CONTRACT_ID>1000000</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>9</FUND_ID>
      <SEQ>3</SEQ>
      <PERCENT_INVEST>70</PERCENT_INVEST>
   </ROW>   
</ROWSET>';

  procedure mock_success_case is
  begin
    /* 
      start mock cass all success
        ilp_t_process_subscribe | true
        contract_id             | true
        pol_detail              | true
        premium_alloc           | true
    */
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mSuccProcId, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mSuccProcId;
    -- success case set CONTRACT_ID
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccParamId, :mSuccProcId,''CONTRACT_ID'',:mSuccCntIDParamVal)'
      USING mSuccParamId, mSuccProcId, mSuccCntIDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccParamId, :mSuccProcId,''REQUEST_ID'',:mSuccReqIDParamVal)'
      USING mSuccReqParamId, mSuccProcId, mSuccReqIDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccPolDParamId, :mSuccProcId,''POL_DETAIL'',:mSuccPolDParamVal)'
      USING mSuccPolDParamId, mSuccProcId, mSuccPolDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccPolPrmParamId, :mSuccProcId,''POL_PREM_ALLOC'',:mSuccPrmAllcVal)'
      USING mSuccPolPrmParamId, mSuccProcId, mSuccPrmAllcVal;
  
    /* end mock case success */
  end;

  procedure mock_fail_case is
  begin
    /* start mock case fail 
       ilp_t_process_subscribe     | true
        contract_id                | fail
    
    */
  
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mFailProcessId, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mFailProcessId;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (9998, :mFailProcessId,''CONTRACT_ID'',:mFailCntId)'
      USING mFailProcessId, mFailCntId;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (9999, :mFailProcessId,''POL_DETAIL'',:mFailPolDParamVal)'
      USING mFailProcessId, mFailPolDParamVal;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (10000, :mFailProcessId,''POL_PREM_ALLOC'',:mFailPrmAllcVal)'
      USING mFailProcessId, mFailPrmAllcVal;
  
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mNotFoundPremAllc, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mPIDNotFoundPremAllc;
  
    -- set fail case CONTRACT_ID
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (90021, :mNotFoundPremAllc,''CONTRACT_ID'',:mFailCntId)'
      USING mPIDNotFoundPremAllc, mFailCntId;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM
    (PARAM_ID,PROCESS_ID,PARAM_NAME,PARAM_VALUE) values 
    (90022, :mNotFoundPremAllc,''POL_DETAIL'',:mFailPremAllocPolDParamVal)'
      USING mPIDNotFoundPremAllc, mFailPolDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM
    (PARAM_ID,PROCESS_ID,PARAM_NAME,PARAM_VALUE) values 
    (90023, :mFailProcessId,''POL_PREM_ALLOC'',:mFailPrmAllcVal)'
      USING mFailProcessId, mFailPrmAllcVal;
    /* end mock case fail */
  end;
  procedure mock_validate_fail is
  
  begin
    -- set mock databefore
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mFailProcessId, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mFailValidProcId;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mFailCntValidPid, :mFailValidProcId,''CONTRACT_ID'',:mFailCntID)'
      USING mFailCntValidPid, mFailValidProcId, mFailCntID;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mFailPolDParamId, :mFailValidProcId,''POL_DETAIL'',:mFailPolDParamVal)'
      USING mFailPolDParamId, mFailValidProcId, mFailPolDParamVal;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mFailPrmAllcValidPid, :mFailValidProcId,''POL_PREM_ALLOC'',:mFailPrmAllcVal)'
      USING mFailPrmAllcValidPid, mFailValidProcId, mFailPrmAllcVal;
  end;
  /*  --------------------------------------------------
       UT_SETUP : setup the test data here. This is first
                  procedure gets saveTopupd automatically
  ----------------------------------------------------- */
  PROCEDURE ut_setup IS
  BEGIN
    ut_teardown; -- delete mock data
    mock_success_case;
    mock_fail_case;
    mock_validate_fail;
  END;

  /*  --------------------------------------------------
       UT_TEARDOWN : clean you data here. This is the last
                  procedure gets saveTopupd automatically
  ----------------------------------------------------- */
  PROCEDURE ut_teardown IS
  BEGIN
    -- delete mock success case
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
  
    -- delete mock fail case
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mFailProcessId'
      USING mFailProcessId;
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE where PROCESS_ID = :mFailProcessId'
      USING mFailProcessId;
    -- delete case not found in prem_alloc
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mNotFoundPremAllc'
      USING mPIDNotFoundPremAllc;
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE where PROCESS_ID = :mNotFoundPremAllc'
      USING mPIDNotFoundPremAllc;
    -- delete mock data in ilp_t_pol_detail
    execute IMMEDIATE 'delete from ILP_T_POL_DETAIL where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
    -- clear mock data in ILP_T_POL_PREM_ALLOC
    execute IMMEDIATE 'delete from ILP_T_POL_PREM_ALLOC where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
    /* clear case validate fail */
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mFailValidProcId'
      USING mFailValidProcId;
  
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE where PROCESS_ID = :mFailValidProcId'
      USING mFailValidProcId;
    /* end clear case validate fail */
    commit;
  EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Ignore if any errors. 
  END;
  PROCEDURE ut_getPolPreAllc is
  begin
    utassert.isnotnull('It should return xml.',
                       ilp_pk_topup.getPolPreAllc(mSuccProcId));
  end;
  /*
   PROCEDURE getPolicyPremAllocList(
     pProcessId NUMBER,
     pContractId NUMBER
     )
     Assertion methods used : EQ
  */
  PROCEDURE ut_getPolicyPremAllocList is
  
    pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  begin
    pPolPremAllocList := ilp_pk_topup.getPolicyPremAllocList(mSuccProcId,
                                                             mSuccCntIDParamVal);
    utassert.eq('It should return list data.', pPolPremAllocList.count, 3);
    utassert.eq('Premium Type shoud be RPP.',
                pPolPremAllocList(1).premium_type,
                'TUP');
  
  end;

  procedure ut_getPoldetail is
    policyDetailRow ILP_T_POL_DETAIL%ROWTYPE;
  begin
    policyDetailRow := ilp_pk_topup.getPolicyDetailRow(mSuccProcId,
                                                       mSuccCntIDParamVal);
    utassert.eq('It should return row of poldetail',
                policyDetailRow.policy_no,
                '9999999999');
  end;

  /*  --------------------------------------------------
                   PROCEDURE savePremToPolDetail (
                             pProcessId          NUMBER;
    pContractId         NUMBER;
    pRequestId          NUMBER;
    pApplicationId      NUMBER ;
    pPolicyNo           VARCHAR2(20);
    pAutoReFlag         VARCHAR2(10);
    pAutoReMonth        NUMBER;
    pDeductDevidendFund VARCHAR2(1);
    pUpdateUser         VARCHAR2(10);
    pTopupAmount        NUMBER ;
                   )
  
      Assertion methods used : eqqueryvalue
  ----------------------------------------------------- */
  PROCEDURE ut_savePremToPolDetail IS
    pProcessId          NUMBER := 88888;
    pContractId         NUMBER := 88888;
    pRequestId          NUMBER := 99999;
    pApplicationId      NUMBER := 99999;
    pPolicyNo           VARCHAR2(20) := '88888888';
    pAutoReFlag         VARCHAR2(10) := 'N';
    pAutoReMonth        NUMBER := 12;
    pDeductDevidendFund VARCHAR2(1) := '';
    pUpdateUser         VARCHAR2(10) := 'UNITTEST';
    pTopupAmount        NUMBER := 0;
  BEGIN
    ilp_pk_topup.savePremToPolDetail(pProcessId,
                                     pContractId,
                                     pRequestId,
                                     pApplicationId,
                                     pPolicyNo,
                                     pAutoReFlag,
                                     pAutoReMonth,
                                     pDeductDevidendFund,
                                     pUpdateUser,
                                     pTopupAmount);
    utassert.eqqueryvalue('It should savePremToPolDetail should insert data into table ilp_t_pol_detail',
                          'select contract_id from ilp_t_pol_detail where policy_no =' ||
                          pPolicyNo,
                          pContractId);
  
    -- clear data after insert.
    execute IMMEDIATE 'delete from ilp_t_pol_detail where PROCESS_ID = :pProcessId'
      USING pProcessId;
  END;

  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_pass IS
    result number;
  BEGIN
  
    result := ilp_pk_topup.saveTopup(mSuccProcId, mUpdateUser);
    --utassert.eq('It should return 0 when saveTopup pass', result, 0);
    utassert.eqqueryvalue('Save Topup should insert data into table ilp_t_pol_detail',
                          'select contract_id from ilp_t_pol_detail where process_id =' ||
                          mSuccProcId,
                          mSuccCntIDParamVal);
    utassert.eqqueryvalue('It should count data equals topup list size when insert to ILP_T_POL_PREM_ALLOC',
                          'select count(*) from ILP_T_POL_PREM_ALLOC where process_id =' ||
                          mSuccProcId,
                          3);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_notFound IS
  
  BEGIN
  
    -- Test expect result 2 is data not found.
    utAssert.eq('It should return 2 when we use ilp_pk_topup.saveTopup but not found contractid when pass processid it should return value is 2',
                ilp_pk_topup.saveTopup(mNotFoundProcId, mUpdateUser),
                2);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_polDtail_notFound IS
  
  BEGIN
  
    -- Test expect return 2(fail) not found policy_detail.
    utAssert.eq('It should return 2 when we use ilp_pk_topup.saveTopup but not found data policy_detail when pass processid.',
                ilp_pk_topup.saveTopup(mNotFoundProcId, mUpdateUser),
                2);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_premAllc_notFound IS
  
  BEGIN
  
    -- Test expect result 2 is premium_allocate data not found.
    utAssert.eq('It should return 2 when call ilp_pk_topup.saveTopup but not found data premium_allocate when pass processid.',
                ilp_pk_topup.saveTopup(mPIDNotFoundPremAllc, mUpdateUser),
                2);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                         pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_fail IS
  
  BEGIN
    -- should found fail case.
    utassert.eqqueryvalue('It should found fail case in ILP_T_PROCESS_SUBSCRIBE',
                          'select count(*) as count from ILP_T_PROCESS_SUBSCRIBE where PROCESS_ID =' ||
                          mFailProcessId,
                          1);
    utassert.eqqueryvalue('It should found data subscribe_param with fail case in ILP_T_PROCESS_SUBSCRIBE_PARAM',
                          'select count(*) as count from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID =' ||
                          mFailProcessId,
                          3);
    -- Test expect result -1 is fail.  
    utAssert.eq('It should return -1 when ilp_pk_topup.saveTopup was failed.',
                ilp_pk_topup.saveTopup(mFailProcessId, mUpdateUser),
                -1);
  END;

  /*  --------------------------------------------------
                   PROCEDURE getParam (
                         pProcessId in NUMBER;
                         mSuccCntIDParamName in VARCHAR2
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_getParam IS
  
  BEGIN
  
    -- Test expect result :mSuccCntIDParamVal when we use ilp_pk_topup.getParam(:mSuccProcId,mSuccCntIDParamName).
    utAssert.eq('It should return value : ' || mSuccCntIDParamVal ||
                ' when ilp_pk_topup.getParam.',
                ilp_pk_topup.getParam(mSuccProcId, cntIDParamName),
                mSuccCntIDParamVal);
  END;
  /*  --------------------------------------------------
                   PROCEDURE getContractId (
                         pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_getContractId IS
  
  BEGIN
  
    -- Test expect result :mSuccCntIDParamVal when we use ilp_pk_topup.getContractId(:mSuccProcId).
    utAssert.eq('It shuould return ' || mSuccCntIDParamVal ||
                ' when ilp_pk_topup.getContractId',
                ilp_pk_topup.getContractId(mSuccProcId),
                mSuccCntIDParamVal);
  END;
  /*  --------------------------------------------------
                   PROCEDURE getRequestId (
                         pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_getRequestId IS
  
  BEGIN
  
    -- Test expect result :mSuccReqIDParamVal when we use ilp_pk_topup.getRequestId(:mSuccProcId).  
    utAssert.eq('It shuould return ' || mSuccCntIDParamVal ||
                ' when ilp_pk_topup.getRequestId',
                ilp_pk_topup.getRequestId(mSuccProcId),
                mSuccReqIDParamVal);
  END;
  PROCEDURE ut_savePolPremAlloc is
    pProcessId        NUMBER := mSuccProcId;
    pContractId       NUMBER := mSuccCntIDParamVal;
    pRequestId        NUMBER := 99999;
    pApplicationId    NUMBER := 99999;
    pPolicyNo         VARCHAR2(20) := '88888888';
    pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    pUpdateUser       VARCHAR2(10) := 'UNITTEST';
  
  begin
    pPolPremAllocList := ilp_pk_topup.getPolicyPremAllocList(mSuccProcId,
                                                             mSuccCntIDParamVal);
    ilp_pk_topup.savePolPremAlloc(pProcessId,
                                  pContractId,
                                  pPolicyNo,
                                  pApplicationId,
                                  pPolPremAllocList,
                                  pUpdateUser);
    -- Test case expect should have data after insert into ILP_T_POL_PREM_ALLOC.
    utassert.eqqueryvalue('It should save data into ILP_T_POL_PREM_ALLOC',
                          'select contract_id from ILP_T_POL_PREM_ALLOC where PROCESS_ID =' ||
                          pProcessId,
                          pContractId);
  
  end;
  /*
  PROCEDURE : validatePremAmount
    
   Assertion methods used : EQ
  */
  procedure ut_validatePremiumAmount_succ is
    pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  begin
    -- get fake fail data for policy_premium_alloc.
    pPolPremAllocList := ilp_pk_topup.getPolicyPremAllocList(mSuccProcId,
                                                             mSuccCntIDParamVal);
    -- Test expect return true when validatePreAmount becuase sum of premium not over 100%.
    utassert.eq('It should validate all premiun amount should not over 100 percentage.',
                ilp_pk_topup.validatePremAmount(mSuccCntIDParamVal,
                                                pPolPremAllocList),
                true);
  end;

  procedure ut_validatePrmAmount_fail is
    pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  
    expect boolean := false;
    actual boolean;
  begin
  
    pPolPremAllocList := ilp_pk_topup.getPolicyPremAllocList(mFailValidProcId,
                                                             mFailCntID);
    -- Test expect return false when validatePreAmount becuase sum of premium over 100%.
    utassert.eq('It should validate all premiun amount should not over 100 percentage.',
                ilp_pk_topup.validatePremAmount(mFailCntID,
                                                pPolPremAllocList),
                false);
  
  end;

  PROCEDURE test IS
  BEGIN
    utplsql.run('ILP_PK_TOPUP_UT');
  END;

end ILP_PK_TOPUP_UT;
/
