/*
ESTIMA.DO:

Estima Nested Logit usando os intrumentos do Berry
*/

* ______________________________________________________________________________
*
*                             ABRINDO BASE DE DADOS 
* ______________________________________________________________________________

cd "/mnt/84DC97E6DC97D0B2/carros"
use "base_limpa_instr.dta", clear


* ______________________________________________________________________________
*
* 							   INSTALANDO RCL
* ______________________________________________________________________________

ssc install ivreg2
ssc install ranktest
ssc install rcl


* ______________________________________________________________________________
*
* 							ESTIMANDO POR ORIGEM 
* ______________________________________________________________________________

generate Origem = acordo
generate prec_ln = ln(prec)


*-------------------------------------------------------------------------------
* REGRESSÃO
*-------------------------------------------------------------------------------
rcl share_geral ///
    potencia_ln espaco_interno_ln carga_ln ///
    (prec_ln = BLP2_potencia_ln BLP3_potencia_ln BLP5_1_potencia_ln ///
		BLP5_2_potencia_ln /*BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l */ ///
		BLP2_carga_ln BLP3_carga_ln BLP5_1_carga_ln BLP5_2_carga_ln BST_1 BST_1_1), ///
    market(ano_cidade) ///
    robust ///
    nests(combustivel segmento) ///
    msize(mkt_pop_) ///
    tsls  

*-------------------------------------------------------------------------------
* MARKUP
*-------------------------------------------------------------------------------
scalar alpha   = _b[prec_ln]
scalar sigma_1 = _b[__sigma_g]
scalar sigma_2 = _b[__sigma_hg]

generate ownelas = - alpha * [1 / (1 - sigma_1) - (1 / (1 - sigma_1) - 1 / (1 - sigma_2)) * sjg2 - (sigma_2 / (1 - sigma_2)) * sjg1 - s_jt] * price 
summarize ownelas, d

generate cross_subgroup = alpha * [(1 / (1 - sigma_1) -1 / (1 - sigma_2)) * sjg2 + (sigma_2 / (1 - sigma_2)) * sjg1 + s_jt] * price
generate cross_group    = alpha * [(sigma_2 / (1 - sigma_2)) * sjg1 + s_jt] * price
generate cross_outgroup = alpha * s_jt * price

egen sm = sum(s_jt), by(marca combustivel segmento ano)

generate sjg1m = sm / sg1
generate sjg2m = sm / sg2

generate markups = 1 / /// 
    (alpha * [1 / (1 - sigma1) - (1 / (1 - sigma1) - 1 / (1 - sigma2)) * sjg2m - (sigma2 / (1 - sigma2))*sjggm - sm])











* *model (2) rcl com todas as características

* rcl share_geral ///
*     arcondicionado transmissao tracao EBD1 Aca_de_luxo pilotoauto lnpeso_m lncarga lndiex_c lndiex_l lnpotencia_motor litros_em_cc1 litros_em_cc2 litros_em_cc3 litros_em_cc4 litros_em_cc6 ///
*     (lnpreco_corrigido = BLP2_arcondicionado BLP3_arcondicionado BLP5_1arcondicionado BLP5_2arcondicionado BLP2_transmissao BLP3_transmissao BLP5_1transmissao BLP5_2transmissao BLP2_tracao BLP3_tracao BLP5_1tracao BLP5_2tracao BLP2_EBD1 BLP3_EBD1 BLP5_1EBD1 BLP5_2EBD1 BLP2_Aca_de_luxo BLP3_Aca_de_luxo BLP5_1Aca_de_luxo BLP5_2Aca_de_luxo BLP2_pilotoauto BLP3_pilotoauto BLP5_1pilotoauto BLP5_2pilotoauto BLP2_lnpotencia_motor BLP3_lnpotencia_motor BLP5_1lnpotencia_motor BLP5_2lnpotencia_motor BLP2_lndiex_c BLP3_lndiex_c BLP5_1lndiex_c BLP5_2lndiex_c BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l BLP2_lnpeso_m BLP3_lnpeso_m BLP5_1lnpeso_m BLP5_2lnpeso_m BLP2_lncarga BLP3_lncarga BLP5_1lncarga BLP5_2lncarga BST_1 BST_1_1), ///
*     market(ano_cidade) ///
*     robust ///
*     nests(Origem) ///
*     msize(mkt_pop_) ///
*     tsls    


* * ______________________________________________________________________________
* *
* *                             ESTIMANDO POR SEGMENTO 
* * ______________________________________________________________________________

* *model (3) rcl
* rcl share_geral lnpotencia_motor lndiex_l lncarga (lnpreco_corrigido = BLP2_lnpotencia_motor BLP3_lnpotencia_motor BLP5_1lnpotencia_motor BLP5_2lnpotencia_motor BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l BLP2_lncarga BLP3_lncarga BLP5_1lncarga BLP5_2lncarga BST_1 BST_1_1), market(mes_city) robust nests(segmento) msize(Market_poten) tsls  

* *model (4) rcl com todas as características
* rcl share_geral arcondicionado transmissao tracao EBD1 Aca_de_luxo pilotoauto lnpeso_m lncarga lndiex_c lndiex_l lnpotencia_motor litros_em_cc1 litros_em_cc2 litros_em_cc3 litros_em_cc4 litros_em_cc6 (lnpreco_corrigido = BLP2_arcondicionado BLP3_arcondicionado BLP5_1arcondicionado BLP5_2arcondicionado BLP2_transmissao BLP3_transmissao BLP5_1transmissao BLP5_2transmissao BLP2_tracao BLP3_tracao BLP5_1tracao BLP5_2tracao BLP2_EBD1 BLP3_EBD1 BLP5_1EBD1 BLP5_2EBD1 BLP2_Aca_de_luxo BLP3_Aca_de_luxo BLP5_1Aca_de_luxo BLP5_2Aca_de_luxo BLP2_pilotoauto BLP3_pilotoauto BLP5_1pilotoauto BLP5_2pilotoauto BLP2_lnpotencia_motor BLP3_lnpotencia_motor BLP5_1lnpotencia_motor BLP5_2lnpotencia_motor BLP2_lndiex_c BLP3_lndiex_c BLP5_1lndiex_c BLP5_2lndiex_c BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l BLP2_lnpeso_m BLP3_lnpeso_m BLP5_1lnpeso_m BLP5_2lnpeso_m BLP2_lncarga BLP3_lncarga BLP5_1lncarga BLP5_2lncarga BST_1 BST_1_1), market(mes_city) nests(segmento) msize(Market_poten) tsls    


* * ______________________________________________________________________________
* *
* *                             ANINHANDO POR CARROCERIA 
* * ______________________________________________________________________________

* rcl share_geral ///
*     lnHP_peso espaco_interno_ln pilotoauto tracao cilindrada_dummy* ///
*     cc*__queda_1 cc*__queda_2 ///
*     (prec = ///
*         /* BLP2_lnHP_peso BLP3_lnHP_peso BLP5_1lnHP_peso BLP5_2lnHP_peso */ ///
*         BLP*_espaco_interno_ln BLP*_*_espaco_interno_ln ///
*         BLP*_pilotoauto BLP*_*_pilotoauto ///
*         BLP*_tracao BLP*_*_tracao BST_1 BST_1_1), ///
*     market(ano_cidade) ///
*     robust ///
*     nests(carroceria) ///
*     msize(mkt_pop_) ///
*     gmm2s ///
*     msimulation(marca) ///
*     onlymc ///
*     vat(VAT) ///
*     elasticities(marca)
	
* rcl share_geral ///
*     /* lnHP_peso */ potencia_ln carga_ln espaco_interno_ln pilotoauto tracao cilindradas ///
*     (prec_ln = BLP* BST*), ///
*     market(ano_cidade) ///
*     robust ///
*     nests(carroceria) ///
*     msize(mkt_pop_) ///
*     tsls


* * ______________________________________________________________________________
* *
* *                        ANINHANDO POR CARROCERIA E ORIGEM 
* * ______________________________________________________________________________
                                      
* rcl share_geral lnHP_peso lnespaço_interno pilotoauto tracao litros_em_cc1 litros_em_cc2 litros_em_cc3 litros_em_cc4 litros_em_cc6 litros_em_cc1__primeira litros_em_cc2__primeira litros_em_cc3__primeira litros_em_cc4__primeira litros_em_cc6__primeira litros_em_cc1__segunda litros_em_cc2__segunda litros_em_cc3__segunda litros_em_cc4__segunda litros_em_cc6__segunda (preco_corrigido = BLP2_lnHP_peso BLP3_lnHP_peso BLP5_1lnHP_peso BLP5_2lnHP_peso BLP2_lnespaço_interno BLP3_lnespaço_interno BLP5_1lnespaço_interno BLP5_2lnespaço_interno BLP2_pilotoauto BLP3_pilotoauto BLP5_1pilotoauto BLP5_2pilotoauto BLP2_tracao BLP3_tracao BLP5_1tracao BLP5_2tracao  BST_1 BST_1_1), market(ano_city) robust nests(capacidade_litros carroceria) msize(Market_poten) gmm2s


* * ______________________________________________________________________________
* *
* *                  ANINHANDO POR CARROCERIA, ORIGEM E COMBUSTIVEL 
* * ______________________________________________________________________________

* rcl share_geral lnHP_peso lnespaço_interno pilotoauto tracao litros_em_cc1 litros_em_cc2 litros_em_cc3 litros_em_cc4 litros_em_cc6 litros_em_cc1__primeira litros_em_cc2__primeira litros_em_cc3__primeira litros_em_cc4__primeira litros_em_cc6__primeira litros_em_cc1__segunda litros_em_cc2__segunda litros_em_cc3__segunda litros_em_cc4__segunda litros_em_cc6__segunda (preco_corrigido = BLP2_lnHP_peso BLP3_lnHP_peso BLP5_1lnHP_peso BLP5_2lnHP_peso BLP2_lnespaço_interno BLP3_lnespaço_interno BLP5_1lnespaço_interno BLP5_2lnespaço_interno BLP2_pilotoauto BLP3_pilotoauto BLP5_1pilotoauto BLP5_2pilotoauto BLP2_tracao BLP3_tracao BLP5_1tracao BLP5_2tracao  BST_1 BST_1_1), market(ano_city) robust nests(combustivel_ capacidade_litros carroceria) msize(Market_poten) gmm2s
                                                       
        
* * Elasticidades preço da demanda na mão

* gen elasticidade=_b[preco_corrigido]* preco_corrigido*(1/1-

* prec/_b[M_lsjg])*(1-exp_M_lsjg*(1-_b[M_lsjg])-_b[M_lsjg]*sh)
                                                               