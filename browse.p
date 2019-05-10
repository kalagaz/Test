

DEFINE VAR method-return AS LOGICAL NO-UNDO.
DEFINE var v-pno as inte no-undo.
DEFINE BUTTON btn-new LABEL "New Row".
DEFINE BUTTON btn-ok  LABEL "Continue".
DEFINE BUTTON btn-cxl LABEL "Close".

DEF TEMP-TABLE tt-comp NO-UNDO
    FIELD p-ck AS logi 
    FIELD p-no AS INTE FORMAT ">>>9"
    FIELD p-name AS CHAR FORMAT "x(90)".

CURRENT-WINDOW:WIDTH = 113. 
 
DEFINE QUERY q1 FOR tt-comp SCROLLING.

DEFINE BROWSE b1 QUERY q1 NO-LOCK 
  DISPLAY tt-comp.p-ck column-label "SEL" view-as toggle-box 
  tt-comp.p-no column-label "PNO"
  tt-comp.p-name column-label "Program"
  ENABLE tt-comp.p-ck tt-comp.p-name
  WITH 15 DOWN NO-ASSIGN SEPARATORS centered.

DEFINE FRAME f1 
  SKIP(1) space(2)
  b1 
  space(2)SKIP(1) 
  btn-new at 38 space(3) 
  btn-ok space(3) 
  btn-cxl
  skip(1)
  WITH three-d centered title " Programs to Compile " width 111.
 
ON ROW-LEAVE OF b1 IN FRAME f1 
DO: 
  /* If new row, create record and assign values in browse. */
  IF b1:NEW-ROW THEN DO:
    find last tt-comp no-lock no-error.
    if available tt-comp
    then assign v-pno = tt-comp.p-no + 1.
    else assign v-pno = 1.
    CREATE tt-comp.
    assign tt-comp.p-no = v-pno
           tt-comp.p-ck = yes.
    DISPLAY tt-comp.p-no 
            tt-comp.p-ck 
            WITH BROWSE b1.
    ASSIGN INPUT BROWSE b1 tt-comp.p-ck tt-comp.p-name.
    method-return = b1:CREATE-RESULT-LIST-ENTRY().
    RETURN.
  END.
  
  /* If record exists and was changed in browse, update it. */
  IF BROWSE b1:CURRENT-ROW-MODIFIED THEN DO:
    GET CURRENT q1 EXCLUSIVE-LOCK.
    IF CURRENT-CHANGED tt-comp THEN DO:
      MESSAGE "This record has been changed by another user." SKIP
        "Please re-enter your changes.".
      DISPLAY tt-comp.p-ck tt-comp.p-no tt-comp.p-name WITH BROWSE b1.
      RETURN NO-APPLY.
    END.
    ELSE /* Record is the same, so update it with exclusive-lock */
      ASSIGN INPUT BROWSE b1 tt-comp.p-ck tt-comp.p-name.
      /* Downgrade the lock to a no-lock. */
      GET CURRENT q1 NO-LOCK.
  END.
END.
 
ON CHOOSE OF btn-new IN FRAME f1 DO: /* Insert */
  method-return = b1:INSERT-ROW("AFTER").
END.
 
ON CHOOSE OF btn-cxl IN FRAME f1 
DO: 
   apply "window-close" to current-window.
END.
 
OPEN QUERY q1 FOR EACH tt-comp.
ENABLE ALL WITH FRAME f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW
