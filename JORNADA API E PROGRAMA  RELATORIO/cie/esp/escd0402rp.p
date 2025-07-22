/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

BLOCK-LEVEL ON ERROR UNDO, THROW.
CURRENT-LANGUAGE = CURRENT-LANGUAGE.

{include/i-prgvrs.i ATP0105RP 2.00.01.012}  /*** 010112 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i pl0504rp MPL}
&ENDIF

/****************************************************************************
**
**       Programa: escd0402rp.p
**
**       Data....: Julho de 2019.
**
**       Autor...: Jorge - TOTVS TNU.
**
**       Objetivo: Exporta‡Æo Class fiscal
**
**       Versao..: 
**                 
*****************************************************************************/
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

def temp-table tt-raw-digita
   field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.


DEF TEMP-TABLE ttRelatorio    no-undo
   FIELD it-codigo LIKE ITEM.it-codigo
   FIELD desc-item LIKE item.desc-item 
   FIELD ge-codigo LIKE ITEM.ge-codigo
   FIELD class-fiscal LIKE item.class-fiscal.
  
def new global shared var c-dir-spool-servid-exec as CHAR no-undo.

DEF VAR hApi AS HANDLE NO-UNDO.      
DEF VAR cFile AS CHAR .   


create tt-param.
raw-transfer raw-param to tt-param.

FOR EACH tt-raw-digita:

    CREATE tt-digita.
    raw-transfer tt-raw-digita.raw-digita to tt-digita.

END.

DEF VAR h-acomp AS HANDLE NO-UNDO.

FIND FIRST tt-param NO-LOCK NO-ERROR.


run utp/ut-acomp.p persistent set h-acomp.



run pi-inicializar in h-acomp (input "Exportando class fiscal").

RUN processa.

run pi-finalizar in h-acomp.

return "OK".

PROCEDURE processa:
   DEF VAR iTab AS INTEGER NO-UNDO.
   
   DEFINE VARIABLE lShow AS LOGICAL     NO-UNDO.
   DEF VAR vCont AS INT NO-UNDO.
   
   
   lShow = YES.  
   
   
   
   IF OPSYS <> "UNIX" THEN DO:
        ASSIGN cFile  = SESSION:TEMP-DIR + "escd0402_" + c-seg-usuario + ".xml"  .        
   END.
   ELSE
   DO:
       ASSIGN cFile  = tt-param.arquivo. 
       lShow = NO.
   END.
   
  
   IF i-num-ped-exec-rpw > 0 THEN
   DO:
       ASSIGN
       cFile = c-dir-spool-servid-exec + "/" + "escd0402_" + c-seg-usuario + ".xml"
       lShow = NO.
   END.
   
   
   ASSIGN iTab = 1 
   vCont =  0.
       
    
    
    FOR EACH ITEM
       WHERE ITEM.it-codigo    >=  tt-param.it-codigo-ini  
       AND   ITEM.it-codigo    <=  tt-param.it-codigo-fim  
       AND   ITEM.class-fiscal >= tt-param.c-class-ini       
       AND   ITEM.class-fiscal <= tt-param.c-class-fim  NO-LOCK:


        run pi-acompanhar in h-acomp (INPUT "Item: " + item.it-codigo).
        vCont = vCont + 1.

       IF vCont > 64997 THEN LEAVE.
        
        CREATE ttRelatorio.
        ASSIGN ttRelatorio.it-codigo    = item.it-codigo
               ttRelatorio.desc-item    = item.desc-item 
               ttRelatorio.ge-codigo    = ITEM.ge-codigo  
               ttRelatorio.class-fiscal = ITEM.class-fiscal.  

    END.
    
        
   
   RUN utp/utapi033.p PERSISTENT SET hApi.  

    RUN piNewWorksheetbyTT IN hApi (
        INPUT "escd0402", INPUT "Relatorio Classifica‡Æo Fiscal",
        INPUT BUFFER ttRelatorio:HANDLE, 
        ?, 
        ?). 

    RUN ConvertToXls IN hApi (NO).
    RUN show IN hApi (lShow).

    RUN piProcessa IN hApi (
        INPUT-OUTPUT cFile, 
        INPUT "", 
        INPUT "") .
     
    FINALLY: 
         DELETE PROCEDURE hApi NO-ERROR.                  
      
    END FINALLY.
    
    

END PROCEDURE.


