/*
ESTIMA.DO:

Estima Nested Logit usando os intrumentos do Berry
*/

* ______________________________________________________________________________
*
*                             ABRINDO BASE DE DADOS 
* ______________________________________________________________________________

cd "/mnt/84DC97E6DC97D0B2/carros"
*cd "D:/carros"
use "base_limpa_instr.dta", clear


********************************************************************************
* testes
********************************************************************************
keep if subregiao == "SAO PAULO"
* drop if CO2 == .

* Cortando regiões nada a ver
* drop if cidadeprincipal=="AAAAA"
* gen outros=strmatch(cidadeprincipal,"OTHERS*")
* drop if outros==1
* drop if ano==2013

* Cortando marca de milionário
* drop if marca=="FERRARI"
* drop if marca=="ASTON MARTIN"
* drop if marca=="BENTLEY"
* drop if marca=="JAGUAR"
* drop if marca=="LAMBORGHINI"
* drop if marca=="LEXUS"
* drop if marca=="MASERATI"
* drop if marca=="ROLLS-ROYCE"
drop if prec > 200000


* ______________________________________________________________________________
*
* 							   INSTALANDO RCL
* ______________________________________________________________________________

* ssc install ivreg2
* ssc install ranktest
* ssc install rcl, all replace


* ______________________________________________________________________________
*
* 					 ANINHANDO POR COMBUSTIVEL E SEGMENTO
* ______________________________________________________________________________

generate Origem = acordo

*-------------------------------------------------------------------------------
* DEFININDO VARIÁVEIS
*-------------------------------------------------------------------------------
global X ///
    transmiss ///
    tracao ///
    pilotoauto ///
    arcondicionado ///
    rodaleve ///
    SOM ///
    DVD ///
    vidros ///
    computer ///
    direcao ///
    travcentral ///
    alarme ///
    airbag ///
    ABS1 EBD1 ///
    acabamento_luxo ///
    garantia ///
    espaco_interno_ln ///
    dist_eixos ///
    consumo ///
    peso_bruto_ln ///
    carga_paga_max ///
    potencia_especifica ///
    veloc_max ///
    aceleracao ///
    importado ///
    cilindradas ///
    /*cilindrada_dummy* */ ///
    /* cilindrada_acordo */ ///
	ano_dummy* ///
    potencia_ln
	
global Xt ///
	ano_dummy* ///
	potencia ///
	potencia_especifica ///
	acordo ///
	consumo
	

global IV /// 
    /* BST* BLP* */ ///
	BST* ///
    BLP*potencia ///
    BLP*veloc_max ///
    BLP*aceleracao ///
    BLP*tracao ///
    BLP*peso_bruto ///
    BLP*espaco_interno
	/* BST* BLP*  */ ///
    * BLP*potencia ///
    * BLP*veloc_max ///
    * BLP*aceleracao ///
    * BLP*tracao ///
    * BLP*peso_bruto ///
    * BLP*espaco_interno ///
    * BLP2_potencia_ln BLP3_potencia_ln BLP5_1_potencia_ln ///
    * BLP5_2_potencia_ln BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l  ///
    * BLP2_carga_ln BLP3_carga_ln BLP5_1_carga_ln BLP5_2_carga_ln BST_1 BST_1_1

*-------------------------------------------------------------------------------
* REGREDINDO PREÇO E IV
*-------------------------------------------------------------------------------
*stepwise, pr(0.2): regress prec $IV
*lars prec $IV
*regress prec_ln $IV


*-------------------------------------------------------------------------------
* REGRESSÃO
*-------------------------------------------------------------------------------
* msimulations com a opção onlymc calcula apenas o custo marginal e markup sem simular.
rcl share_geral ///
    $Xt ///
    (prec = $IV), ///
    market(ano_cidade) ///
	msize(mercado_potencial) ///
    robust ///
    nests(segmento) ///
    gmm2s ///
    /* msimulation(marca_e) ///
    onlymc */ ///
    elasticities(marca_e)

*-------------------------------------------------------------------------------
* PARÂMETROS, MARKUP, E CUSTO MARGINAL
*-------------------------------------------------------------------------------
scalar alpha   = -_b[prec]
scalar sigma_1 = _b[__sigma_g]
scalar sigma_2 = _b[__sigma_hg]

matrix theta = e(b)

generate xb0 = __xb0
generate ksi = __ksi
generate lnss0 = __lnss0
generate delta = __delta
generate shat = __shat


generate ownelas = - alpha * [1 / (1 - sigma_1) ///
    - (1 / (1 - sigma_1) ///
    - 1 / (1 - sigma_2)) * sjg2 ///
    - (sigma_2 / (1 - sigma_2)) * sjg1 ///
    - s_jt] * prec
* summarize ownelas, d

generate cross_subgroup = alpha * [(1 / (1 - sigma_1) ///
    - 1 / (1 - sigma_2)) * sjg2 ///
    + (sigma_2 / (1 - sigma_2)) * sjg1 /// 
    + s_jt] * prec
generate cross_group    = alpha * [(sigma_2 / (1 - sigma_2)) * sjg1 /// 
    + s_jt] * prec
generate cross_outgroup = alpha * s_jt * prec

egen sm = sum(s_jt), by(marca combustivel segmento ano)

generate sjg1m = sm / sg1
generate sjg2m = sm / sg2

generate markup = 1 / /// 
    (alpha * [1 / (1 - sigma_1) ///
        - (1 / (1 - sigma_1) ///
        - 1 / (1 - sigma_2)) * sjg2m ///
        - (sigma_2 / (1 - sigma_2)) * sjg1m ///
        - sm])

generate VAT = 0 // MUDAR !!!!!

generate mc = (prec - markup) / (1 + VAT)



* ______________________________________________________________________________
*
*                             SALVANDO 
* ______________________________________________________________________________

* keep marca modelo ano combustivel litros carroceria transmiss portas ///
*     subregiao cidadeprincipal ///
*     segmento ///
*     share_geral prec prec_ln /// 
*     xb0 ksi lnss0 delta shat markup mc

* save estimado.dta

