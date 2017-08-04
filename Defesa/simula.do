/* SIMULA.DO:
	Simula um imposto FEEBATE apartir da estimativa de ESTIMA.DO
	PP: Pivot da emissão de CO2
*/

* ______________________________________________________________________________
*
* 							ABRINDO ESTIMATIVAS 
* ______________________________________________________________________________



* ______________________________________________________________________________
*
* 							IMPOSTO GOVERNO 
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* GANHO DO GOVERNO POR VENDA
*-------------------------------------------------------------------------------
generate imposto = (VAT / (1 + VAT)) * prec
generate imposto_modelo = imposto * vendas_ano
egen imposto_total = sum(imposto_modelo)
egen venda_total = sum(vendas_ano)
replace imposto_total = imposto_total / venda_total

*-------------------------------------------------------------------------------
* MEDIA DE CO2
*-------------------------------------------------------------------------------
generate CO2_modelo = CO2 * vendas_ano
egen CO2_total = sum(CO2_modelo)
generate CO2_media = CO2_total / venda_total
summarize CO2_media

*-------------------------------------------------------------------------------
* TAXANDO
*-------------------------------------------------------------------------------
generate simco2tax = (CO2 - PP) * tax
summarize simco2tax, d

* ______________________________________________________________________________
*
* 							VENDAS SIMULADAS 
* ______________________________________________________________________________

/*
ln(S_jt) - ln(S_0t) = X' * BETA + QUI - ALPHA * P + SIGMA_1 * ln(S_jht) + SIGMA_2 * ln(S_hgt)

DELTA = X' * BETA + QUI - ALPHA * P
*/

*-------------------------------------------------------------------------------
* ESTIMAÇÃO
*-------------------------------------------------------------------------------
********************************************************************************
* * Já feito no contrai.do com o RCL, ver com prof qual melhor
********************************************************************************
ivreg2 lnsj0 $X (prec lnsjg2 lnsg2g1 = $IV)

scalar sigma_1 = _b[lnsjg2]
scalar sigma_2 = _b[lnsg2g1]
scalar alpha = - _b[prec]

* drop markup mc
generate markups = alpha * ///
    [1 / (1 - sigma_1) ///
    - (1 / (1 - sigma_1) ///
    - 1 / (1 - sigma_2)) * sjg2m ///
    - (sigma_2 / (1-sigma_2)) * sjg1m 
    - sm] 
replace markups = 1 / markups
generate mc = (prec - markups) / (1+VATrate)

generate markup_modelo = markups * vendas_ano // if year==2008
egen markup_total = sum(markup_modelo) // if year==2008
generate markup_medio = markup_total / venda_total // if year==2008
summarize markup_medio

*-------------------------------------------------------------------------------
* NOVO DELTA
*-------------------------------------------------------------------------------
* Já feito no contrai.do com o RCL
generate preco_novo = mc + markups
generate delta_sim = delta - alpha * prec + alpha * preco_novo


generate Dj = exp(delta_sim / (1 - sigma_1))
egen Dh = sum(Dj), by(segmento combustivel ano)
generate Dhtemp = Dh ^ ((1 - sigma_1) / (1 - sigma_2))

* sort segmento combustivel ano
bysort segmento combustivel ano: gen helpvar = _n 
generate help2var = 0
replace help2var = 1 if helpvar == 1
replace Dhtemp = Dhtemp * help2var
egen Dg = sum(Dhtemp), by(combustivel ano)

* sort combustivel ano
bysort combustivel ano: gen help3var = _n 
generate help4var = 0
replace help4var = 1 if help3var == 1
generate Dgtemp = [Dg ^ (1 - sigma_2)] * help4var

egen outshr2 = sum(Dgtemp), by(ano)
replace outshr2 = outshr2 + 1
replace outshr2 = 1 / outshr2
generate prshares = ///
	Dj * (Dh^((sigma_2 - sigma_1) / (1 - sigma_2))) * outshr2 * (Dg ^ (-sigma_2))
generate vendas_sim = prshares * mercado_potencial


*-------------------------------------------------------------------------------
* TABELAS
*-------------------------------------------------------------------------------
table segmento combustivel, contents(median prec median vendas_ano)
table segmento combustivel, contents(median preco_novo median vendas_sim)
table combustivel segmento, contents(median markup)

summarize CO2 /* if ano == 2008 */, d

generate CO2_classe = recode(CO2, 130, 160, 180, 200, 442)

table CO2_classe segmento ///
	if /* ano == 2008 & */ combustivel == "gasolina", ///
	contents(median prec median preco_novo median vendas_ano median vendas_sim count ano)

table CO2_classe segmento ///
	if /* ano == 2008 & */ combustivel == "álcool", ///
	contents(median prec median preco_novo median vendas_ano median vendas_sim count ano)

table CO2_classe segmento combustivel ///
	if 1/* ano == 2008 */, ///
	contents(median prec median preco_novo sum vendas_ano sum vendas_sim count ano)


generate CO2_modelo_sim = CO2 * vendas_sim
egen CO2_total_sim = sum(CO2_modelo_sim) /* if ano == 2008 */
egen venda_total_sim = sum(vendas_sim) /* if ano == 2008 */
generate CO2_media_sim = CO2_total_sim / venda_total_sim /* if ano == 2008 */
summarize CO2_media CO2_media_sim 

generate tax_CO2_modelo = simco2tax * vendas_sim /* if ano == 2008 */
egen tax_CO2_total = sum(tax_CO2_modelo) /* if ano == 2008 */
generate tax_CO2_media = tax_CO2_total / venda_total_sim /* if ano == 2008 */
summarize tax_CO2_total tax_CO2_media


* ______________________________________________________________________________
*
* 							GANHOS AMBIENTAIS 
* ______________________________________________________________________________

generate ganho_ambiental = CO2_total - CO2_total_sim /* if ano == 2008 */
generate ganho_ambiental_mil = ganho_ambiental / 1000000

generate CO2_ambiente_media = CO2_media - CO2_media_sim 
summarize ganho_ambiental_mil CO2_ambiente_media 

********************************************************************************
* DE ONDE VEIO ISSO: ganho_ambiental_STAR
********************************************************************************
generate ganho_ambiental_STAR = ganho_ambiental_mil / 5

generate ganho_ambiental_PERC = ///
	(ganho_ambiental / (CO2_total) * (venda_total_sim / venda_total)) * 100
summarize ganho_ambiental_STAR ganho_ambiental_PERC

generate ganho_ambiental_Euro = ganho_ambiental_STAR * 15
summarize ganho_ambiental_Euro

generate CO2_total_mil = CO2_total / 1000000
summarize CO2_total_mil

generate imposto_sim = (VAT / (1 + VAT)) * preco_novo /* if ano == 2008 */
generate imposto_modelo_sim = imposto_sim * vendas_sim /* if ano == 2008 */
egen imposto_total_sim = sum(imposto_modelo_sim) /* if ano == 2008 */
replace imposto_total_sim = imposto_total_sim / venda_total_sim /* if ano == 2008 */


* ______________________________________________________________________________
*
* 							GANHO DO GOVERNO 
* ______________________________________________________________________________

generate gov_rev_per_car = imposto_total_sim - imposto_total + tax_CO2_media
generate gov_rev_all = ///
	imposto_total_sim * venda_total_sim - imposto_total * venda_total + tax_CO2_total
generate gov_rev_per_car_euros = gov_rev_per_car
generate gov_rev_all_mil = gov_rev_all / 1000

generate actrev = imposto_total * venda_total / 1000

summarize  gov_rev_all_mil gov_rev_per_car_euros
summarize actrev


* ______________________________________________________________________________
*
* 							EXCEDENTE DO PRODUTOR 
* ______________________________________________________________________________

***markups/producer surplus***
********************************************************************************
* VATrate?
********************************************************************************
generate VATrate = 0

generate markups_star = preco_novo - (1 + VATrate) * mc - simco2tax

generate markup_modelo_sim = markups_star * vendas_sim /* if ano == 2008 */
egen markup_total_sim = sum(markup_modelo_sim) /* if ano == 2008 */
generate markup_medio_sim = markup_total_sim / venda_total_sim /* if ano == 2008 */
summarize markup_total_sim markup_medio_sim
summarize markup_total markup_medio

generate exc_prod_delta_mil = (markup_total_sim - markup_total) / 1000
generate markup_medio_delta = (markup_medio_sim - markup_medio)
summarize exc_prod_delta_mil markup_medio_delta

generate markup_total_mil = markup_total / 1000
summarize markup_total_mil

***outside good share difference***
egen outshr_sim = sum(prshares) /* if ano == 2008 */
replace outshr_sim = 1 - outshr_sim /* if ano == 2008 */
***outshare change***
generate outshract = outshr /* if ano == 2008 */
generate outshr_delta = (outshr_sim - outshract) * 100
summarize outshr_delta

generate outact_perc = outshract * 100
summarize outact_perc

generate W_act = (ln(1 / outshr)) / (-alpha)
generate W_sim = (ln(1 / outshr2)) / (-alpha)
table ano, contents(mean W_sim mean W_act)

generate W_act_all = W_act * vendas_ano
egen W_act_allsum = sum(W_act_all) /* if ano == 2008 */
generate W_sim_all = W_sim * vendas_sim
egen W_sim_allsum = sum(W_sim_all) /* if ano == 2008 */
summarize W_sim_allsum W_act_allsum

generate W_diff = ((W_act_allsum - W_sim_allsum) / W_act_allsum) * (-100)
summarize W_diff outshr_sim outshract

generate W_diffmil = (W_sim_allsum - W_act_allsum) / 1000
summarize W_diffmil, d

generate bem_estar_total = (W_act_allsum + markup_total + actrev * 1000) / 1000
generate bem_estar_total_sim = ///
	(W_sim_allsum ///
	+ markup_total_sim ///
	+ ganho_ambiental_Euro * 1000 ///
	+ imposto_total_sim * venda_total_sim ///
	+ tax_CO2_total) / 1000
generate TWdiff = bem_estar_total_sim - bem_estar_total
generate TWperc = (TWdiff / bem_estar_total) * 100

table CO2_classe combustivel /* if ano == 2008 */ , ///
	contents(median prec median preco_novo median vendas_ano median vendas_sim count ano)


* ______________________________________________________________________________
*
* 							TABELAS 
* ______________________________________________________________________________

generate venda_delta = (venda_total_sim - venda_total) / 1000
generate venda_delta_perc = (venda_delta / venda_total) * 100000
summarize venda_delta venda_delta_perc
summarize W_diffmil W_diff
generate percmark = (exc_prod_delta_mil / markup_total_mil) * 100
summarize exc_prod_delta_mil percmark
generate govperc = (gov_rev_all_mil / actrev) * 100
summarize gov_rev_all_mil govperc
summarize ganho_ambiental_Euro ganho_ambiental_PERC
summarize TWdiff TWperc

