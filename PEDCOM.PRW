#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"



User Function PEDCOM(nOPC)

Local cPerg		:= "PEDCOM"
Private lEnd	:= .F.
Private cTitulo	:= "Pedido Compras"
Private _numpag := 1
Private _nLin   := 0 

Private _aPed   := {}
//nOPC := If(nOpc == Nil,2,nOpc)	
nOPC := 1
If nOPC == 2
	//??????????????????????
	//?Verifica / Cria Grupo de Perguntas (SX1) ?
	//??????????????????????
	//AjustaPerg(cPerg)
	If Pergunte(cPerg,.T.)
		//??????????????????????
		//?Gera array com dados para impressao      ?
		//??????????????????????
		GeraArray(MV_PAR01,MV_PAR02)
		RptStatus({|lEnd| RunImp()},cTitulo)
	EndIf
Else
	//??????????????????????
	//?Gera array com dados para impressao      ?
	//??????????????????????
	GeraArray(SC7->C7_NUM,SC7->C7_NUM)
	RptStatus({|lEnd| RunImp()},cTitulo)
Endif

Return Nil
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?GeraArray?Autor ?Wilson Cruz           ?Data ?16.10.10 ??
???????????????????????????????????????
??escri??o ?Gera array base para impressao                             ??
???????????????????????????????????????
??so       ?Inovalli                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function GeraArray(_cPedDe,_cPedAte)

Local _aArea  := GetArea()
Local _aForn  := {}
Local _cDesc  := ""
Local _cCompra := "" 

dbSelectArea("SC7")
dbSetOrder(1)
dbSeek(xFilial("SC7")+_cPedDe,.T.)
While !Eof() .and. SC7->C7_NUM >= _cPedDe .And. SC7->C7_NUM <= _cPedAte
	
	_aForn := GetAdvFVal("SA2",{"A2_NOME","A2_END","A2_TEL","A2_MUN","A2_CEP","A2_INSCR","A2_CGC"},xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1,0)
	
//	DbSelectARea("SB5")
//	DbSetOrder(1)
//	If DbSeek(xFilial("SB5")+SC7->C7_PRODUTO)
//		_cDesc := SB5->B5_CEME
//	Else	    
        _cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SC7->C7_PRODUTO,1)//Descricao do Produto

		_ccompra := GetAdvFVal("SY1","Y1_NOME",xFilial("SY1")+SC7->C7_USER,3)//Descricao do Produto
//	Endif
	
	dbSelectArea("SC7")
    
//    If SC7->C7_RESIDUO == " "
//		If SC7->C7_QUANT > SC7->C7_QUJE
			Aadd(_aPed,{SC7->C7_NUM,;	   										// [01] Numero do pedido de compra
			SC7->C7_FORNECE,;													// [02] Codigo do fornecedor
			SC7->C7_LOJA,;														// [03] Loja do fornecedor
			SC7->C7_CONTATO,;													// [04] Nome do contato
			SC7->C7_QUANT /*-SC7->C7_QUJE*/,;									// [05] Quantidade do pedido de compra
			SC7->C7_QUJE,;														// [06] Quantidade ja entregue
			SC7->C7_PRECO,;														// [07] Preco unitario
			SC7->C7_UM,;														// [08] Unidade de medida
			(SC7->C7_QUANT /*- SC7->C7_QUJE*/) * SC7->C7_PRECO,;				// [09] Total do item
			SC7->C7_VLDESC,;													// [10] Valor do desconto
			SC7->C7_COND,;														// [11] Condicao de pagamento
			SC7->C7_DATPRF,;													// [12] Data de entrega
			SC7->C7_EMISSAO,;													// [13] Data de emissao do pedido de compra
			IIF (!EMPTY(SC7->C7_DESCRI),SC7->C7_DESCRI,_cDesc),;				// [14] Descricao do produto
			SC7->C7_OBS,;														// [15] Observacao do item do pedido de compra
			_aForn[1],;															// [16] Nome do fornecedor
			_aForn[2],;															// [17] Endereco fornecedor
			_aForn[3],;															// [18] Telefone do fornecedor
			_aForn[4],;															// [19] Cidade do fornecedor
			_aForn[5],;															// [20] CEP do fornecedor
			_aForn[6],;															// [21] Inscricao Estadual do fornecedor
			_aForn[7],;															// [22] CNPJ do fornecedor
			GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+SC7->C7_COND,1,0),; 	// [23] Descricao da condicao de pagamento
			SC7->C7_VALFRE,;													// [24] Valor do frete                    
			SC7->C7_PRODUTO,;													// [25] Codigo produto                     
			SC7->C7_ITEM,;														// [26] Item do pedido   
			_cCompra})															// [27] Comprador  													                  
//		Endif
//	Endif
	_aForn  := {}
	DbSkip()
End

RestArea(_aArea)
Return Nil
/*/
?????????????????????????????????????????
?????????????????????????????????????????
?????????????????????????????????????????
??uncao    ?AjustaPerg   ?Autor ?Wilson Cruz           ?Data ?16.01.10 ??
?????????????????????????????????????????
??escricao ?Cria Grupo de Perguntas no SX1                                 ??
?????????????????????????????????????????
??so       ?Inovalli                                                       ??
?????????????????????????????????????????
?????????????????????????????????????????
?????????????????????????????????????????
/*/
Static Function AjustaPerg(cPerg)

Local aPerg := {}

/*{"X1_PERcUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP", "X1_PICTURE"}
*/

AADD(aPerg,{"Pedido de ","X1_PERSPA","X1_PERENG","MV_CH1","C",TamSx3("C7_NUM")[1],;
TamSx3("C7_NUM")[2],0,"G","",;
"MV_PAR01","","","","",;
"","","","","",;
"","","","","",;
"","","","","",;
"","","","","",;
"","","","",""})

AADD(aPerg,{"Pedido Ate","X1_PERSPA","X1_PERENG","MV_CH2","C",TamSx3("C7_NUM")[1],;
TamSx3("C7_NUM")[2],0,"G","",;
"MV_PAR02","","","","",;
"","","","","",;
"","","","","",;
"","","","","",;
"","","","","",;
"","","","",""})

//AjustaSx1(cPerg,aPerg)	//Funcao Generica AjustaSx1()
Return
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?RunImp   ?Autor ?Wilson Cruz           ?Data ?16.01.10 ??
???????????????????????????????????????
??escri??o ?Impressao do pedido de compra                              ??
???????????????????????????????????????
??so       ?Inovalli                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function RunImp()
//Local _nIcmsIt 	:=  0
Local _nSubTot	:=  0
Local _nDescont	:=  0
Local _nTotGer  := 0  
Local _nFrete  	:=  0
Local _nTotal	:=  0
Local _lContPg 	:= .F.
Local _nItens  	:=  0
Local _lCont   	:= .T.
Local _nPag    	:=  1
//Local _nMaxIt  	:= 08
//Local _nMaxIt  	:= 16
//Local _cMsg01   := ""
//Local _cMsg02   := ""
//Local _cMsg03   := ""
//Local _cMsg04   := ""
//Local _cMsg05   := ""
//Local _cMsg06   := ""
Local _cLogo	:= "" 
Private oPrint 	:= TMSPrinter():New(cTitulo)

//????????????????????
//?Carrega Fontes Graficas (Parametros) ?
//?.Nome da Fonte(Windows)				 ?
//?.Tamanho em Pixels					 ?
//?.Bold (T/F)    						 ?
//????????????????????
//<oFont> := TFont():New( <cName>, <nWidth>, <nHeight>, <.from.>,[<.bold.>],<nEscapement>,,<nWeight>,[<.italic.>],[<.underline.>],,,,,, [<oDevice>] )

oFont06n	:= TFont():New("Batang",9,06,.T.,.F.,5,.T.,5,.T.,.F.)
oFont06b	:= TFont():New("Batang",9,06,.T.,.T.,5,.T.,5,.T.,.F.)
oFont06ns	:= TFont():New("Batang",9,06,.T.,.F.,5,.T.,5,.T.,.T.)
oFont06bs	:= TFont():New("Batang",9,06,.T.,.T.,5,.T.,5,.T.,.T.)

oFont08n	:= TFont():New("Batang",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
oFont08b	:= TFont():New("Batang",9,08,.T.,.T.,5,.T.,5,.T.,.F.)
oFont08ns	:= TFont():New("Batang",9,08,.T.,.F.,5,.T.,5,.T.,.T.)
oFont08bs	:= TFont():New("Batang",9,08,.T.,.T.,5,.T.,5,.T.,.T.)

oFont09n	:= TFont():New("Batang",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
oFont09b	:= TFont():New("Batang",9,09,.T.,.T.,5,.T.,5,.T.,.F.)
oFont09ns	:= TFont():New("Batang",9,09,.T.,.F.,5,.T.,5,.T.,.T.)
oFont09bs	:= TFont():New("Batang",9,09,.T.,.T.,5,.T.,5,.T.,.T.)


oFont12n	:= TFont():New("Batang",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12b	:= TFont():New("Batang",9,12,.T.,.T.,5,.T.,5,.T.,.F.)                                                                
oFont12ns	:= TFont():New("Batang",9,12,.T.,.F.,5,.T.,5,.T.,.T.)
oFont12bs	:= TFont():New("Batang",9,12,.T.,.T.,5,.T.,5,.T.,.T.)

oFont14n	:= TFont():New("Batang",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14b	:= TFont():New("Batang",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14ns	:= TFont():New("Batang",9,14,.T.,.F.,5,.T.,5,.T.,.T.)
oFont14bs	:= TFont():New("Batang",9,14,.T.,.T.,5,.T.,5,.T.,.T.)

oFont15n	:= TFont():New("Batang",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15b	:= TFont():New("Batang",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15ns	:= TFont():New("Batang",9,15,.T.,.F.,5,.T.,5,.T.,.T.)
oFont15bs	:= TFont():New("Batang",9,15,.T.,.T.,5,.T.,5,.T.,.T.)

oFont17b	:= TFont():New("Batang",9,17,.T.,.T.,5,.T.,5,.T.,.F.)

oFont21n	:= TFont():New("Batang",9,21,.T.,.F.,5,.T.,5,.T.,.F.)
oFont21b	:= TFont():New("Batang",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21ns	:= TFont():New("Batang",9,21,.T.,.F.,5,.T.,5,.T.,.T.)
oFont21bs	:= TFont():New("Batang",9,21,.T.,.T.,5,.T.,5,.T.,.T.)

oFont28n	:= TFont():New("Bookman Old Style",	9,28,.T.,.F.,5,.T.,5,.T.,.F.)
oFont28b	:= TFont():New("Bookman Old Style",	9,28,.T.,.T.,5,.T.,5,.T.,.F.)
oFont28ns	:= TFont():New("Bookman Old Style",	9,28,.T.,.F.,5,.T.,5,.T.,.T.)
oFont28bs	:= TFont():New("Bookman Old Style",	9,28,.T.,.T.,5,.T.,5,.T.,.T.)

oBrush		:= TBrush():New("",CLR_LIGHTGRAY)

///cBmp		:= GetSrvProfString("StartPath","") + "LOGO_INOVALLI.BMP"   
// MV_XLOGPC  = NOME DO LOGO PARA O PEDIDO DE COMPRAS 
_cLogo		:= SuperGetMV("MV_XLOGPC")

//cBmp		:= GetSrvProfString("StartPath","") + "LOGO_INOV.BMP"
cBmp		:= GetSrvProfString("StartPath","") + _cLogo 
nLin		:= 0280
nCol		:= 0300

_lContPg    := .F.
oPrint:SetPortrait()

_nI := 1
SetRegua(RecCount())
While len(_aPed) >= _nI .and. _lCont
	
	//?????????????????????
	//?Inicializa a p?ina a cada orcamento   ?
	//?????????????????????
	oPrint:StartPage()
	
	//?????????????????????
	//?Controle de numero de paginas          ?
	//?????????????????????
//	If _lContPg
///		_nPag    := 1
//	Endif
	
	CabecPV(_nI,_nPag)
	CabecEmp(_ni,_nPag,Alltrim(_aPed[_nI,27]),_nlin)

	//?????????????????????
	//?Impressao dos itens do pedido          ?
	//?????????????????????
	_cPed   := _aPed[_nI,01]
	_cCol   := 150
	_lCont  := .T. // Controle do loop de impressao dos itens
	_nItens :=  0  // Controle de numero de itens por pagina
	_lContPg:= .F. // Controle de continuacao de pagina
	_nlin   := 1400

	While _cPed == _aPed[_nI,01] .and. _lCont
		
		oPrint:Say(_nlin+30,_cCol+040,_aPed[_nI,26],oFont08n ) // item pedido
	//	oPrint:Say(_nlin+30,_cCol+040,_aPed[_nI,25],oFont08n ) // item pedido	
		oPrint:Say(_nlin+30,_cCol+130,Transform(_aPed[_nI,25],"@!"),oFont08n)  //codigo do produto
		oPrint:Say(_nlin+30,_cCol+340,""+SUBSTR(_aPed[_nI,14],1,50),oFont08n) //oFont12b)						// Descricao do produto 
	    oPrint:Say(_nlin+70,_cCol+340,""+SUBSTR(_aPed[_nI,14],51,99),oFont08n) //oFont12b)                      //Continua?o da descricao
		oPrint:Say(_nlin+30,_cCol+1400,Transform(_aPed[_nI,05], "@E 999,999,999.99"),oFont08n ) //oFont12b)		// Quantidade
		oPrint:Say(_nlin+30,_cCol+1660,_aPed[_nI,08],oFont08n) //oFont12b)     									// Unidade de medida 	
    //	oPrint:Say(_nlin+30,_cCol+550,""+SUBSTR(_aPed[_nI,14],1,50),oFont08n) //oFont12b)						// Descricao do produto 
	//  oPrint:Say(_nlin+70,_cCol+550,""+SUBSTR(_aPed[_nI,14],51,99),oFont08n) //oFont12b)                      //Continua?o da descricao
		oPrint:Say(_nlin+30,_cCol+1760,Transform(_aPed[_nI,07], "@E 99,999,999.99999999"),oFont08n) //oFont12b)	// Valor unitario
		oPrint:Say(_nlin+30,_cCol+2080,Transform(_aPed[_nI,09], "@E 9,999,999,999.99"),oFont08n) //oFont12b)		// Valor Total
		
		If Len(_aPed[_nI,14]) > 170
			
		Endif
		
		_nlin += 100  
		
		//????????????????????
		//?Atualiza totalizadores do relatorio  ?
		//????????????????????
		_nSubTot  += _aPed[_nI,09]
		_nTotGer  += _aPed[_nI,09]	
		_nDescont += _aPed[_nI,10]
		_nFrete	  += _aPed[_nI,24]
		//????????????????????
		//?Controla numero maximo de itens      ?
		//????????????????????
		_nItens++
		_nI++
		
		If _nI > Len(_aPed)
			_lCont := .F.
			_nI := Len(_aPed)
		Else
			IF _nlin >= 3200 
			//	RodaOrc(_nLin,_nPag,_nSubTot,_nDescont,_nI-1, _nFrete,_nTotGer)
				oPrint:EndPage()
				_nPag++
				CabecPV(_nI,_nPag)
			// fazer via funcao 
			_nlin   := 520
			oPrint:Box(_nLin,150,_nlin+080,2400)
			oPrint:Say(_nlin,190,"ITEM",oFont08b)
			oPrint:Say(_nlin,280,"CÓDIGO",oFont08b)
			oPrint:Say(_nlin,488,"DESCRICAO",oFont08b)
			oPrint:Say(_nlin,1540,"QTD",oFont08b)
			oPrint:Say(_nlin,1800,"UN",oFont08b)
			oPrint:Say(_nlin,1940,"VLR UNITÁRIO",oFont08b)
			oPrint:Say(_nlin,2228,"VLR TOTAL",oFont08b)





			_nLin += 60
				//_nlin   := 1400
    			_nSubTot  := 0
				_nDescont := 0
				_nFrete   := 0
				_nTotal   := 0
				_nItens   := 0
			endif
			
			//If _nItens >= _nMaxIt  .And. _cPed == _aPed[_nI,01]
			//	RodaOrc(_nPag,_nSubTot,_nDescont,_nI-1, _nFrete,_nTotGer)
		//		oPrint:EndPage()
		//		_nPag++
		//		CabecPV(_nI,_nPag)
		//		_nlin   := 1200
    	//		_nSubTot  := 0
		//		_nDescont := 0
		//		_nFrete   := 0
		//		_nTotal   := 0
		//		_nItens   := 0
		Endif
		//Endif
		
	End

	IF _nlin >= 3200 
		//RodaOrc(_nPag,_nSubTot,_nDescont,_nI-1, _nFrete,_nTotGer)
		oPrint:EndPage()
			_nPag++
		CabecPV(_nI,_nPag)

			RodaOrcF(_nlin, _nPag,_nSubTot,_nDescont,If(_lCont,_nI-1,_nI), _nFrete,_nTotGer)
			_nSubTot  := 0
			_nDescont := 0
			_nTotal   := 0
			_nItens   := 0
			_nFrete   := 0
	else 
			RodaOrcF(_nlin, _nPag,_nSubTot,_nDescont,If(_lCont,_nI-1,_nI), _nFrete,_nTotGer)
			_nSubTot  := 0
			_nDescont := 0
			_nTotal   := 0
			_nItens   := 0
			_nFrete   := 0
	
	endif 
	//????????????????????
	//?Finaliza a pagina do orcamento       ?
	//????????????????????
	oPrint:EndPage()
End

oPrint:Preview()     // Visualiza antes de imprimir
oPrint:EndPage()

Return nil
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?CabecPV  ?Autor ?Wilson Cruz           ?Data ?17.01.10 ??
???????????????????????????????????????
??escri??o ?Cabecalho do Pedido de Compra                              ??
???????????????????????????????????????
??so       ?Inovalli                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function CabecPV(_nPos,_nPag)

Local _nlin := 200  // alterado..era 250
//Local _nAjust  

//?????????????????????
//?Dados do pedido de compra              ?
//?????????????????????
////oPrint:SayBitmap( 170,170,cBmp,0450,0350) 
oPrint:SayBitmap( 220,165,cBmp,0350,0300)
///
oPrint:Box(_nLin,150,_nlin+300,2400)   
oPrint:Box(160,130,3400,2430)   


oPrint:Line(_nlin,520,_nlin+300,520)
oPrint:Line(_nlin,1850,_nlin+300,1850)

//oPrint:Line(_nlin+175,520,_nlin+175,1850) // Linha horizontal

_nlin := 250    
_numpag:= Strzero(_nPag,2)
_cdata := 	subs(DTOS(_aPed[_nPos,13]),7,2)+"/"+ ; 
			subs(DTOS(_aPed[_nPos,13]),5,2)+"/"+ ; 
			subs(DTOS(_aPed[_nPos,13]),1,4) 

//oPrint:Say(_nlin,840	,"RQ - REGISTRO DA QUALIDADE",oFont15b,,,,)        //850
//oPrint:Say(_nlin,840	,"PC - P E D I D O   D E   C O M P R A ",oFont15b,,,,)        //850
oPrint:Say(_nlin,1870	,"Data Emissao.: " + _cdata ,oFont08b,,,,)  
//oPrint:Say(_nlin,2060	,"XXX-XXX-XX",oFont12n,,,,)
_nlin += 080
//oPrint:Say(_nlin,1870	,"Rev.:",oFont15b,,,,) 
//oPrint:Say(_nlin,2010	,"00",oFont12n,,,,)
//_nlin += 80            
oPrint:Say(_nlin,800	,"PEDIDO DE COMPRA - "+_aPed[_nPos,1],oFont17b,,,,)     //920
//_nlin += 10
_nlin += 110
oPrint:Say(_nlin,1870	,"Página.:",oFont08b,,,,)
oPrint:Say(_nlin,2060	," "+_numpag,oFont08n,,,,) 

_nlin += 80

Return(_nlin)



Static Function CabecEmp(_nPos,_nPag,_comprador,_nlin)

//?????????????????????
//?Dados da Empresa                      ?
//?????????????????????
_nlin := 520 
oPrint:Say(_nlin,150		, SM0->M0_NOMECOM,oFont08b)
_nlin += 60 
//oPrint:Say(_nlin,150		,"Rua Augusta, 2840 - 13 Andar - Cerquesa Cesar",oFont12b)
oPrint:Say(_nlin,150		, "CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont08n)
_nlin += 60 

oPrint:Say(_nlin,150		, SM0->M0_ENDENT,oFont08n)
_nlin += 60                               
//oPrint:Say(_nlin,150		, "S? Paulo - SP CEP: 01412-100",oFont12b)
oPrint:Say(_nlin,150		, alltrim(SM0->M0_CIDENT) + " - " + alltrim(SM0->M0_ESTENT) + " CEP " + ;
                              Transform(SM0->M0_CEPENT,"@R 99999-999")  ,oFont08n)
//_nlin += 60 
//oPrint:Say(_nlin,150		,"Comprador: " +  Alltrim(_aPed[_nPos,27]),oFont08n)

_nlin += 60 
//oPrint:Say(_nlin,150		,"Comprador: " +  Alltrim(_aPed[_nPos,27]),oFont08n)
oPrint:Say(_nlin,150		,"Comprador: " +  Alltrim(_comprador),oFont08n)

//?????????????????????
//?Dados do Fornecedor                    ?
//?????????????????????
_nlin += 90 //100 
oPrint:Say(_nlin,150		,"Fornecedor",oFont08b)
_nlin += 60 
oPrint:Say(_nlin,150		,"Razão Social",oFont08n)
oPrint:Say(_nlin,450		,": "+_aPed[_nPos,16],oFont08n) 
_nlin += 60 
oPrint:Say(_nlin,150		,"Contato",oFont08n)
oPrint:Say(_nlin,450		,": "+_aPed[_nPos,04],oFont08n)
_nlin += 60 
oPrint:Say(_nlin,150		,"Endereço",oFont08n)
oPrint:Say(_nlin,450		,": "+_aPed[_nPos,17],oFont08n)
oPrint:Say(_nlin,1550		,"Município",oFont08n)
oPrint:Say(_nlin,1850		,": "+_aPed[_nPos,19],oFont08n)
_nlin += 60 
oPrint:Say(_nlin,150		,"Telefone",oFont08n)
oPrint:Say(_nlin,450		,": "+_aPed[_nPos,18],oFont08n)
oPrint:Say(_nlin,1550		,"CEP",oFont08n)
oPrint:Say(_nlin,1850		,": "+ Transform(_aPed[_nPos,20],"@R 99999-999"),oFont08n)
_nlin += 60 
oPrint:Say(_nlin,150		,"CNPJ:",oFont08n)
oPrint:Say(_nlin,450		,": "+Transform(_aPed[_nPos,22],Iif(Len(Alltrim(_aPed[_nPos,22]))<14,"@R 999.999.999-99","@R 99.999.999/9999-99")) ,oFont08n)
oPrint:Say(_nlin,1550		,"Inscr.Estadual",oFont08n)
oPrint:Say(_nlin,1850		,": "+_aPed[_nPos,21],oFont08n)

//????????????????????
//?Imprime box dos itens                ?
//????????????????????
_nLin := 1300
//oPrint:Box(_nLin,150,_nlin+1400,2400)
//oPrint:Line(_nlin,520,_nlin+1400,520)		// Linha vertival separacao entre quantidade e unidade de medida
//oPrint:Line(_nlin,690,_nlin+1400,690)		// Linha vertival separacao entre unidade de medida e descricao  oPrint:Line(_nlin,700,_nlin+900,700)
//oPrint:Line(_nlin,1640,_nlin+1400,1640)		// Linha vertival separacao entre descricao e valor unitario     oPrint:Line(_nlin,1620,_nlin+900,1620)
//oPrint:Line(_nlin,2000,_nlin+1640,2000)		// Linha vertival separacao entre valor unitario e valor total
//oPrint:Line(_nlin,2400,_nlin+1640,2400)		// Linha vertival continuacao da linha vertical do box

//_nLin := 1130

//oPrint:Box(_nLin,150,_nlin+1200,2400)
oPrint:Box(_nLin,150,_nlin+080,2400)
//oPrint:Line(_nlin,520,_nlin+1200,520)		// Linha vertival separacao entre quantidade e unidade de medida
//oPrint:Line(_nlin,690,_nlin+1200,690)		// Linha vertival separacao entre unidade de medida e descricao  oPrint:Line(_nlin,700,_nlin+900,700)
//oPrint:Line(_nlin,1640,_nlin+1200,1640)		// Linha vertival separacao entre descricao e valor unitario     oPrint:Line(_nlin,1620,_nlin+900,1620)
//oPrint:Line(_nlin,2000,_nlin+1440,2000)		// Linha vertival separacao entre valor unitario e valor total
//oPrint:Line(_nlin,2400,_nlin+1440,2400)		// Linha vertival continuacao da linha vertical do box

//????????????????????
//?Imprime box dos totais               ?
//????????????????????
//oPrint:Line(_nlin+960,2000,_nlin+960,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1020,2000,_nlin+1020,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1080,2000,_nlin+1080,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1140,2000,_nlin+1140,2400) // Linha horizontal de


//oPrint:Line(_nlin+960,2000,_nlin+960,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1020,2000,_nlin+1020,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1080,2000,_nlin+1080,2400) // Linha horizontal de separacao cabecalho
//oPrint:Line(_nlin+1640,2000,_nlin+1640,2400) // Linha horizontal de separacao cabecalho

_nLin += 10
//oPrint:Say(_nlin,190,"Quantidade",oFont15b)
//oPrint:Say(_nlin,550,"Unid.",oFont15b)
//oPrint:Say(_nlin,930,"Descrição",oFont15b)
//oPrint:Say(_nlin,1700,"Vlr Unit.",oFont15b)
//oPrint:Say(_nlin,2080,"Vlr Total",oFont15b)

//oPrint:Box(_nLin,150,_nlin+080,2400)
oPrint:Say(_nlin,190,"ITEM",oFont08b)
oPrint:Say(_nlin,280,"CÓDIGO",oFont08b)
oPrint:Say(_nlin,488,"DESCRICAO",oFont08b)
oPrint:Say(_nlin,1540,"QTD",oFont08b)
oPrint:Say(_nlin,1800,"UN",oFont08b)
oPrint:Say(_nlin,1940,"VLR UNITÁRIO",oFont08b)
oPrint:Say(_nlin,2228,"VLR TOTAL",oFont08b)


_nLin += 60
//oPrint:Line(_nlin,150,_nlin,2400) // Linha horizontal de separacao cabecalho    

Return
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?RodaOrc  ?Autor ?Wilson Cruz           ?Data ?17.01.10 ??
???????????????????????????????????????
??escri??o ?Rodape do Orcamento                                        ??
???????????????????????????????????????
??so       ?Inovalli                                                   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/

Static Function RodaOrc(_nlin,_nPag,_nSubTot,_nDescont,_nI, _nFrete,_nTotGer)

_nlin   := _nlin + 20 
_cCol   :=  150


oPrint:Box(_nLin,150,_nlin+060,2400)
oPrint:Say(_nLin,1700,"TOTAL DA PAGINA =====> R$",oFont12b)     				// Total sem desconto
oPrint:Say(_nlin,_cCol+1980,Transform(_nSubTot, "@E 999,999,999,999.99"),oFont12b)

Return()


Static Function RodaOrcF(_nlin, _nPag,_nSubTot,_nDescont,_nI, _nFrete,_nTotGer)

Local nXi := 0 

_nLin := _nLin + 10


oPrint:Box(_nLin,140,_nlin+520,2400)

oPrint:Box(_nLin+000,2050,_nlin+060,2400)
oPrint:Box(_nLin+060,2050,_nlin+120,2400)
oPrint:Box(_nLin+120,2050,_nlin+180,2400)
oPrint:Box(_nLin+180,2050,_nlin+240,2400)


_nLin := _nLin + 10

oPrint:Say(_nLin,190,"Condição de Pgto / Prazo de Entrega ",oFont08b)     				// Total do desconto
oPrint:Say(_nLin,1800,"Sub-Total",oFont08b)     				// Total do desconto
oPrint:Say(_nlin,_cCol+2060,Transform( _nTotGer, "@E 999,999,999.99"),oFont08b)

_nLin += 60

oPrint:Say(_nLin,1800,"Desconto",oFont08b)     				// Total do desconto
oPrint:Say(_nlin,_cCol+2060,Transform(_nDescont, "@E 999,999,999.99"),oFont08b)
oPrint:Say(_nlin,200," "+_aPed[_nI,23] + "             / ",oFont08n)
oPrint:Say(_nlin,440," " + Dtoc(_aPed[_nI,12]),oFont08n)

_nLin += 60


oPrint:Say(_nLin,1800,"Frete",oFont08b)     				// Total do frete
oPrint:Say(_nlin,_cCol+2060,Transform(_nFrete, "@E 999,999,999.99"),oFont08b)

_nLin += 60
oPrint:Say(_nLin,1800,"Total",oFont08b)     				// Total geral
oPrint:Say(_nlin,_cCol+2060,Transform( _nTotGer - _nDescont+_nFrete, "@E 999,999,999.99"),oFont08b)

_nLin += 10

oPrint:Say(_nLin,190,"Orientação para Entregas : ",oFont08b)
_nLin += 40
oPrint:Say(_nLin,190,"- Horário de recebimento das 09:00 às 16:00 de segunda a sexta-feira",oFont08n)
_nLin += 40
oPrint:Say(_nLin,190,"- Informar o número do Pedido de Compra na Nota Fiscal",oFont08n)
_nLin += 40
oPrint:Say(_nLin,190,"- Deve constar o número da Nota Fiscal no boleto campo 'número do documento'",oFont08n)
_nLin += 40
oPrint:Say(_nLin,190,"- Enviar Nota Fiscal + Boleto para admin@ .com.br",oFont08n)
_nLin += 40
oPrint:Say(_nLin,190,"- Enviar XML correspondente a NF para xml@ .com.br",oFont08n)
_nLin += 40
oPrint:Say(_nLin,190,"- O Faturamento deve ser conforme o CNPJ do pedido de compra",oFont08n)

_nlin += 080


//oPrint:Say(3150,2190,"P?ina: " +Strzero(_nPag,2) ,oFont12b)
oPrint:Say(_nlin,150,"Observações:",oFont08b)

nLinhas := MLCount(_aPed[1,15],90)
For nXi:= 1 To len(_aPed) //nLinhas
    
        If !empty( _aPed[nXi,15])
               _nlin += 50 
			   oPrint:Say(_nlin,180,_aPed[nXi,15],oFont08n)  
		IF _nlin >= 3000 
		
			oPrint:EndPage()
				_nPag++
			CabecPV(_nI,_nPag)
		
		Endif 

        EndIf
Next nXi 

Return(_npag)

