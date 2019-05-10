/* CodeSource.p -- Data-Source definitions and FILL logic for code tables */
DEFINE DATA-SOURCE srcRep   FOR SalesRep.
DEFINE DATA-SOURCE srcDept  FOR Department.
DEFINE DATA-SOURCE srcState FOR State.

PROCEDURE postRepRowFill:
  DEFINE INPUT PARAMETER DATASET-HANDLE phDataSet.

  DEFINE VARIABLE hSalesRep     AS HANDLE  NO-UNDO.
  DEFINE VARIABLE dTotalQuota   AS DECIMAL NO-UNDO.
  DEFINE VARIABLE dTotalBalance AS DECIMAL NO-UNDO.
  DEFINE VARIABLE iMonth        AS INTEGER NO-UNDO.

  hSalesRep = phDataSet:GET-BUFFER-HANDLE("ttSalesRep").
  DO iMonth = 1 TO 12:
    dTotalQuota = dTotalQuota + SalesRep.MonthQuota[iMonth].
  END.

  hSalesRep:BUFFER-FIELD("AnnualQuota"):BUFFER-VALUE = dTotalQuota.
  FOR EACH Customer WHERE Customer.SalesRep =
    STRING(hSalesRep:BUFFER-FIELD("RepCode"):BUFFER-VALUE):
    dTotalBalance = dTotalBalance + Customer.Balance.
  END.
  hSalesRep:BUFFER-FIELD("TotalBalance"):BUFFER-VALUE = dTotalBalance.
END PROCEDURE. /* postRepRowFill */

FUNCTION attachDataSet RETURNS LOGICAL (INPUT phDataSet AS HANDLE):
  phDataSet:GET-BUFFER-HANDLE("ttSalesRep"):SET-CALLBACK-PROCEDURE
    ("AFTER-ROW-FILL", "postRepRowFill", THIS-PROCEDURE).
  phDataSet:GET-BUFFER-HANDLE("ttSalesRep"):ATTACH-DATA-SOURCE
    (DATA-SOURCE srcRep:HANDLE, "SalesRep.SalesRep,RepCode").
  phDataSet:GET-BUFFER-HANDLE("ttState"):ATTACH-DATA-SOURCE
    (DATA-SOURCE srcState:HANDLE).
  phDataSet:GET-BUFFER-HANDLE("ttDept"):ATTACH-DATA-SOURCE
    (DATA-SOURCE srcDept:HANDLE).
  RETURN phDataSet:ERROR.
END FUNCTION. /* attachDataSet */

FUNCTION detachDataSet RETURNS LOGICAL (INPUT phDataSet AS HANDLE):
  phDataSet:GET-BUFFER-HANDLE("ttSalesRep"):DETACH-DATA-SOURCE().
  phDataSet:GET-BUFFER-HANDLE("ttState"):DETACH-DATA-SOURCE().
  phDataSet:GET-BUFFER-HANDLE("ttDept"):DETACH-DATA-SOURCE().
  RETURN phDataSet:ERROR.
END FUNCTION. /* detachDataSet */
