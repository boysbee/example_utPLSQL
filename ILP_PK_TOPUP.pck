CREATE OR REPLACE PACKAGE ILP_PK_TOPUP IS

  -- AUTHOR  : NATTAPORNCH
  -- CREATED : 12/16/2015 15:15 PM
  -- PURPOSE : PACKAGE FOR ADD TOPUP INFORMATION

  FUNCTION saveTopup(PPROCESSID IN NUMBER, PUPDATEUSER IN VARCHAR2)
    RETURN NUMBER;
  FUNCTION getParam(PPROCID IN NUMBER, PKEY IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION getContractId(PPROCESSID IN NUMBER) RETURN VARCHAR2;
  FUNCTION getRequestId(PPROCESSID IN NUMBER) RETURN VARCHAR2;
  FUNCTION getPolicyPremAllocList(pProcessId  IN NUMBER,
                                  pContractId IN NUMBER)
    RETURN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  FUNCTION getPolicyDetailRow(pProcessId IN NUMBER, pContractId IN NUMBER)
    RETURN ILP_T_POL_DETAIL%ROWTYPE;
  PROCEDURE savePremToPolDetail(pProcessId          in NUMBER,
                                pContractId         in NUMBER,
                                pRequestId          in NUMBER,
                                pApplicationId      in NUMBER,
                                pPolicyNo           in VARCHAR2,
                                pAutoReFlag         in VARCHAR2,
                                pAutoReMonth        in NUMBER,
                                pDeductDevidendFund in VARCHAR2,
                                pUpdateUser         in VARCHAR2,
                                pTopupAmount        in NUMBER);
  PROCEDURE savePolPremAlloc(pProcessId        IN NUMBER,
                             pContractId       IN NUMBER,
                             pPolicyNo         IN VARCHAR2,
                             pApplicationId    IN NUMBER,
                             pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                             pUpdateUser       IN VARCHAR2);
  FUNCTION getPolPreAllc(pProcessId IN NUMBER) return VARCHAR2;
  procedure validatePremAmount(pContractId    IN VARCHAR2,
                               pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                               pErrors        in out wtErrorList);

END ILP_PK_TOPUP;
/
create or replace package body ILP_PK_TOPUP is
  lPackageName VARCHAR2(50) := 'ILP_PK_TOPUP';
  TYPE tNumberCollection IS TABLE OF NUMBER INDEX BY VARCHAR2(64);
  FUNCTION getParam(pProcId in NUMBER, pKey in VARCHAR2) RETURN VARCHAR2 is
  begin
    return ILP_PK_PROCESS.GetParamValue(pProcId, pKey);
  end;

  FUNCTION getPolicyDetailRow(pProcessId IN NUMBER, pContractId IN NUMBER)
    RETURN ILP_T_POL_DETAIL%ROWTYPE IS
  
    lParamValue varchar2(4000);
    lFunc       varchar2(100) := 'ILP_PK_TOPUP.getPolicyDetailRow';
  
  BEGIN
  
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Process Id: ' || pProcessId ||
                            ', ContractId: ' || pContractId);
    lParamValue := ILP_PK_PROCESS.GetParamValue(pProcessId, 'POL_DETAIL');
    RETURN ILP_PK_XML_CONVERTER.GET_POL_DETAIL(lParamValue, pContractId);
  
  END getPolicyDetailRow;

  FUNCTION getPolPreAllc(pProcessId IN NUMBER) return VARCHAR2 is
  BEGIN
    RETURN getParam(pProcessId, 'POL_PREM_ALLOC');
  END;

  FUNCTION getPolicyPremAllocList(pProcessId  IN NUMBER,
                                  pContractId IN NUMBER)
    RETURN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE IS
  
    lParamValue VARCHAR2(4000);
    lFunc       varchar2(100) := 'ILP_PK_TOPUP.getPolicyPremAllocList';
  
  BEGIN
  
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Process Id: ' || pProcessId ||
                            ', ContractId: ' || pContractId);
  
    lParamValue := getPolPreAllc(pProcessId);
    RETURN ILP_PK_XML_CONVERTER.GET_ILP_PREM_TABLE_FROM_XML(xmltype(lParamValue),
                                                            pContractId);
  
  END getPolicyPremAllocList;
  FUNCTION isValueInRange(pValue    IN NUMBER,
                          pMinVAlue IN NUMBER,
                          pMaxValue IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN pValue BETWEEN pMinVAlue AND pMaxValue;
  END;
  procedure validateSumValue(sumAlloc IN NUMBER,
                             pErrors  in out wtErrorList) is
  begin
    if sumAlloc > 100 or sumAlloc < 0 then
      plw_pk_errors.addError(pErrors,
                             'ERR',
                             'Fund percent allocated in TUP must between 0-100.(Current:' ||
                             sumAlloc || ')',
                             NULL,
                             NULL);
    
    end if;
  
  end;
  procedure validateEachValue(pContractId    IN VARCHAR2,
                              pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                              sumAlloc       IN OUT NUMBER,
                              pErrors        in out wtErrorList) is
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.validateEachValue';
    pMinValue CONSTANT INTEGER := 0;
    pMaxValue CONSTANT INTEGER := 100;
  
  begin
  
    FOR i in 1 .. pPremAllocList.count LOOP
      IF (NOT isValueInRange(pPremAllocList(i).percent_invest,
                             pMinValue,
                             pMaxValue)) THEN
        plw_pk_errors.addError(pErrors,
                               'ERR',
                               'Fund percent allocated in ' || pPremAllocList(i)
                               .premium_type ||
                                ' must between 0-100.(Current:' || pPremAllocList(i)
                               .percent_invest || ')',
                               NULL,
                               NULL);
      END IF;
    
      sumAlloc := sumAlloc + pPremAllocList(i).percent_invest;
    END LOOP;
  
  end;

  procedure validatePremAmount(pContractId    IN VARCHAR2,
                               pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                               pErrors        in out wtErrorList) is
    lFunc    VARCHAR2(50) := 'ILP_PK_TOPUP.validatePremAmount';
    sumAlloc NUMBER := 0;
  
  begin
    validateEachValue(pContractId, pPremAllocList, sumAlloc, pErrors);
  
    validateSumValue(sumAlloc, pErrors);
  
  end;

  PROCEDURE savePremToPolDetail(pProcessId          in NUMBER,
                                pContractId         in NUMBER,
                                pRequestId          in NUMBER,
                                pApplicationId      in NUMBER,
                                pPolicyNo           in VARCHAR2,
                                pAutoReFlag         in VARCHAR2,
                                pAutoReMonth        in NUMBER,
                                pDeductDevidendFund in VARCHAR2,
                                pUpdateUser         in VARCHAR2,
                                pTopupAmount        in NUMBER) IS
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.savePremToPolDetail';
  begin
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'Process Id: ' || pProcessId || ' Request Id:' ||
                            pRequestId);
  
    insert into ilp_t_pol_detail
      (contract_id,
       application_id,
       policy_no,
       process_id,
       request_id,
       auto_rebalance_flag,
       auto_rebalance_month,
       deduct_dividend_fund,
       update_user,
       update_date)
    values
      (pContractId,
       pApplicationId,
       pPolicyNo,
       pProcessId,
       pRequestId,
       pAutoReFlag,
       pAutoReMonth,
       pDeductDevidendFund,
       pUpdateUser,
       sysdate);
  end;

  FUNCTION getContractId(pProcessId IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN getParam(pProcessId, 'CONTRACT_ID');
  END;
  FUNCTION getRequestId(pProcessId IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN getParam(pProcessId, 'REQUEST_ID');
  END;

  PROCEDURE insertPolPremAlloc(pProcessId        IN NUMBER,
                               pContractId       IN NUMBER,
                               pPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE) IS
  
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.insertPolPremAlloc';
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'Process id:' || pProcessId);
  
    FORALL i IN pPolPremAllocList.FIRST .. pPolPremAllocList.LAST
      INSERT INTO ILP_T_POL_PREM_ALLOC
        (PROCESS_ID,
         POLICY_NO,
         CONTRACT_ID,
         APPLICATION_ID,
         REQUEST_ID,
         PREMIUM_TYPE,
         SEQ,
         START_DATE,
         FUND_GROUP_ID,
         FUND_ID,
         PERCENT_INVEST,
         AMOUNT,
         INVEST_ID,
         STATUS,
         STATUS_DATE,
         CREATE_USER,
         CREATE_DATE,
         UPDATE_USER,
         UPDATE_DATE)
      VALUES
        (pPolPremAllocList(i).process_id,
         pPolPremAllocList(i).policy_no,
         pPolPremAllocList(i).contract_id,
         pPolPremAllocList(i).application_id,
         pPolPremAllocList(i).request_id,
         pPolPremAllocList(i).premium_type,
         pPolPremAllocList(i).seq,
         pPolPremAllocList(i).start_date,
         pPolPremAllocList(i).fund_group_id,
         pPolPremAllocList(i).fund_id,
         pPolPremAllocList(i).percent_invest,
         pPolPremAllocList(i).amount,
         pPolPremAllocList(i).invest_id,
         pPolPremAllocList(i).status,
         pPolPremAllocList(i).status_date,
         pPolPremAllocList(i).create_user,
         pPolPremAllocList(i).create_date,
         pPolPremAllocList(i).update_user,
         pPolPremAllocList(i).update_date);
  
  END;

  PROCEDURE preparePolPremAllocList(pProcessId        IN NUMBER,
                                    pContractId       IN NUMBER,
                                    pPolicyNo         IN VARCHAR2,
                                    pApplicationId    IN NUMBER,
                                    pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                                    pUpdateUser       IN VARCHAR2) IS
  
    lCurDate DATE := sysdate;
    lFunc    VARCHAR2(50) := 'ILP_PK_TOPUP.preparePolPremAllocList';
  
  BEGIN
  
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'pProcessId: ' || pProcessId || ', pPolicyNo: ' ||
                            pPolicyNo || ', pApplicationId: ' ||
                            pApplicationId || ', pUpdateUser: ' ||
                            pUpdateUser);
  
    FOR i IN pPolPremAllocList.FIRST .. pPolPremAllocList.LAST LOOP
      pPolPremAllocList(i).process_id := pProcessId;
      pPolPremAllocList(i).policy_no := pPolicyNo;
      pPolPremAllocList(i).contract_id := pContractId;
      pPolPremAllocList(i).application_id := pApplicationId;
      pPolPremAllocList(i).create_user := pUpdateUser;
      pPolPremAllocList(i).create_date := lCurDate;
      pPolPremAllocList(i).update_user := pUpdateUser;
      pPolPremAllocList(i).update_date := lCurDate;
    END LOOP;
  
  END;
  PROCEDURE deletePolPremAlloc(pContractId IN NUMBER) IS
  
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.deletePolPremAlloc';
  
  BEGIN
    az_pk0_general.logTrace(lFunc, pContractId, '');
  
    DELETE FROM ILP_T_POL_PREM_ALLOC t
     WHERE t.Contract_Id = pContractId
       AND t.application_id IS NOT NULL;
  
  END;
  PROCEDURE savePolPremAlloc(pProcessId        IN NUMBER,
                             pContractId       IN NUMBER,
                             pPolicyNo         IN VARCHAR2,
                             pApplicationId    IN NUMBER,
                             pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                             pUpdateUser       IN VARCHAR2) IS
  
    lFunc VARCHAR2(50) := lPackageName || '.savePolPremAlloc';
  
  BEGIN
  
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'pProcessId: ' || pProcessId || ', pPolicyNo: ' ||
                            pPolicyNo || ', pApplicationId: ' ||
                            pApplicationId || ', pUpdateUser: ' ||
                            pUpdateUser);
  
    preparePolPremAllocList(pProcessId,
                            pContractId,
                            pPolicyNo,
                            pApplicationId,
                            pPolPremAllocList,
                            pUpdateUser);
    deletePolPremAlloc(pContractId);
    insertPolPremAlloc(pProcessId, pContractId, pPolPremAllocList);
  
  END;
  FUNCTION saveTopup(pProcessId in number, pUpdateUser in VARCHAR2)
    RETURN NUMBER is
    lContractId       VARCHAR2(200);
    lRequestId        VARCHAR2(200);
    lPolicyDetailRow  ILP_T_POL_DETAIL%ROWTYPE;
    lPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    lFunc             VARCHAR2(50) := lPackageName || '.saveTopup';
    lErrors           wtErrorList := wtErrorList();
  
  begin
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Start Save Topup for process_id: ' ||
                            pProcessId);
  
    lContractId := getContractId(pProcessId);
  
    lRequestId := getRequestId(pProcessId);
  
    lPolicyDetailRow := getPolicyDetailRow(pProcessId, lContractId);
  
    lPolPremAllocList := getPolicyPremAllocList(pProcessId, lContractId);
    validatePremAmount(lContractId, lPolPremAllocList, lErrors);
    IF (lErrors.COUNT > 0) THEN
      az_pk0_general.logTrace(lFunc,
                              lContractId,
                              'Process id: ' ||
                              '=> Found error in validation!!!');
      return - 1;
    END IF;
    savePremToPolDetail(pProcessId,
                        lContractId,
                        lRequestId,
                        lPolicyDetailRow.Application_Id,
                        lPolicyDetailRow.Policy_No,
                        lPolicyDetailRow.Auto_Rebalance_Flag,
                        lPolicyDetailRow.Auto_Rebalance_Month,
                        lPolicyDetailRow.Deduct_Dividend_Fund,
                        pUpdateUser,
                        0);
  
    savePolPremAlloc(pProcessId,
                     lContractId,
                     lPolicyDetailRow.Policy_No,
                     lPolicyDetailRow.Application_Id,
                     lPolPremAllocList,
                     pUpdateUser);
  
    IF lErrors.count > 0 THEN
      ilp_pk_process.addErrorsToTable(pProcessId, lErrors);
      RETURN - 1;
    END IF;
  
    RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 2;
    
  end;

end ILP_PK_TOPUP;
/
