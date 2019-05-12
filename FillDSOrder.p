/* fillDSOrder.p -- Test procedure for an Order Dataset for OpenEdge 10 */
{dsOrderTT.i}
{dsOrder.i}

DEFINE INPUT PARAMETER piOrderNum AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER DATASET FOR dsOrder.

DEFINE QUERY qOrder FOR Order, Customer, SalesRep. 
DEFINE QUERY qItem  FOR ITEM.                      

DEFINE DATA-SOURCE srcOrder FOR QUERY qOrder                                  
  Order KEYS (OrderNum), Customer KEYS (CustNum), SalesRep KEYS (SalesRep). 

DEFINE DATA-SOURCE srcOline FOR OrderLine KEYS (OrderNum).
DEFINE DATA-SOURCE srcItem FOR ITEM KEYS (ItemNum).

QUERY qOrder:QUERY-PREPARE("FOR EACH Order WHERE Order.OrderNum = " +
  STRING(piOrderNum) + ", FIRST Customer OF Order, FIRST SalesRep OF Order").

BUFFER ttOrder:ATTACH-DATA-SOURCE
  (DATA-SOURCE srcOrder:HANDLE, "Customer.Name,CustName").
BUFFER ttOline:ATTACH-DATA-SOURCE(DATA-SOURCE srcOline:HANDLE).
BUFFER ttItem:ATTACH-DATA-SOURCE(DATA-SOURCE srcItem:HANDLE).

DATASET dsOrder:FILL().

BUFFER ttOrder:DETACH-DATA-SOURCE().
BUFFER ttOline:DETACH-DATA-SOURCE().
BUFFER ttItem:DETACH-DATA-SOURCE().

/* 
FOR EACH ttOrder:
  DISPLAY 
    ttOrder.OrderNum
    ttOrder.OrderDate
    ttOrder.CustName FORMAT "X(15)"
    ttOrder.RepName FORMAT "X(15)".
END.
FOR EACH ttOline:
  DISPLAY 
    ttOline.OrderNum
    ttOline.LineNum.
END.
FOR EACH ttItem:
  DISPLAY ttItem.ItemNum ttItem.ItemName.
END.
*/
