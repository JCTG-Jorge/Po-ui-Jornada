
USING Progress.Lang.Error.
USING com.totvs.framework.api.JsonApiResponseBuilder.

{utp/ut-api.i}
{utp/ut-api-utils.i}

{include/i-prgvrs.i escd0402ws 2.00.00.001 } /*** "010001" ***/

{utp/ut-api-action.i piExecutar  POST /~*}
{utp/ut-api-notfound.i}

 DEFINE VARIABLE apiHandler AS HANDLE NO-UNDO.


PROCEDURE piExecutar:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.


    DEFINE VARIABLE lHasNext    AS LOGICAL   INITIAL FALSE  NO-UNDO.
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.


    RUN  cie/apiescd0402.p PERSISTENT SET apiHandler. 

    oOutput = NEW JsonObject().

    IF VALID-HANDLE(apiHandler) THEN
        RUN  piCriaRelatorio IN apiHandler (INPUT oInput,
                                            OUTPUT oOutput,
                                            OUTPUT TABLE RowErrors ).
                                          
    
    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'WARNING':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asWarning(aOutput, lHasNext, TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(oOutput).
    END.

    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    
    FINALLY:
        DELETE PROCEDURE apiHandler NO-ERROR. 
    END FINALLY.

    

END PROCEDURE.
