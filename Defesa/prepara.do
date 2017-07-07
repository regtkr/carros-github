/*
PREPARA.DO:

Trata os dados para que a estimação;
Cria variáveis instrumentais
*/

* ______________________________________________________________________________
*
*                             ABRINDO A BASE DE DADOS
* ______________________________________________________________________________

clear
cd "/mnt/84DC97E6DC97D0B2/carros"
use "BIG_File_with_fuel.dta", clear


* ______________________________________________________________________________
*
* 							    FORMATANDO OS DADOS
* ______________________________________________________________________________

/*
Selecionando os dados que são considerados relevantes, como também podendo
transformá-las para melhor uso.
*/

*-------------------------------------------------------------------------------
* LISTA DE VARIÁVEIS A INSTRUMENTALIZAR E OUTRAS VARIÁVEIS A SEGUR
*-------------------------------------------------------------------------------
/* 
instr: lista vazia a ser preenchida de variáveis para instrumentalizar
 a partir destas usando Berry.
outras: variáveis que serão mantidas na base.  
*/
local instr
local outras

*-------------------------------------------------------------------------------
* TEMPO
*-------------------------------------------------------------------------------
* Excluido os anos irrelevantes
keep if inrange(ano, 2008, 2013)

local outras `outras' ano

*-------------------------------------------------------------------------------
* LOCAL
*-------------------------------------------------------------------------------
local outras `outras' regiao subregiao cidadeprincipal

*-------------------------------------------------------------------------------
* QUANTIDADE VENDIDA
*-------------------------------------------------------------------------------
* Vendas no ano
local outras `outras' vendas_ano

* Vendas no mes
forvalues i = 1(1)12 {
    local outras `outras' sales`i'
} 

*-------------------------------------------------------------------------------
* PREÇO
*-------------------------------------------------------------------------------
* Removendo carros sem preço
drop if prec == .
* Preços estão multiplicados por 100, dividindo-os:
replace prec = prec / 100

local outras `outras' prec

********************************************************************************
* CORRIGINDO A INFLAÇÃO
********************************************************************************
* TODO

*-------------------------------------------------------------------------------
* DADOS DUPLICADOS
*-------------------------------------------------------------------------------
* Excluindo
* duplicates drop marca modelo ano litros transmiss carroceria, force

*-------------------------------------------------------------------------------
* TRANSMISSÃO
*-------------------------------------------------------------------------------
generate transmissao = .
replace  transmissao = 1 if transmiss == "automática"
replace  transmissao = 0 if transmiss == "manual"

local instr `instr' transmissao 

*-------------------------------------------------------------------------------
* TRAÇÃO
*-------------------------------------------------------------------------------
generate tracao = 0
replace  tracao = 1 if trca == "4x4"

local instr `instr' tracao

*-------------------------------------------------------------------------------
* PILOTO AUTOMÁTICO
*-------------------------------------------------------------------------------
generate pilotoauto = 0
replace  pilotoauto = 1 if pilo == "std"

local instr `instr' pilotoauto

*-------------------------------------------------------------------------------
* AR CONDICIONADO
*-------------------------------------------------------------------------------
generate arcondicianado = 0
replace arcondicianado = 1 if arco == "std"

local instr `instr' arcondicianado

*-------------------------------------------------------------------------------
* MATERIAL DA RODA
*-------------------------------------------------------------------------------
generate rodaleve = 0
replace  rodaleve = 1 if roda_m == "liga leve"

local instr `instr' rodaleve

*-------------------------------------------------------------------------------
* SOM
*-------------------------------------------------------------------------------
generate SOM = 0
replace  SOM= 1 if som == "std"

local instr `instr' SOM

*-------------------------------------------------------------------------------
* DVD
*-------------------------------------------------------------------------------
generate DVD = 0
replace  DVD = 1  if dvd == "std"

local instr `instr' DVD

*-------------------------------------------------------------------------------
* VIDROS ELÉRICOS
*-------------------------------------------------------------------------------
generate vidros = 0
replace  vidros = 1 if viel == "std"

local instr `instr' vidros

*-------------------------------------------------------------------------------
* COMPUTADOR DE BORDO
*-------------------------------------------------------------------------------
generate computer = 0
replace  computer = 1 if copt == "std"

local instr `instr' computer

*-------------------------------------------------------------------------------
* DIREÇÃO CHIC
*-------------------------------------------------------------------------------
generate direcao = 0
replace  direcao = 1 ///
	if dira_t == "hidráulica" | dira_t=="elérica" | dira_t=="eletro-hidrául."

local instr `instr' direcao

*-------------------------------------------------------------------------------
* TRAVAMENTO CENTRAL
*-------------------------------------------------------------------------------
generate travcentral = 0
replace  travcentral = 1 if trav == "std"

local instr `instr' travcentral

*-------------------------------------------------------------------------------
* ALARME
*-------------------------------------------------------------------------------
generate alarme = 0
replace  alarme = 1 if alam == "std"

local instr `instr' alarme

*-------------------------------------------------------------------------------
* AIRBAG
*-------------------------------------------------------------------------------
generate airbag = 0
replace airbag = 1 if aird == "std"
replace airbag = 0 if aird != "std" & aird!=""

local instr `instr' airbag

*-------------------------------------------------------------------------------
* FREIOS
*-------------------------------------------------------------------------------
generate ABS1 = 0
replace  ABS1 = 1 if abs == "std"

generate EBD1 = 0
replace  EBD1 = 1 if ebd == "std"

local instr `instr' ABS1
local instr `instr' EBD1

*-------------------------------------------------------------------------------
* ACABAMENTO DE LUXO
*-------------------------------------------------------------------------------
generate acabamento_luxo = 0
replace  acabamento_luxo = 1 if aclu == "std"

local instr `instr' acabamento_luxo

*-------------------------------------------------------------------------------
* GARANTIA
*-------------------------------------------------------------------------------
rename gato_d garantia

local instr `instr' garantia

*-------------------------------------------------------------------------------
* POTÊCIA DO MOTOR
*-------------------------------------------------------------------------------
*qui 
generate potencia_categorica = irecode(pote_c, 100, 200, 300, 400, 500, 750)
generate potencia_ln = ln(pote_c)
rename pote_c potencia

local instr `instr' potencia potencia_ln

*-------------------------------------------------------------------------------
* ESPAÇO INTERNO
*-------------------------------------------------------------------------------
* diex_X, X corresponde a: a(altura), l(largura), c(comprimento)
generate area_frontal   = diex_l * diex_a
generate area_superior  = diex_l * diex_c
generate volume_externo = diex_l * diex_c * diex_a

generate area_frontal_ln   = ln(area_frontal)
generate area_superior_ln  = ln(area_superior)
generate volume_externo_ln = ln(volume_externo)

* Espaço interno: distância entre os eixos X largura
generate espaco_interno    = diex_l * diex_e
generate espaco_interno_ln = ln(espaco_interno)

* Dimenções
generate dist_eixos_ln  = ln(diex_e)
generate largura_ln     = ln(diex_l)
generate comprimento_ln = ln(diex_c)

local instr `instr' area_frontal area_superior volume_externo ///
	area_frontal_ln area_superior_ln volume_externo_ln ///
	espaco_interno espaco_interno_ln ///
    dist_eixos_ln largura_ln comprimento_ln

*-------------------------------------------------------------------------------
* CONSUMO
*-------------------------------------------------------------------------------
generate consumo_ln = ln(cons_c)
rename   cons_c consumo

local instr `instr' consumo consumo_ln

*-------------------------------------------------------------------------------
* PESO
*-------------------------------------------------------------------------------
generate peso_carga = irecode(peso_b, 1500, 2000, 2500, 3000, 4000)

generate carga_paga_max = peso_b - peso_m
generate carga          = irecode(carga_paga_max, 140, 300, 400, 500, 600, 900)
generate carga_ln       = ln(carga_paga_max)

generate peso_bruto_ln = ln(peso_b)
rename   peso_b peso_bruto
rename   carg_v carga_carro

local instr `instr' carga_paga_max carga_ln peso_bruto peso_bruto_ln carga_carro

*-------------------------------------------------------------------------------
* VELOCIADADE MÁXIMA
*-------------------------------------------------------------------------------
generate veloc_max_ln = ln(dese_v)
rename   dese_v veloc_max

local instr `instr' veloc_max

*-------------------------------------------------------------------------------
* ACELERAÇÃO DE 0 A 100
*-------------------------------------------------------------------------------
rename dese_a aceleracao

local instr `instr' aceleracao

*-------------------------------------------------------------------------------
* CILINDRADAS
*-------------------------------------------------------------------------------
rename moto_cc cilindradas

* acordo?
generate cilindradas_disc = .

replace cilindradas_disc = 1 if litros == 1 & acordo == 1
replace cilindradas_disc = 2 if litros == 1 & acordo == 0
replace cilindradas_disc = 3 if litros >  1 & litros <= 2 & acordo == 1
replace cilindradas_disc = 4 if litros >  1 & litros <= 2 & acordo == 0
replace cilindradas_disc = 5 if litros >  2 & acordo == 1
replace cilindradas_disc = 6 if litros >  2 & acordo == 0

* Removendo fora destes conjuntos
drop if cilindradas_disc == .

* local instr `instr' cilindradas //não faz sentido vai estar refletido na pot do motor
local outras `outras' cilindradas

*-------------------------------------------------------------------------------
* SEGMENTO
*-------------------------------------------------------------------------------
generate segmento = 1 if jato=="AS Carro Grande"
replace  segmento = 2 if jato=="AS Carro Luxo"
replace  segmento = 3 if jato=="AS Carro Médio+" ///
                       | jato=="AS Carro Médio-"
replace  segmento = 4 if jato=="AS Esporte"
replace  segmento = 5 if jato=="AS MPV" ///
                       | jato=="AS Perua Grande" ///
                       | jato==" AS Perua Luxo" /// 
                       | jato=="AS Perua Média"
replace  segmento = 6 if jato=="AS Pequeno"
replace  segmento = 7 if jato=="AS Popular"
replace  segmento = 8 if jato=="AS SUV"

rename tipo_segmento segmento

label define TIPO 1 "CARRO GRANDE" ///local instr `instr' aceleracao
                  2 "CARRO DE LUXO" ///
                  3 "CARRO MEDIO" ///
                  4 "ESPORTIVO" ///
                  5 "MPV_PERUA" ///
                  6 "CARRO PEQUENO" ///
                  7 "CARRO POPULAR" ///
                  8 "SUV"

label values segmento TIPO

local outras `outras' segmento

*-------------------------------------------------------------------------------
* CARROCERIA
*-------------------------------------------------------------------------------
local outras `outras' carroceria

*-------------------------------------------------------------------------------
* MARCA
*-------------------------------------------------------------------------------
local outras `outras' marca

*-------------------------------------------------------------------------------
* PAIS ONDE FOI PRODUZIDO
*-------------------------------------------------------------------------------
* Produzdo no Basil
generate brasil = 0
replace  brasil = 1 if pais == "BR"

* Produzidos no mercosul
generate mercosul = 0
replace  mercosul = 1 if pais == "A" | pais == "UY" | pais == "BR"

* Produzido dentro de acodo comercial com o Brasil
generate acordo = 0
replace  acordo = 1 if pais=="BR" | pais=="A" | pais=="MEX" | pais=="UY"

* Carros fora do mercosul e de acordos comerciais
generate importado = 1
replace  importado = 0 if pais=="BR" | pais=="A" | pais=="MEX" | pais=="UY"

local outras `outras' brasil mercosul acordo importado

* ______________________________________________________________________________
*
*                        REMOVENDO VARIÁVEIS NÃO UTILIZADAS 
* ______________________________________________________________________________

keep `instr' `outras'


* ______________________________________________________________________________
*
*                          TRANSFORMANDO EM PAINEL LONGO 
* ______________________________________________________________________________

* Transformando vendas mensais(sales) na forma longa:
reshape long sales, j(mes)


* ______________________________________________________________________________
*
*                             EVENTOS 
* ______________________________________________________________________________
* * Criando varável de tempo para os períodos de redução do ipi e das políticas comerciais.

* generate queda_1 = 1 if mes_ano==12 | mes_ano==13 | mes_ano==14 | mes_ano==15 | mes_ano==16 | mes_ano==17 | mes_ano==18 | mes_ano==19 | mes_ano==20 | mes_ano==21 | mes_ano==22 | mes_ano==23 | mes_ano==24 | mes_ano==25 | mes_ano==26 | mes_ano==27 
* replace  queda_1 = 0 if mes_ano==1 | mes_ano==2 | mes_ano==3 | mes_ano==4 | mes_ano==5 | mes_ano==6 | mes_ano==7 | mes_ano==8 | mes_ano==9 | mes_ano==10 | mes_ano==11 | mes_ano==28 | mes_ano==29 | mes_ano==30 | mes_ano==31 | mes_ano==32 | mes_ano==33 | mes_ano==34 | mes_ano==35 | mes_ano==36 | mes_ano==37 | mes_ano==38 | mes_ano==39 | mes_ano==40 | mes_ano==41 | mes_ano==42 | mes_ano==43 | mes_ano==44 | mes_ano==45 | mes_ano==46 | mes_ano==47 | mes_ano==48 | mes_ano==49 | mes_ano==50 | mes_ano==51 | mes_ano==52 | mes_ano==53 | mes_ano==54 | mes_ano==55 | mes_ano==56 | mes_ano==57 | mes_ano==58 | mes_ano==59 | mes_ano==60 | mes_ano==61 | mes_ano==62 | mes_ano==63 | mes_ano==64 | mes_ano==65 

* gen queda_2 = 1 if mes_ano==49 | mes_ano==50 | mes_ano==51 | mes_ano==52 | mes_ano==53 | mes_ano==54 | mes_ano==55 | mes_ano==56 | mes_ano==57 | mes_ano==58 | mes_ano==59 | mes_ano==60 | mes_ano==61 | mes_ano==62 | mes_ano==63 | mes_ano==64 | mes_ano==65
* replace queda_2 = 0 if mes_ano==1 | mes_ano==2 | mes_ano==3 | mes_ano==4 | mes_ano==5 | mes_ano==6 | mes_ano==7 | mes_ano==8 | mes_ano==9 | mes_ano==10 | mes_ano==11 | mes_ano==12 | mes_ano==13 | mes_ano==14 | mes_ano==15 | mes_ano==16 | mes_ano==17 | mes_ano==18 | mes_ano==19 | mes_ano==20 | mes_ano==21 | mes_ano==22 | mes_ano==23 | mes_ano==24 | mes_ano==25 | mes_ano==26 | mes_ano==27 | mes_ano==28 | mes_ano==29 | mes_ano==30 | mes_ano==31 | mes_ano==32 | mes_ano==33 | mes_ano==34 | mes_ano==35 | mes_ano==36 | mes_ano==37 | mes_ano==38 | mes_ano==39 | mes_ano==40 | mes_ano==41 | mes_ano==42 | mes_ano==43 | mes_ano==44 | mes_ano==45 | mes_ano==46 | mes_ano==47 | mes_ano==48  


* * Criando variáveis de interações da capacidade em litros dos carros (importados e nacionais) com os períodos de queda do IPI.

* gen litros_em_cc1__primeira = litros_em_cc1 * queda_1
* gen litros_em_cc2__primeira = litros_em_cc2 * queda_1
* gen litros_em_cc3__primeira = litros_em_cc3 * queda_1
* gen litros_em_cc4__primeira = litros_em_cc4 * queda_1
* gen litros_em_cc5__primeira = litros_em_cc5 * queda_1
* gen litros_em_cc6__primeira = litros_em_cc6 * queda_1

* gen litros_em_cc1__segunda = litros_em_cc1 * queda_2
* gen litros_em_cc2__segunda = litros_em_cc2 * queda_2
* gen litros_em_cc3__segunda = litros_em_cc3 * queda_2
* gen litros_em_cc4__segunda = litros_em_cc4 * queda_2
* gen litros_em_cc5__segunda = litros_em_cc5 * queda_2
* gen litros_em_cc6__segunda = litros_em_cc6 * queda_2


* ______________________________________________________________________________
*
* BASE DE VOLUME ORIGINAL
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* 					UNINDO A BASE DE MERCADO POTENCIAL
* ______________________________________________________________________________
merge m:1 ano regiao subregiao cidade using "Pot_mkt.dta"

drop if _merge != 3
drop _merge

* ______________________________________________________________________________
*
* 	CONSTRUINDO MERCADO POTECIAL E CALCULANDO A PARTICIPAÇÃO NOS MERCADOS
* ______________________________________________________________________________

* Construindo variável de share do bem j e do bem externo
bysort ano cidadeprincipal: egen vendas_total = sum(vendas_ano)
generate share_geral = vendas_ano / mkt_pop_

bysort ano cidadeprincipal: egen share_insidegood = total(share_geral)
generate share_outsidegood = 1 - share_insidegood
generate share_geral_ln = ln(share_geral)
generate share_outsidegood_ln = ln(share_outsidegood)
generate dif_share = ln(share_geral) - ln(share_outsidegood)

* ______________________________________________________________________________
*
*                                   CRIANDO GRUPOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* CIDADE E ANO
*-------------------------------------------------------------------------------
egen ano_cidade = group(ano cidadeprincipal), label


* ______________________________________________________________________________
*
*                         CRIANDO VARIÁVEIS INSTRUMENTAIS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* INSTRUMENTOS BLP
*-------------------------------------------------------------------------------
sort ano_cidade marca
foreach variable of local instr {
    bysort ano_cidade marca: egen ownsum = total(`variable')
    * Instrumento BLP (2) para outros produzidos pela mesma firma dentro do mercado.
    qui generate BLP2_`variable' = ownsum - `variable'
    bysort ano_cidade: egen totsum = total(`variable')
    * Instrumento BLP (3) para produtos produzidos por outras firmas fora do mercado.
    qui generate BLP3_`variable' = totsum - ownsum
    drop ownsum
    drop totsum
}

*-------------------------------------------------------------------------------
* INSTRUMENTOS BST
*-------------------------------------------------------------------------------
sort ano_cidade marca carroceria
foreach variable of local instr {
    bysort ano_cidade marca carroceria: egen ownsum = total(`variable')
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
	mercado no mesmo segmento.
    * Soma das características dos outros produtos produzidos pela mesma firma
	localizados no mesmo segmento. */
    qui generate BLP5_1_`variable' = ownsum - `variable'   
    bysort ano_cidade carroceria: egen totsum = total(`variable')
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
	mercado no mesmo segmento.
    * Soma das características dos outros produtos produzidos por outras firmas
	localizados no mesmo segmento. */ 
    qui generate BLP5_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}

*-------------------------------------------------------------------------------
* PROXY DA SUBSTITUTIBILIDADE
*-------------------------------------------------------------------------------
/* Número de modelos de uma mesma montadora vendidos em um mesmo grupo como 
proxy da substitubilidade dos produtos. */
bysort ano_cidade marca carroceria: egen BST_1 = count(prec)

/* Número de modelos em um dado grupo do mercado como proxy da substitubilidade
 dos produtos. */
bysort ano_cidade marca: egen BST_1_1 = count(prec)

* Número de empresas pertencentes em um mesmo grupo como proxy do grau de concorrência.
*----------------------------------------------------------------------------------------


* ______________________________________________________________________________
*
*                                   SALVANDO
* ______________________________________________________________________________

save base_limpa_instr.dta

