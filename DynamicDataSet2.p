/* DynamicDataSet2.p -- creates a dynamic DataSet and Data-Sources, fills it 
   for a key value passed in, and returns it. */
DEFINE INPUT  PARAMETER pcSources    AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER pcSourceKeys AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER pcFields     AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER pcKeyValue   AS CHARACTER  NO-UNDO.
DEFINE OUTPUT PARAMETER DATASET-HANDLE phDataSet.

DEFINE VARIABLE iEntry      AS INTEGER    NO-UNDO.
DEFINE VARIABLE hDataSource AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBuffer     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hQuery      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hTable      AS HANDLE     NO-UNDO.

CREATE DATASET phDataSet.

DO iEntry = 1 TO NUM-ENTRIES(pcSources):
  CREATE TEMP-TABLE hTable.
  hTable:CREATE-LIKE(ENTRY(iEntry, pcSources)).
  hTable:TEMP-TABLE-PREPARE("tt" + ENTRY(iEntry, pcSources)).
  phDataSet:ADD-BUFFER(hTable:DEFAULT-BUFFER-HANDLE).
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
                         " WHERE " + ENTRY(1, pcSourceKeys) + pcKeyValue).
    hDataSource:QUERY = hQuery.
  END.
END.
    
phDataSet:FILL().
DELETE OBJECT hQuery.

DO iEntry = 1 TO phDataSet:NUM-BUFFERS:
  hBuffer = phDataSet:GET-BUFFER-HANDLE(iEntry).
  MESSAGE "Data-Source: "
    hBuffer:DATA-SOURCE:GET-SOURCE-BUFFER:NAME SKIP
    "WHERE-STRING:" hBuffer:DATA-SOURCE:FILL-WHERE-STRING
    VIEW-AS ALERT-BOX.
  DELETE OBJECT hBuffer:DATA-SOURCE.
END.
