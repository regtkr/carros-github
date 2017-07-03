/*
ESTIMA.DO:

Estima Nested Logit usando os intrumentos do Berry
*/

* cd "/mnt/84DC97E6DC97D0B2/carros"
* use "base_limpa_instr.dta", clear

* ______________________________________________________________________________
*
* 							INSTALANDO RCL
* ______________________________________________________________________________

ssc install rcl


* ______________________________________________________________________________
*
* 							ESTIMANDO POR ORIGEM 
* ______________________________________________________________________________

mergersim init, nests(Origem) price(lnpreco_corrigido) quantity(quantidade_vendida) marketsize(Market_poten) firm(empresas)

*model (1) mergersim e ivregress

xi:ivregress 2sls M_ls lnpotencia_motor lndiex_l lncarga (lnpreco_corrigido M_lsjg = BLP2_lnpotencia_motor BLP3_lnpotencia_motor BLP5_1lnpotencia_motor BLP5_2lnpotencia_motor BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l BLP2_lncarga BLP3_lncarga BLP5_1lncarga BLP5_2lncarga BST_1 BST_1_1), vce(robust)  

*model (2) mergersim e ivregress com todas as características

xi:ivregress 2sls M_ls arcondicionado transmissao tracao EBD1 Aca_de_luxo pilotoauto lnpeso_m lncarga lndiex_c lndiex_l lnpotencia_motor litros_em_cc1 litros_em_cc2 litros_em_cc3 litros_em_cc4 litros_em_cc6 (lnpreco_corrigido M_lsjg = BLP2_arcondicionado BLP3_arcondicionado BLP5_1arcondicionado BLP5_2arcondicionado BLP2_transmissao BLP3_transmissao BLP5_1transmissao BLP5_2transmissao BLP2_tracao BLP3_tracao BLP5_1tracao BLP5_2tracao BLP2_EBD1 BLP3_EBD1 BLP5_1EBD1 BLP5_2EBD1 BLP2_Aca_de_luxo BLP3_Aca_de_luxo BLP5_1Aca_de_luxo BLP5_2Aca_de_luxo BLP2_pilotoauto BLP3_pilotoauto BLP5_1pilotoauto BLP5_2pilotoauto BLP2_lnpotencia_motor BLP3_lnpotencia_motor BLP5_1lnpotencia_motor BLP5_2lnpotencia_motor BLP2_lndiex_c BLP3_lndiex_c BLP5_1lndiex_c BLP5_2lndiex_c BLP2_lndiex_l BLP3_lndiex_l BLP5_1lndiex_l BLP5_2lndiex_l BLP2_lnpeso_m BLP3_lnpeso_m BLP5_1lnpeso_m BLP5_2lnpeso_m BLP2_lncarga BLP3_lncarga BLP5_1lncarga BLP5_2lncarga BST_1 BST_1_1), vce(robust)   
