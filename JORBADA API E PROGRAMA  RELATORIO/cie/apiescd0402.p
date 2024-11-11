
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apiescd0402 2.00.00.002 } /*** "010002" ***/
{include/i-license-manager.i apiescd0402 MCD}

{method/dbotterr.i}

{utp/ut-glob.i}

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as INTEGER
    FIELD it-codigo-ini    AS CHAR
    FIELD it-codigo-fim    AS CHAR 
    FIELD c-class-ini      LIKE ITEM.class-fiscal    
    FIELD c-class-fim      LIKE ITEM.class-fiscal.
    
           
    
define temp-table tt-digita no-undo
    field ge-codigo            LIKE grup-estoque.ge-codigo
    field descricao            LIKE grup-estoque.descricao
    index id ge-codigo.

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.    
   

 
/*:T--- FUNCTIONS ---*/



FUNCTION fn-get-id-from-path RETURNS CHARACTER (
    INPUT oRequest AS JsonAPIRequestParser
):

    RETURN STRING(oRequest:getPathParams():GetCharacter(1)).
    
END FUNCTION.  

FUNCTION fn-has-row-errors RETURNS LOGICAL ():

    FOR EACH RowErrors 
        WHERE UPPER(RowErrors.ErrorType) = 'INTERNAL':U:
        DELETE RowErrors. 
    END.

    RETURN CAN-FIND(FIRST RowErrors 
        WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U).
    
END FUNCTION.



PROCEDURE piCriaRelatorio:
 DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
 DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
 DEFINE OUTPUT PARAM TABLE FOR RowErrors.
 
 DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
 DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
 DEFINE VARIABLE oPayload  AS JsonObject           NO-UNDO.
  
 DEFINE VARIABLE pClassFiscalIni AS CHARACTER   NO-UNDO.
 DEFINE VARIABLE pClassFiscalFim AS CHARACTER   NO-UNDO.
 DEFINE VARIABLE pitCodigoIni AS CHARACTER   NO-UNDO.
 DEFINE VARIABLE pitCodigoFim AS CHARACTER   NO-UNDO.
 
 DEFINE VARIABLE mStorage AS MEMPTR  NO-UNDO.
 DEFINE VARIABLE vRelatorio AS LONGCHAR NO-UNDO.
    
 ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
 ASSIGN oPayload = oRequest:getPayload().
 
 
  ASSIGN pClassFiscalIni             = oPayload:getCharacter("classFiscalIni")     WHEN oPayload:has("classFiscalIni")                          
         pClassFiscalFim             = oPayload:getCharacter("classFiscalFim")     WHEN oPayload:has("classFiscalFim")  
         pitCodigoIni                = oPayload:getCharacter("itCodigoIni")      WHEN oPayload:has("itCodigoIni")                          
         pitCodigoFim                = oPayload:getCharacter("itCodigoFim")      WHEN oPayload:has("itCodigoFim") .
    
    
    create tt-param.
    assign tt-param.usuario         = c-seg-usuario
           tt-param.destino         = 3
           tt-param.data-exec       = today
           tt-param.hora-exec       = time.
           
    ASSIGN tt-param.arquivo = session:temp-directory + "escd0402_" + c-seg-usuario + ".xml".
     /* Coloque aqui a l½gica de grava»’o dos par³mtros e sele»’o na temp-table
       tt-param */ 
       
   assign tt-param.it-codigo-ini  = pitCodigoIni        
          tt-param.it-codigo-fim  = pitCodigoFim       
          tt-param.c-class-ini  = pClassFiscalIni        
          tt-param.c-class-fim  = pClassFiscalFim .

    raw-transfer tt-param    to raw-param.
    
    RUN esp/escd0402rp.p  (INPUT raw-param,
                           INPUT table tt-raw-digita).      
                           
    COPY-LOB FROM FILE tt-param.arquivo TO mStorage .
     vRelatorio = BASE64-ENCODE(mStorage).
     
     oOutput = NEW JsonObject().
     
     oOutput:ADD('pRelatorio', vRelatorio ).
     oOutput:ADD('pNomeArquivo', 'escd0402.xml').                                      
    
      

    
CATCH eSysError AS Progress.Lang.SysError:
    CREATE RowErrors.
    ASSIGN RowErrors.ErrorNumber = 17006
           RowErrors.ErrorDescription = eSysError:getMessage(1)
           RowErrors.ErrorSubType = "ERROR".
END.
FINALLY: 
    IF fn-has-row-errors() THEN DO:
        UNDO, RETURN 'NOK':U.
    END.
END FINALLY.


END PROCEDURE.
