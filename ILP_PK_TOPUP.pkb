create or replace package body ILP_PK_TOPUP is
  lPackageName VARCHAR2(50) := 'ILP_PK_TOPUP';

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
  
    lParamValue := ilp_pk_process.GetParamValue(pProcessId,
                                                'POL_PREM_ALLOC');
    RETURN ILP_PK_XML_CONVERTER.GET_ILP_PREM_TABLE_FROM_XML(xmltype(lParamValue),
                                                            pContractId);
  
  END getPolicyPremAllocList;

  FUNCTION saveTopup(pProcessId in number) RETURN NUMBER is
    lContractId       VARCHAR2(200);
    lPolicyDetailRow  ILP_T_POL_DETAIL%ROWTYPE;
    lPolPremAllocList ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
    lFunc             VARCHAR2(50) := lPackageName || '.saveTopup';
    lErrors           wtErrorList := wtErrorList();
  begin
    az_pk0_general.logTrace(lFunc,
                            0,
                            'Start Save Topup for process_id: ' ||
                            pProcessId);
  
    lContractId := ilp_pk_process.getParamValue(pProcessId, 'CONTRACT_ID');
  
    lPolicyDetailRow := getPolicyDetailRow(pProcessId, lContractId);
    lPolPremAllocList := getPolicyPremAllocList(pProcessId, lContractId);
  
    if lContractId = '1000000' then
      return - 1;
    end if;
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
