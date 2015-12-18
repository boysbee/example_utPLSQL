create or replace package body ILP_PK_TOPUP_UT is
  mockNotFoundProcId INTEGER := 1111;

  mockSuccProcId        INTEGER := 9999;
  mockSuccParamId       INTEGER := 9999;
  mockSuccPolDParamId   INTEGER := 10000;
  mockSuccPolPrmParamId INTEGER := 10001;

  mockSuccCntIDParamName   VARCHAR2(20) := 'CONTRACT_ID';
  mockSuccPolDParamName    VARCHAR2(20) := 'POL_DETAIL';
  mockSuccPrmAllcParamName VARCHAR2(20) := 'POL_PREM_ALLOC';
  mockSuccCntIDParamVal    VARCHAR2(100) := '9999999';

  mockSuccPrmAllcVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
    <ROW>
        <ContractId>9999999</ContractId>
        <ApplicationId>99999999</ApplicationId>
        <PremiumType>RPP</PremiumType>
        <FundId>7</FundId>
        <Seq>1</Seq>
        <PercentInvest>30</PercentInvest>
    </ROW>   
</ROWSET>';

  mockSuccPolDParamVal VARCHAR2(4000) := '<?xml version="1.0" encoding="UTF-16"?>
<ROWSET>
    <ROW>
        <ApplicationId>99999999</ApplicationId>
        <Autorebalanceflag>Y</Autorebalanceflag>
        <Autorebalancemonth>6</Autorebalancemonth>
        <Deductdividendfund>Y</Deductdividendfund>
        <PolicyNo>9999999999</PolicyNo>
        <ContractId>9999999</ContractId>
    </ROW>
</ROWSET>';

  mockFailProcessId  INTEGER := 9998;
  mockFailParamId    INTEGER := 9998;
  mockFailParamName  VARCHAR2(20) := 'CONTRACT_ID';
  mockFailParamValue VARCHAR2(100) := '1000000';
  /*  --------------------------------------------------
       UT_SETUP : setup the test data here. This is first
                  procedure gets saveTopupd automatically
  ----------------------------------------------------- */
  PROCEDURE ut_setup IS
  BEGIN
    ut_teardown; -- delete mock data
    -- mock success case
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mockSuccProcId, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mockSuccProcId;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mockSuccParamId, :mockSuccProcId,:mockSuccCntIDParamName,:mockSuccCntIDParamVal)'
      USING mockSuccParamId, mockSuccProcId, mockSuccCntIDParamName, mockSuccCntIDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mockSuccParamId, :mockSuccProcId,:mockSuccPolDParamName,:mockSuccCntIDParamVal)'
      USING mockSuccPolDParamId, mockSuccProcId, mockSuccPolDParamName, mockSuccPolDParamVal;
  
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mockSuccPolPrmParamId, :mockSuccProcId,:mockSuccPrmAllcParamName,:mockSuccCntIDParamVal)'
      USING mockSuccPolPrmParamId, mockSuccProcId, mockSuccPrmAllcParamName, mockSuccPrmAllcVal;
  
    -- mock fail case
    execute immediate 'insert into ilp_t_process_subscribe 
    (PROCESS_ID, FUNC_CODE, CREATE_USER, CREATE_DATE, START_DATE, FINISH_DATE, 
    PROCESS_TYPE, PROCESS_STATUS, PROCESS_RESULT, EXECUTE_USER)
    values (:mockFailProcessId, ''SAVE_TOPUP'', ''asdfsaf'', 
    sysdate, sysdate, sysdate, ''N'', ''N'', 1, ''asdfsaf'')'
      USING mockFailProcessId;
    EXECUTE IMMEDIATE 'insert into ILP_T_PROCESS_SUBSCRIBE_PARAM(PARAM_ID,PROCESS_ID,
    PARAM_NAME,PARAM_VALUE) values 
    (:mockFailParamId, :mockFailProcessId,:mockFailParamName,:mockFailParamValue)'
      USING mockFailParamId, mockFailProcessId, mockFailParamName, mockFailParamValue;
  END;

  /*  --------------------------------------------------
       UT_TEARDOWN : clean you data here. This is the last
                  procedure gets saveTopupd automatically
  ----------------------------------------------------- */
  PROCEDURE ut_teardown IS
  BEGIN
    -- delete mock success case
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mockSuccProcId'
      USING mockSuccProcId;
    EXECUTE IMMEDIATE 'delete from ilp_t_process_subscribe where PROCESS_ID = :mockSuccProcId'
      USING mockSuccProcId;
  
    -- delete mock fail case
    EXECUTE IMMEDIATE 'delete from ILP_T_PROCESS_SUBSCRIBE_PARAM where PROCESS_ID = :mockSuccProcId'
      USING mockFailProcessId;
    EXECUTE IMMEDIATE 'delete from ilp_t_process_subscribe where PROCESS_ID = :mockSuccProcId'
      USING mockFailProcessId;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Ignore if any errors. 
  END;

  /*  --------------------------------------------------
                   PROCEDURE saveTopup (
                            pProcessId in NUMBER;
                   )
  
      Assertion methods used : EQ
  ----------------------------------------------------- */
  PROCEDURE ut_saveTopup_pass IS
  
  BEGIN
  
    -- We expect result 0 is success.
    utAssert.eq('ilp_pk_topup.saveTopup success it should return value is 0',
                ilp_pk_topup.saveTopup(mockSuccProcId),
                0);
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
    utAssert.eq('ilp_pk_topup.saveTopup not found contractid when pass processid it should return value is 2',
                ilp_pk_topup.saveTopup(mockNotFoundProcId),
                2);
  END;

  PROCEDURE ut_saveTopup_polDtail_notFound IS
  
  BEGIN
  
    -- We expect result 2 is policy_detail data not found.
    utAssert.eq('ilp_pk_topup.saveTopup not found contractid when pass processid it should return value is 2',
                ilp_pk_topup.saveTopup(mockNotFoundProcId),
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
  
    -- We expect result -1 is fail.  
    utAssert.eq('ilp_pk_topup.saveTopup fail it should return value is 0',
                ilp_pk_topup.saveTopup(mockFailProcessId),
                -1);
  END;

  PROCEDURE TEST IS
  BEGIN
    utplsql.run('ILP_PK_TOPUP_UT');
  END;
end ILP_PK_TOPUP_UT;
