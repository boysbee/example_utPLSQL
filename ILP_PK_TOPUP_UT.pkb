create or replace package body ILP_PK_TOPUP_UT is
  mNotFoundProcId INTEGER := 9000;
  mNotFoundPolD   INTEGER := 9001;

  mSuccProcId        INTEGER := 9999;
  mSuccParamId       INTEGER := 9999;
  mSuccPolDParamId   INTEGER := 10000;
  mSuccPolPrmParamId INTEGER := 10001;
  mSuccReqParamId    INTEGER := 10002;

  mSuccCntIDParamName   VARCHAR2(20) := 'CONTRACT_ID';
  mSuccReqIDParamName   VARCHAR2(20) := 'REQUEST_ID';
  mSuccPolDParamName    VARCHAR2(20) := 'POL_DETAIL';
  mSuccPrmAllcParamName VARCHAR2(20) := 'POL_PREM_ALLOC';
  mSuccCntIDParamVal    VARCHAR2(100) := '9999999';

  mSuccReqIDParamVal VARCHAR2(100) := '9999999';

  mSuccPrmAllcVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
          <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>2</FUND_ID>
      <SEQ>1</SEQ>
      <PERCENT_INVEST>70</PERCENT_INVEST>
   </ROW>   
   <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>5</FUND_ID>
      <SEQ>2</SEQ>
      <PERCENT_INVEST>20</PERCENT_INVEST>
   </ROW>
   <ROW>
      <CONTRACT_ID>9999999</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>9</FUND_ID>
      <SEQ>3</SEQ>
      <PERCENT_INVEST>10</PERCENT_INVEST>
   </ROW>   
</ROWSET>';

  mSuccPolDParamVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
   <ROW>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <AUTO_REBALANCE_FLAG>Y</AUTO_REBALANCE_FLAG>
      <AUTO_REBALANCE_MONTH>6</AUTO_REBALANCE_MONTH>
      <DEDUCT_DIVIDEND_FUND>Y</DEDUCT_DIVIDEND_FUND>
      <POLICY_NO>9999999999</POLICY_NO>
      <CONTRACT_ID>9999999</CONTRACT_ID>
   </ROW>
    <ROW>
        <APPLICATION_ID>99999999</APPLICATION_ID>
        <Autorebalanceflag>Y</Autorebalanceflag>
        <Autorebalancemonth>6</Autorebalancemonth>
        <Deductdividendfund>Y</Deductdividendfund>
        <POLICY_NO>9999999999</PolicyNo>
        <CONTRACT_ID>9999999</CONTRACT_ID>
    </ROW>
</ROWSET>';

  mFailProcessId INTEGER := 9998;
  mFailParamId   INTEGER := 9998;
  mFailParamName VARCHAR2(20) := 'CONTRACT_ID';

  mFailCntId           VARCHAR2(100) := '1000000';
  mPIDNotFoundPremAllc INTEGER := 9002;

  mFailPremAllocPolDParamVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
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
      <PERCENT_INVEST>70</PERCENT_INVEST>
   </ROW>   
   <ROW>
      <CONTRACT_ID>1000000</CONTRACT_ID>
      <APPLICATION_ID>1342900</APPLICATION_ID>
      <PREMIUM_TYPE>TUP</PREMIUM_TYPE>
      <FUND_ID>5</FUND_ID>
      <SEQ>2</SEQ>
      <PERCENT_INVEST>30</PERCENT_INVEST>
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
  /*  --------------------------------------------------
       UT_SETUP : setup the test data here. This is first
                  procedure gets saveTopupd automatically
  ----------------------------------------------------- */
  PROCEDURE ut_setup IS
  BEGIN
    ut_teardown; -- delete mock data
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
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccParamId, :mSuccProcId,:mSuccCntIDParamName,:mSuccCntIDParamVal)'
      USING mSuccParamId, mSuccProcId, mSuccCntIDParamName, mSuccCntIDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccPolDParamId, :mSuccProcId,:mSuccPolDParamName,:mSuccPolDParamVal)'
      USING mSuccPolDParamId, mSuccProcId, mSuccPolDParamName, mSuccPolDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccPolPrmParamId, :mSuccProcId,:mSuccPrmAllcParamName,:mSuccPrmAllcVal)'
      USING mSuccPolPrmParamId, mSuccProcId, mSuccPrmAllcParamName, mSuccPrmAllcVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mSuccParamId, :mSuccProcId,:mSuccReqIDParamName,:mSuccReqIDParamVal)'
      USING mSuccReqParamId, mSuccProcId, mSuccReqIDParamName, mSuccReqIDParamVal;
    /* end mock case success */
  
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
    (:mFailParamId, :mFailProcessId,:mFailParamName,:mFailCntId)'
      USING mFailParamId, mFailProcessId, mFailParamName, mFailCntId;
  
    /* mock case not found prem_alloc 
    ilp_t_process_subscribe : found
    ILP_T_PROCESS_SUBSCRIBE_PARAM ( CONTRACT_ID) : found
    ILP_T_PROCESS_SUBSCRIBE_PARAM ( POL_DETAIL) :found
    ILP_T_PROCESS_SUBSCRIBE_PARAM ( POL_PREM_ALLOC) : not found
    */
  
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mNotFoundPremAllc, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mPIDNotFoundPremAllc;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mFailPremAllocCase, :mNotFoundPremAllc,:mFailParamName,:mFailCntId)'
      USING 90021, mPIDNotFoundPremAllc, mFailParamName, mFailCntId;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM
    (PARAM_ID,PROCESS_ID,PARAM_NAME,PARAM_VALUE) values 
    (:mFailPremAllocPolIdCase, :mNotFoundPremAllc,:mSuccPolDParamName,:mFailPremAllocPolDParamVal)'
      USING 90022, mPIDNotFoundPremAllc, mSuccPolDParamName, mFailPremAllocPolDParamVal;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM
    (PARAM_ID,PROCESS_ID,PARAM_NAME,PARAM_VALUE) values 
    (90023, :mFailProcessId,''POL_PREM_ALLOC'',:mFailPrmAllcVal)'
      USING mFailProcessId, mFailPrmAllcVal;
    /* end mock case fail */
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
    EXECUTE IMMEDIATE 'delete from ilp_t_process_subscribe where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
  
    -- delete mock fail case
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mFailProcessId'
      USING mFailProcessId;
    EXECUTE IMMEDIATE 'delete from ilp_t_process_subscribe where PROCESS_ID = :mFailProcessId'
      USING mFailProcessId;
    -- delete case not found in prem_alloc
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mNotFoundPremAllc'
      USING mPIDNotFoundPremAllc;
    EXECUTE IMMEDIATE 'delete from ilp_t_process_subscribe where PROCESS_ID = :mNotFoundPremAllc'
      USING mPIDNotFoundPremAllc;
    -- delete mock data in ilp_t_pol_detail
    execute IMMEDIATE 'delete from ilp_t_pol_detail where PROCESS_ID = :mSuccProcId'
      USING mSuccProcId;
  
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
  
    result := ilp_pk_topup.saveTopup(mSuccProcId);
    utassert.eqqueryvalue('Save Topup should insert data into table ilp_t_pol_detail',
                          'select contract_id from ilp_t_pol_detail where process_id =' ||
                          mSuccProcId,
                          mSuccCntIDParamVal);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_notFound IS
  
  BEGIN
  
    -- We expect result 2 is data not found.
    utAssert.eq('It should return 2 when we use ilp_pk_topup.saveTopup but not found contractid when pass processid it should return value is 2',
                ilp_pk_topup.saveTopup(mNotFoundProcId),
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
                ilp_pk_topup.saveTopup(mNotFoundProcId),
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
  
    -- We expect result 2 is premium_allocate data not found.
    utAssert.eq('It should return 2 when call ilp_pk_topup.saveTopup but not found data premium_allocate when pass processid.',
                ilp_pk_topup.saveTopup(mPIDNotFoundPremAllc),
                2);
  END;
  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                         pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  /*PROCEDURE ut_saveTopup_fail IS
  
  BEGIN
  
    -- We expect result -1 is fail.  
    utAssert.eq('It should return -1 when ilp_pk_topup.saveTopup was failed.',
                ilp_pk_topup.saveTopup(mFailProcessId),
                -1);
  END;
  */
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
                ilp_pk_topup.getParam(mSuccProcId, mSuccCntIDParamName),
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
    execute IMMEDIATE 'delete from ILP_T_POL_PREM_ALLOC where PROCESS_ID = :pProcessId'
      USING pProcessId;
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
  /*
  PROCEDURE : validatePremAmount
    
   Assertion methods used : EQ
  */
  procedure ut_validatePremiumAmount_fail is
    pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  begin
    -- get fake fail data for policy_premium_alloc.
    pPolPremAllocList := ilp_pk_topup.getPolicyPremAllocList(mFailProcessId,
                                                             mFailCntId);
    -- Test expect return false when validatePreAmount becuase sum of premium over 100%.
    utassert.eq('It should false return when validate all premiun amount should over 100 percentage.',
                ilp_pk_topup.validatePremAmount(mFailProcessId,
                                                pPolPremAllocList),
                false);
  end;
  PROCEDURE TEST IS
  BEGIN
    utplsql.run('ILP_PK_TOPUP_UT');
  END;
end ILP_PK_TOPUP_UT;
