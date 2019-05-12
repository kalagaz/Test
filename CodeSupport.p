/* CodeSupport.p -- support procedures for dsCode tables */
{dsCodeTT.i}
{dsCode.i}

DEFINE VARIABLE hSourceProc AS HANDLE  NO-UNDO.
DEFINE VARIABLE lError      AS LOGICAL NO-UNDO.
DEFINE VARIABLE hCodeSet    AS HANDLE  NO-UNDO.
DEFINE VARIABLE hCodeSource AS HANDLE  NO-UNDO.

ON CLOSE OF THIS-PROCEDURE DO:
  DYNAMIC-FUNCTION("detachDataSet" IN hSourceProc, INPUT hCodeSet).
  DELETE PROCEDURE hSourceProc.
  DELETE PROCEDURE THIS-PROCEDURE.
END.

hCodeSet = DATASET dsCode:HANDLE.
RUN CodeSource.p PERSISTENT SET hSourceProc.
lError = DYNAMIC-FUNCTION ("attachDataSet" IN hSourceProc, hCodeSet).
hCodeSet:FILL().

PROCEDURE fetchCodeTables:
  DEFINE INPUT PARAMETER pcTables AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER DATASET-HANDLE phDynData.

  DEFINE VARIABLE iTable    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE cTable    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE hTableBuf AS HANDLE    NO-UNDO.

  CREATE DATASET phDynData.
  DO iTable = 1 TO NUM-ENTRIES(pcTables):
    cTable = ENTRY(iTable,pcTables).
    CREATE BUFFER hTableBuf FOR TABLE cTable.
    phDynData:ADD-BUFFER(hTableBuf).
  END.
END PROCEDURE. /* fetchCodeTables */

PROCEDURE fetchCustomTable:
  DEFINE INPUT PARAMETER pcTable     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pcFields    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pcSelection AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER DATASET-HANDLE phFilterData.

  DEFINE VARIABLE iField  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE cField  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE hTable  AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hNewBuf AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hOldBuf AS HANDLE    NO-UNDO.

  /* Create a new dynamic ProDataSet based on the table and fields passed in. */
  CREATE DATASET phFilterData.
  CREATE TEMP-TABLE hTable.

  DO iField = 1 TO NUM-ENTRIES(pcFields):
    cField = ENTRY(iField,pcFields).
    hTable:ADD-LIKE-FIELD(cField,pcTable + "." + cField).
  END.

  hTable:TEMP-TABLE-PREPARE(pcTable).
  hNewBuf = hTable:DEFAULT-BUFFER-HANDLE.
  phFilterData:ADD-BUFFER(hNewBuf).

  /* Next create a dynamic query for the selection criteria passed in. */
  CREATE QUERY hQuery.
  hOldBuf = DATASET dsCode:GET-BUFFER-HANDLE(pcTable).
  hQuery:ADD-BUFFER(hOldBuf).
  hQuery:QUERY-PREPARE("FOR EACH " + pcTable + " WHERE " + pcSelection).
  /* 
  hQuery:QUERY-OPEN().
  hQuery:GET-FIRST().
  DO WHILE NOT hQuery:QUERY-OFF-END:
    hNewBuf:BUFFER-CREATE().
    hNewBuf:BUFFER-COPY(hOldBuf).
    hQuery:GET-NEXT().
  END. 
  */

  CREATE DATA-SOURCE hCodeSource.
  /* NOTE: hOldBuf is the source temp-table buffer, and the KEYS list is not 
     needed */
  hCodeSource:ADD-SOURCE-BUFFER(hOldBuf, ?).
  /* Because there is a specific query for selecting a subset of the rows in 
     the source temp-table, the procedure uses the dynamic query defined above. 
     Otherwise it could leave off the query and get all rows automatically. */
  hCodeSource:QUERY = hQuery.
  /* Now when it attaches the Data-Source and fills the new ProDataSet it gets
     rows from its Data-Source, which is the table in the original ProDataSet. */
  hNewBuf:ATTACH-DATA-SOURCE(hCodeSource).
  phFilterData:FILL().
  hNewBuf:DETACH-DATA-SOURCE().
  /* This is the end of the alternative code to use the original ProDataSet as a
     Data-Source for the custom subset. */

  DELETE OBJECT phFilterData.
  DELETE OBJECT hCodeSource.
  DELETE OBJECT hQuery.
END PROCEDURE. /* fetchCustomTable */
