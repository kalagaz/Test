/* DynamicDataSet.p -- creates a dynamic DataSet and Data-Sources, fills it for 
   a key value passed in, and returns it. */
   
DEFINE INPUT PARAMETER pcBuffers    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcFields     AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcSources    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcSourceKeys AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcKeyValue   AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER DATASET-HANDLE phDataSet.

DEFINE VARIABLE iEntry      AS INTEGER NO-UNDO.
DEFINE VARIABLE hDataSource AS HANDLE  NO-UNDO.
DEFINE VARIABLE hBuffer     AS HANDLE  NO-UNDO.
DEFINE VARIABLE hQuery      AS HANDLE  NO-UNDO.

CREATE DATASET phDataSet.
DO iEntry = 1 TO NUM-ENTRIES(pcBuffers):
  phDataSet:ADD-BUFFER(WIDGET-HANDLE(ENTRY(iEntry, pcBuffers))).
END.
phDataSet:ADD-RELATION(phDataSet:GET-BUFFER-HANDLE(1),
                       phDataSet:GET-BUFFER-HANDLE(2),
                       pcFields).
                       
DO iEntry = 1 TO NUM-ENTRIES(pcSources):
  CREATE DATA-SOURCE hDataSource.
  CREATE BUFFER hBuffer FOR TABLE ENTRY(iEntry, pcSources).
  hDataSource:ADD-SOURCE-BUFFER(hBuffer, ENTRY(iEntry,pcSourceKeys)).
  phDataSet:GET-BUFFER-HANDLE(iEntry):ATTACH-DATA-SOURCE(hDataSource).
 
  IF iEntry = 1 THEN DO:
    CREATE QUERY hQuery.
    hQuery:ADD-BUFFER(hBuffer).
    hQuery:QUERY-PREPARE("FOR EACH " + ENTRY(1, pcSources) +
      " WHERE " + ENTRY(1, pcSourceKeys) + " = " + pcKeyValue).
    hDataSource:QUERY = hQuery.
  END. /* DO IF iEntry = 1 */
END. /* DO iEntry = 1 TO NUM-ENTRIES */
phDataSet:FILL().

DELETE OBJECT hQuery.
DO iEntry = 1 TO phDataSet:NUM-BUFFERS:
  hBuffer = phDataSet:GET-BUFFER-HANDLE(iEntry).
  DELETE OBJECT hBuffer:DATA-SOURCE.
END.
