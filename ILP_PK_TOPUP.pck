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

  FUNCTION getTopupAmount(pProcessId IN NUMBER)
    RETURN ILP_T_POL_DETAIL.Topup_Amount%TYPE;

  PROCEDURE savePremToPolDetail(pProcessId   IN NUMBER,
                                pContractId  IN NUMBER,
                                pRequestId   IN NUMBER,
                                pPolicyNo    IN VARCHAR2,
                                pUpdateUser  IN VARCHAR2,
                                pTopupAmount IN NUMBER);

  PROCEDURE savePolPremAlloc(pProcessId        IN NUMBER,
                             pContractId       IN NUMBER,
                             pRequestId        IN NUMBER,
                             pPolicyNo         IN VARCHAR2,
                             pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                             pUpdateUser       IN VARCHAR2);

  FUNCTION getPolPreAllc(pProcessId IN NUMBER) RETURN VARCHAR2;

  PROCEDURE validatePremAmount(pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                               pErrors        IN OUT wtErrorList);

  FUNCTION remvInvestZeroPolPremAllocList(pPolPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE)
    return ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;

END ILP_PK_TOPUP;
/
CREATE OR REPLACE PACKAGE BODY ILP_PK_TOPUP IS
  lPackageName VARCHAR2(50) := 'ILP_PK_TOPUP';
  --TYPE tNumberCollection IS TABLE OF NUMBER INDEX BY VARCHAR2(64);
  FUNCTION getParam(pProcId IN NUMBER, pKey IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ILP_PK_PROCESS.GetParamValue(pProcId, pKey);
  END;

  FUNCTION getTopupAmount(pProcessId IN NUMBER)
    RETURN ILP_T_POL_DETAIL.Topup_Amount%TYPE IS
  
    lFunc VARCHAR2(100) := 'ILP_PK_TOPUP.getTopupAmount';
  
  BEGIN
  
    az_pk0_general.logTrace(lFunc, 0, 'Process Id: ' || pProcessId);
    RETURN to_number(ILP_PK_PROCESS.GetParamValue(pProcessId,
                                                  'TOPUP_AMOUNT'));
    --RETURN ILP_PK_XML_CONVERTER.GET_POL_DETAIL(lParamValue, pContractId);
  
  END getTopupAmount;

  FUNCTION getPolPreAllc(pProcessId IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN getParam(pProcessId, 'POL_PREM_ALLOC');
  END;

  FUNCTION getPolicyPremAllocList(pProcessId  IN NUMBER,
                                  pContractId IN NUMBER)
    RETURN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE IS
    lParamValue VARCHAR2(4000);
    lFunc       VARCHAR2(100) := 'ILP_PK_TOPUP.getPolicyPremAllocList';
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

  PROCEDURE validateSumValue(sumAlloc IN NUMBER,
                             pErrors  IN OUT wtErrorList) IS
  BEGIN
    IF sumAlloc > 100 OR sumAlloc < 0 THEN
      plw_pk_errors.addError(pErrors,
                             'ERR',
                             'Fund percent allocated in TUP must between 0-100.(Current:' ||
                             sumAlloc || ')',
                             NULL,
                             NULL);
    END IF;
  END;

  PROCEDURE validateEachValue(pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                              sumAlloc       IN OUT NUMBER,
                              pErrors        IN OUT wtErrorList) IS
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.validateEachValue';
    pMinValue CONSTANT INTEGER := 0;
    pMaxValue CONSTANT INTEGER := 100;
  BEGIN
    FOR i IN 1 .. pPremAllocList.count LOOP
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
  END;

  PROCEDURE validatePremAmount(pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                               pErrors        IN OUT wtErrorList) IS
    lFunc    VARCHAR2(50) := 'ILP_PK_TOPUP.validatePremAmount';
    sumAlloc NUMBER := 0;
  BEGIN
    validateEachValue(pPremAllocList, sumAlloc, pErrors);
    validateSumValue(sumAlloc, pErrors);
  END;

  PROCEDURE savePremToPolDetail(pProcessId   IN NUMBER,
                                pContractId  IN NUMBER,
                                pRequestId   IN NUMBER,
                                pPolicyNo    IN VARCHAR2,
                                pUpdateUser  IN VARCHAR2,
                                pTopupAmount IN NUMBER) IS
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.savePremToPolDetail';
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'Process Id: ' || pProcessId || ' Request Id:' ||
                            pRequestId);
    INSERT INTO ilp_t_pol_detail
      (contract_id,
       policy_no,
       process_id,
       request_id,
       topup_amount,
       update_user,
       update_date)
    VALUES
      (pContractId,
       pPolicyNo,
       pProcessId,
       pRequestId,
       pTopupAmount,
       pUpdateUser,
       SYSDATE);
  END;

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
                                    pRequestId        IN NUMBER,
                                    pPolicyNo         IN VARCHAR2,
                                    pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                                    pUpdateUser       IN VARCHAR2) IS
    lCurDate DATE := SYSDATE;
    lFunc    VARCHAR2(50) := 'ILP_PK_TOPUP.preparePolPremAllocList';
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'pProcessId: ' || pProcessId || ', pPolicyNo: ' ||
                            pPolicyNo || ', pUpdateUser: ' || pUpdateUser);
    FOR i IN pPolPremAllocList.FIRST .. pPolPremAllocList.LAST LOOP
      pPolPremAllocList(i).process_id := pProcessId;
      pPolPremAllocList(i).policy_no := pPolicyNo;
      pPolPremAllocList(i).contract_id := pContractId;
      pPolPremAllocList(i).request_id := pRequestId;
      pPolPremAllocList(i).application_id := NULL;
      pPolPremAllocList(i).create_user := pUpdateUser;
      pPolPremAllocList(i).create_date := lCurDate;
      pPolPremAllocList(i).update_user := pUpdateUser;
      pPolPremAllocList(i).update_date := lCurDate;
    END LOOP;
  END;

  PROCEDURE deletePolPremAlloc(pContractId IN NUMBER, pRequestId IN NUMBER) IS
    lFunc VARCHAR2(50) := 'ILP_PK_TOPUP.deletePolPremAlloc';
  BEGIN
    az_pk0_general.logTrace(lFunc, pContractId, '');
    DELETE FROM ILP_T_POL_PREM_ALLOC t
     WHERE t.Contract_Id = pContractId
       AND t.request_id = pRequestId;
  END;

  PROCEDURE savePolPremAlloc(pProcessId        IN NUMBER,
                             pContractId       IN NUMBER,
                             pRequestId        IN NUMBER,
                             pPolicyNo         IN VARCHAR2,
                             pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                             pUpdateUser       IN VARCHAR2) IS
    lFunc VARCHAR2(50) := lPackageName || '.savePolPremAlloc';
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            pContractId,
                            'pProcessId: ' || pProcessId || ', pPolicyNo: ' ||
                            pPolicyNo || ', pUpdateUser: ' || pUpdateUser);
    preparePolPremAllocList(pProcessId,
                            pContractId,
                            pRequestId,
                            pPolicyNo,
                            pPolPremAllocList,
                            pUpdateUser);
    deletePolPremAlloc(pContractId, pRequestId);
    insertPolPremAlloc(pProcessId, pContractId, pPolPremAllocList);
  END;
  FUNCTION remvInvestZeroPolPremAllocList(pPolPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE)
    return ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE is
    resultFilter ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    lFunc        VARCHAR2(50) := 'ILP_PK_TOPUP.remvInvestZeroPolPremAllocList';
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Start remove percent invest zero from list.');
    resultFilter := ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE();
    FOR i IN pPolPremAllocList.FIRST .. pPolPremAllocList.LAST LOOP
      if pPolPremAllocList(i).percent_invest > 0 then
        resultFilter.extend;
         resultFilter(i) := pPolPremAllocList(i);
      end if;
    END LOOP;
  
    return resultFilter;
  END;
  FUNCTION saveTopup(pProcessId IN NUMBER, pUpdateUser IN VARCHAR2)
    RETURN NUMBER IS
    lContractId       VARCHAR2(200);
    lRequestId        VARCHAR2(200);
    lPolicyNo         VARCHAR2(20);
    lTopupAmount      ILP_T_POL_DETAIL.topup_amount%TYPE;
    lPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    preparePolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    lFunc             VARCHAR2(50) := lPackageName || '.saveTopup';
    lErrors           wtErrorList := wtErrorList();
  BEGIN
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Start Save Topup for process_id: ' ||
                            pProcessId);
    lContractId       := getContractId(pProcessId);
    lRequestId        := getRequestId(pProcessId);
    lPolicyNo         := ILP_PK_POLICY_INFO.getPolicyNoByContractIdInOCP(lContractId);
    lTopupAmount      := getTopupAmount(pProcessId);
    lPolPremAllocList := getPolicyPremAllocList(pProcessId, lContractId);
  
    validatePremAmount(lPolPremAllocList, lErrors);
  
    IF (lErrors.COUNT > 0) THEN
      az_pk0_general.logTrace(lFunc,
                              lContractId,
                              'Process id: ' ||
                              '=> Found error in validation!!!');
      RETURN 0;
    END IF;
  
    savePremToPolDetail(pProcessId,
                        lContractId,
                        lRequestId,
                        lPolicyNo,
                        pUpdateUser,
                        lTopupAmount);
    preparePolPremAllocList := remvInvestZeroPolPremAllocList(lPolPremAllocList);
    savePolPremAlloc(pProcessId,
                     lContractId,
                     lRequestId,
                     lPolicyNo,
                     preparePolPremAllocList,
                     pUpdateUser);
  
    IF lErrors.count > 0 THEN
      ilp_pk_process.addErrorsToTable(pProcessId, lErrors);
      RETURN 0;
    END IF;
  
    RETURN 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 2;
    
  END;

END ILP_PK_TOPUP;
/
