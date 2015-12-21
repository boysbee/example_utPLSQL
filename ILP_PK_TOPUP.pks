CREATE OR REPLACE PACKAGE ILP_PK_TOPUP IS

  -- AUTHOR  : NATTAPORNCH
  -- CREATED : 12/16/2015 15:15 PM
  -- PURPOSE : PACKAGE FOR ADD TOPUP INFORMATION

  FUNCTION SAVETOPUP(PPROCESSID IN NUMBER) RETURN NUMBER;
  FUNCTION GETPARAM(PPROCID IN NUMBER, PKEY IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION GETCONTRACTID(PPROCESSID IN NUMBER) RETURN VARCHAR2;
  FUNCTION GETREQUESTID(PPROCESSID IN NUMBER) RETURN VARCHAR2;
  FUNCTION getPolicyPremAllocList(pProcessId  IN NUMBER,
                                  pContractId IN NUMBER)
    RETURN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE;
  PROCEDURE SAVEPREMTOPOLDETAIL(PPROCESSID          IN NUMBER,
                                PCONTRACTID         IN NUMBER,
                                PREQUESTID          IN NUMBER,
                                PAPPLICATIONID      IN NUMBER,
                                PPOLICYNO           IN VARCHAR2,
                                PAUTOREFLAG         IN VARCHAR2,
                                PAUTOREMONTH        IN NUMBER,
                                PDEDUCTDEVIDENDFUND IN VARCHAR2,
                                PUPDATEUSER         IN VARCHAR2,
                                PTOPUPAMOUNT        IN NUMBER);
  PROCEDURE savePolPremAlloc(pProcessId        IN NUMBER,
                             pContractId       IN NUMBER,
                             pPolicyNo         IN VARCHAR2,
                             pApplicationId    IN NUMBER,
                             pPolPremAllocList IN OUT ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE,
                             pUpdateUser       IN VARCHAR2);
  FUNCTION getPolPreAllc(pProcessId IN NUMBER) return VARCHAR2;
  FUNCTION validatePremAmount(pContractId    IN VARCHAR2,
                              pPremAllocList IN ILP_PK_TYPE.ILP_T_POL_PREM_ALLOC_TABLE)
    return BOOLEAN;

END ILP_PK_TOPUP;
