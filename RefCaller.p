/* refCaller.p */
{dsOrderTT.i}
{dsOrder.i}

DEFINE VARIABLE hProc AS HANDLE NO-UNDO.

RUN refCallee.p PERSISTENT SET hProc.
MESSAGE "In the calling proc, dsOrder is " DATASET dsOrder:HANDLE VIEW-AS ALERT-BOX.
RUN fillProc IN hProc (OUTPUT DATASET dsOrder BY-REFERENCE).
