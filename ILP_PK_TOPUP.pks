create or replace package ILP_PK_TOPUP is

  -- Author  : NATTAPORNCH
  -- Created : 12/16/2015 15:15 PM
  -- Purpose : Package for add TOPUP information

  FUNCTION saveTopup(pProcessId in number) RETURN NUMBER;

end ILP_PK_TOPUP;
