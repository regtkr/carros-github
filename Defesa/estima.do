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
generate prec_ln = ln(prec)

encode marca,       generate(marca_e)
encode combustivel, generate(combustivel_e)

*-------------------------------------------------------------------------------
* DEFININDO VARIÁVEIS
*-------------------------------------------------------------------------------
local X ///
    potencia_ln espaco_interno_ln carga_ln

local IV ///
    BLP2_potencia_ln BLP3_potencia_ln BLP5_1_potencia_ln ///
    BLP5_2_potencia_ln /*BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l */ ///
    BLP2_carga_ln BLP3_carga_ln BLP5_1_carga_ln BLP5_2_carga_ln BST_1 BST_1_1



*-------------------------------------------------------------------------------
* REGRESSÃO
*-------------------------------------------------------------------------------
* msimulations com a opção onlymc calcula apenas o custo marginal e markup sem simular.
rcl share_geral ///
    `X' ///
    (prec_ln = `IV'), ///
    market(ano_cidade) ///
    robust ///
    nests(combustivel_e segmento) ///
    msize(mkt_pop_) ///
    tsls  ///
    msimulation(marca_e) ///
    onlymc ///
    elasticities(marca_e)

*-------------------------------------------------------------------------------
* PARÂMETROS, MARKUP, E CUSTO MARGINAL
*-------------------------------------------------------------------------------
scalar alpha   = abs(_b[prec_ln])
scalar sigma_1 = _b[__sigma_g]
scalar sigma_2 = _b[__sigma_hg]

matrix theta = e(b)

generate xb0 = __xb0
generate ksi = __ksi
generate lnss0 = __lnss0
generate delta = __delta
generate shat = __shat


generate ownelas = - alpha * [1 / (1 - sigma_1) - (1 / (1 - sigma_1) - 1 / (1 - sigma_2)) * sjg2 - (sigma_2 / (1 - sigma_2)) * sjg1 - s_jt] * prec_ln
summarize ownelas, d

generate cross_subgroup = alpha * [(1 / (1 - sigma_1) -1 / (1 - sigma_2)) * sjg2 + (sigma_2 / (1 - sigma_2)) * sjg1 + s_jt] * prec_ln
generate cross_group    = alpha * [(sigma_2 / (1 - sigma_2)) * sjg1 + s_jt] * prec_ln
generate cross_outgroup = alpha * s_jt * prec_ln

egen sm = sum(s_jt), by(marca combustivel segmento ano)

generate sjg1m = sm / sg1
generate sjg2m = sm / sg2

generate markup = 1 / /// 
    (alpha * [1 / (1 - sigma_1) - (1 / (1 - sigma_1) - 1 / (1 - sigma_2)) * sjg2m - (sigma_2 / (1 - sigma_2))*sjg1m - sm])

generate VAT = 0 // MUDAR !!!!!

generate mc = (prec_ln - markup) / (1 + VAT)



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

