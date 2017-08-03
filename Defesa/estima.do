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
* TESTANDO ALGUMAS REGIÕES
********************************************************************************
keep if subregiao == "SAO PAULO"
keep if cidadeprincipal == "SAO PAULO"
drop if ano == 2013

* keep if cidadeprincipal == "BAURU"

* keep if cidadeprincipal == "RIO DE JANEIRO" 

* keep if cidadeprincipal == "SAO PAULO" | ///
* 	cidadeprincipal == "BELO HORIZONTE" | ///
* 	cidadeprincipal == "RIO DE JANEIRO" | ///
* 	cidadeprincipal == "BRASILIA" | ///
* 	cidadeprincipal == "CURITIBA" | ///
* 	cidadeprincipal == "SALVADOR"

keep if ///
    cidadeprincipal == "PORTO VELHO" | ///
    cidadeprincipal == "MANAUS" | ///
    cidadeprincipal == "RIO BRANCO" | ///
    cidadeprincipal == "CAMPO GRANDE" | ///
    cidadeprincipal == "MACAPA" | ///
    cidadeprincipal == "BRASILIA" | ///
    cidadeprincipal == "BOA VISTA" | ///
    cidadeprincipal == "CUIABA" | ///
    cidadeprincipal == "PALMAS" | ///
    cidadeprincipal == "TERESINA" | ///
    cidadeprincipal == "SAO PAULO" | ///
    cidadeprincipal == "RIO DE JANEIRO" | ///
    cidadeprincipal == "BELEM" | ///
    cidadeprincipal == "SAO LUÍS" | ///
    cidadeprincipal == "GOIANIA" | ///
    cidadeprincipal == "SALVADOR" | ///
    cidadeprincipal == "MACEIO" | ///
    cidadeprincipal == "PORTO ALEGRE" | ///
    cidadeprincipal == "CURITIBA" | ///
    cidadeprincipal == "FLORIANOPOLIS" | ///
    cidadeprincipal == "BELO HORIZONTE" | ///
    cidadeprincipal == "FORTALEZA" | ///
    cidadeprincipal == "RECIFE" | ///
    cidadeprincipal == "JOAO PESSOA" | ///
    cidadeprincipal == "ARACAJU" | ///
    cidadeprincipal == "NATAL" | ///
    cidadeprincipal == "VITORIA"
	
* bysort marca: generate numero = _N
* replace numero = numero/_N
* gen popular = 0
* replace popular = 1 if numero > 0.05
* drop if popular != 0

* keep if marca == "CHEVROLET" | ///
*         marca == "CITROEN" | ///
*         marca == "FORD" | ///
*         marca == "FIAT" | ///
*         marca == "PEUGEOT" | ///
*         marca == "RENAULT" | ///
*         marca == "VOLKSWAGEN"

* generate popular = 0
* replace popular = 1 if marca == "CHEVROLET" | ///
*         marca == "CITROEN" | ///
*         marca == "FORD" | ///
*         marca == "FIAT" | ///
*         marca == "PEUGEOT" | ///
*         marca == "RENAULT" | ///
*         marca == "VOLKSWAGEN"

* Usando CO2 que faz sentido
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

* Preços pequenos
* drop if preco > 100000
* replace popular = 0
* replace popular = 1 if preco < 100000

*-------------------------------------------------------------------------------
* CONTAGEM DAS FIRMAS
*-------------------------------------------------------------------------------
sort ano_local segmento
bysort ano_local segmento: egen contagem_marcas = count(ano_local)
sort ano_local segmento marca_e
bysort ano_local segmento marca_e: egen temp = count(ano_local)
replace contagem_marcas = contagem_marcas - temp
drop temp



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
    transmissao ///
    tracao ///
    /* pilotoauto */ ///
    arcondicionado ///
    /* rodaleve */ ///
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
	transmissao ///
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
	flex ///
	combustivel_e
	
global IV ///
    BLP*transmissao ///
    BLP*tracao ///
    BLP*pilotoauto ///
    BLP*arcondicionado ///
    BLP*rodaleve ///
    BLP*SOM ///
    BLP*DVD ///
    BLP*vidros ///
    BLP*computer ///
    BLP*direcao ///
    BLP*travcentral ///
    BLP*alarme ///
    BLP*airbag ///
    BLP*ABS1 EBD1 ///
    BLP*acabamento_luxo ///
    BLP*garantia ///
    BLP*espaco_interno_ln ///
    BLP*consumo ///
    BLP*peso_bruto_ln ///
    BLP*carga_paga_max ///
    BLP*potencia_especifica ///
    BLP*veloc_max ///
    BLP*aceleracao ///
    BST*
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
*stepwise, pr(0.2): regress preco $IV
*lars preco $IV
*regress preco_ln $IV


*-------------------------------------------------------------------------------
* REGRESSÃO
*-------------------------------------------------------------------------------
* msimulations com a opção onlymc calcula apenas o custo marginal e markup sem simular.
rcl share_geral ///
    $X ///
    (preco_ln = $IV), ///
    market(ano_local) ///
	msize(mercado_potencial) ///
    /*robust*/ ///
    nests(segmento) ///
    tsls ///
    /* msimulation(marca_e) ///
    onlymc */ ///
    elasticities(marca_e)


*-------------------------------------------------------------------------------
* PARÂMETROS, MARKUP, E CUSTO MARGINAL
*-------------------------------------------------------------------------------
scalar alpha   = -_b[preco]
scalar sigma_1 = _b[__sigma_g]
scalar sigma_2 = _b[__sigma_hg]

matrix theta = e(b)

generate xb0 = __xb0
generate ksi = __ksi
generate lnss0 = __lnss0
generate delta = __delta
generate shat = __shat
	
	
* ______________________________________________________________________________
*
*                                       IVREG 
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* VARIÁVEIS
*-------------------------------------------------------------------------------
global X ///
    ano_dummy* ///
    acordo ///
    potencia ///
    aceleracao ///
    veloc_max ///
    torque ///
    dist_eixos ///
    transmissao ///
	cilindradas

global IV ///
	contagem_marcas ///
    BLP5_2_potencia ///
    BLP5_2_aceleracao ///
    BLP5_2_veloc_max ///
    BLP5_2_torque ///
    BLP5_2_dist_eixos ///
	BLP5_2_cilindradas

*-------------------------------------------------------------------------------
* NINHO
*-------------------------------------------------------------------------------
global ninhos ///
    segmento combustivel_e

*-------------------------------------------------------------------------------
* ANINHAMENTO
*-------------------------------------------------------------------------------
/*
s_jt:   share de cada veículo no ano
outshr: share que não comprou
lnsj0:  ln do share normalizado

sg1: Share do ninho ano combustivel
sg2: Share do subninho ano combustivel segmento
*/

generate s_jt = vendas_ano / mercado_potencial
bysort ano subregiao cidadeprincipal: egen outshr = sum(s_jt)
replace outshr = 1 - outshr
generate lnsj0 = ln(s_jt / outshr)

Share dos Ninhos
* local i : word count $ninhos
local i = 0
local ninho
foreach variavel of global ninhos {
    local i = `i' + 1
    local ninho `ninho' `variavel'
    egen sg`i' = sum(s_jt), by(`ninho' ano subregiao cidadeprincipal)
}

if (word count $ninhos) == 1 {
    generate sg2 = sg1
}

* egen sg1 = sum(s_jt), by(segmento ano_local)
* egen sg2 = sum(s_jt), by(segmento consumo_e ano_local)

* Algumas relações
generate sg2g1   = sg2 / sg1
generate lnsg2g1 = ln(sg2g1)
generate sjg2    = s_jt / sg2
generate lnsjg2  = ln(s_jt/sg2)
generate sjg1    = s_jt / sg1 //Mudei o nome de sjgg para sjg1


*-------------------------------------------------------------------------------
* REGRESSÃO
*-------------------------------------------------------------------------------
ivreg2 lnsj0 ///
    preco_ln lnsjg2 lnsg2g1 $X

ivreg2 lnsj0 ///
    (preco_ln lnsjg2 lnsg2g1 = $IV) $X

*-------------------------------------------------------------------------------
* PARÂMETROS, MARKUP, E CUSTO MARGINAL
*-------------------------------------------------------------------------------
scalar alpha   = -_b[preco]
scalar sigma_1 = _b[lnsjg2]
scalar sigma_2 = _b[lnsg2g1]

if (word count $ninhos) == 1 {
    scalar sigma_2 = sigma_1
}

matrix theta = e(b)

* generate xb0 = __xb0
* generate ksi = __ksi
* generate lnss0 = __lnss0
* generate delta = __delta
* generate shat = __shat


********************************************************************************
* ELASTICIDADES
********************************************************************************


generate ownelas = - alpha * [1 / (1 - sigma_1) ///
    - (1 / (1 - sigma_1) ///
    - 1 / (1 - sigma_2)) * sjg2 ///
    - (sigma_2 / (1 - sigma_2)) * sjg1 ///
    - s_jt]
summarize ownelas, d
tabulate marca_e, summarize(ownelas)
tabulate marca_e [aweight=vendas_ano], summarize(ownelas)

generate cross_subgroup = alpha * [(1 / (1 - sigma_1) ///
    - 1 / (1 - sigma_2)) * sjg2 ///
    + (sigma_2 / (1 - sigma_2)) * sjg1 /// 
    + s_jt] * preco
generate cross_group    = alpha * [(sigma_2 / (1 - sigma_2)) * sjg1 /// 
    + s_jt] * preco
generate cross_outgroup = alpha * s_jt * preco

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

generate mc = (preco - markup) / (1 + VAT)



* ______________________________________________________________________________
*
*                             SALVANDO 
* ______________________________________________________________________________

* keep marca modelo ano combustivel litros carroceria transmiss portas ///
*     subregiao cidadeprincipal ///
*     segmento ///
*     share_geral preco preco_ln /// 
*     xb0 ksi lnss0 delta shat markup mc

* save estimado.dta

