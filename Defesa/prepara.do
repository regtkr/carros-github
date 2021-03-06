/*
PREPARA.DO:

Trata os dados para que a estima��o;
Cria vari�veis instrumentais
*/

* ______________________________________________________________________________
*
*                             ABRINDO A BASE DE DADOS
* ______________________________________________________________________________

* clear
cd "/mnt/84DC97E6DC97D0B2/carros"
use "BIG_File_with_fuel.dta", clear


* ______________________________________________________________________________
*
*                          REMOVENDO DADOS ESTRANHOS 
* ______________________________________________________________________________

* Cortando regi�es nada a ver
drop if cidadeprincipal == "AAAAA"

generate outros = strmatch(cidadeprincipal,"OTHERS*")
drop if outros == 1
drop outros

drop if ano == 2013

* Vari�veis vazias
foreach var of varlist _all {
    capture assert mi(`var')
    if !_rc {
       drop `var'
    }
}

* Antigo merge da base
drop _merge

* Cortando marca de milion�rio
drop if marca == "FERRARI"
drop if marca == "ASTON MARTIN"
drop if marca == "BENTLEY"
drop if marca == "JAGUAR"
drop if marca == "LAMBORGHINI"
drop if marca == "LEXUS"
drop if marca == "MASERATI"
drop if marca == "ROLLS-ROYCE"


* ______________________________________________________________________________
*
*                             FORMATANDO OS DADOS
* ______________________________________________________________________________

/*
Selecionando os dados que s�o considerados relevantes, como tamb�m podendo
transform�-las para melhor uso.
*/

*-------------------------------------------------------------------------------
* LISTA DE VARI�VEIS A INSTRUMENTALIZAR E OUTRAS VARI�VEIS A SEGUR
*-------------------------------------------------------------------------------
/* 
instr: lista vazia a ser preenchida de vari�veis para instrumentalizar
 a partir destas usando Berry.
outras: vari�veis que ser�o mantidas na base.  
*/
local instr
local outras

*-------------------------------------------------------------------------------
* TEMPO
*-------------------------------------------------------------------------------
* Excluido os anos irrelevantes
keep if inrange(ano, 2008, 2013)

quietly tabulate ano, generate(ano_dummy)

local outras `outras' ano ano_dummy*

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
local outras `outras' sales_*

*-------------------------------------------------------------------------------
* PRE�O
*-------------------------------------------------------------------------------
rename prec preco
* Removendo carros sem pre�o
drop if preco == .
* Pre�os est�o multiplicados por 100, dividindo-os:
replace preco = preco / 100

generate preco_ln = ln(preco)

local outras `outras' preco preco_ln

********************************************************************************
* CORRIGINDO A INFLA��O
********************************************************************************
* TODO

*-------------------------------------------------------------------------------
* TRANSMISS�O
*-------------------------------------------------------------------------------
generate transmissao = .
replace  transmissao = 1 if trans == "autom�tica"
replace  transmissao = 0 if trans == "manual"

local instr `instr' transmissao 

*-------------------------------------------------------------------------------
* TRA��O
*-------------------------------------------------------------------------------
encode trca, generate(tracao)
* generate tracao = 0
* replace  tracao = 1 if trca == "4x4"
drop trca

local instr `instr' tracao

*-------------------------------------------------------------------------------
* COMPRESSOR
*-------------------------------------------------------------------------------
replace comp = "nenhum"
encode comp, generate(compressor)
* generate tracao = 0
* replace  tracao = 1 if comp == "4x4"
drop comp

local instr `instr' compressor

*-------------------------------------------------------------------------------
* PILOTO AUTOM�TICO
*-------------------------------------------------------------------------------
generate pilotoauto = 0
replace  pilotoauto = 1 if pilo == "std"

local instr `instr' pilotoauto

*-------------------------------------------------------------------------------
* AR CONDICIONADO
*-------------------------------------------------------------------------------
generate arcondicionado = 0
replace  arcondicionado = 1 if arco == "std"
replace  arcondicionado = 0 if arco_p != .

local instr `instr' arcondicionado

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
* VIDROS EL�RICOS
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
* DIRE��O CHIC
*-------------------------------------------------------------------------------
generate direcao = 0
replace  direcao = 1 if dira == "std"
	* if dira_t == "hidr�ulica" | dira_t=="el�rica" | dira_t=="eletro-hidr�ul."

generate hidraulica = 0
replace  hidraulica = 1 if dira_t == "hidr�ulica"

generate eletrica = 0
replace  eletrica = 1 if dira_t=="el�rica"

generate elethidr = 0
replace  elethidr = 1 if dira_t=="eletro-hidr�ul."

local instr `instr' direcao hidraulica eletrica elethidr

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
replace  airbag = 1 if aird == "std"

generate air_lat = 0
replace  air_lat = 1 if airl == "std"

local instr `instr' airbag air_lat

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
* ESPA�O INTERNO
*-------------------------------------------------------------------------------
* diex_X, X corresponde a: a(altura), l(largura), c(comprimento)
generate area_frontal   = diex_l * diex_a
generate area_superior  = diex_l * diex_c
generate volume_externo = diex_l * diex_c * diex_a

generate area_frontal_ln   = ln(area_frontal)
generate area_superior_ln  = ln(area_superior)
generate volume_externo_ln = ln(volume_externo)

* Espa�o interno: dist�ncia entre os eixos X largura
generate espaco_interno    = diex_l * diex_e
generate espaco_interno_ln = ln(espaco_interno)

* Dimen��es
generate dist_eixos  = diex_e
generate largura     = diex_l
generate comprimento = diex_c

generate dist_eixos_ln  = ln(diex_e)
generate largura_ln     = ln(diex_l)
generate comprimento_ln = ln(diex_c)

local instr `instr' area_frontal area_superior volume_externo ///
	area_frontal_ln area_superior_ln volume_externo_ln ///
	espaco_interno espaco_interno_ln ///
  comprimento dist_eixos largura  ///   
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
egen peso_cat = cut(peso_b), group(5) label

generate carga_paga_max = peso_b - peso_m
egen carga_paga_max_cat = cut(carga_paga_max), group(6) label
generate carga_ln       = ln(carga_paga_max)

generate peso_bruto_ln = ln(peso_b)
rename   peso_b peso_bruto
rename   carg_v carga_carro

local instr `instr' carga_paga_max carga_ln peso_bruto peso_bruto_ln carga_carro
local outras `outras' peso_cat carga_paga_max_cat

*-------------------------------------------------------------------------------
* POT�CIA DO MOTOR
*-------------------------------------------------------------------------------
*qui 
egen potencia_cat = cut(pote_c), group(6) label
generate potencia_ln = ln(pote_c)
rename pote_c potencia
generate potencia_especifica = potencia / peso_bruto

local instr `instr' potencia potencia_ln potencia_especifica
local outras `outras' potencia_cat

*-------------------------------------------------------------------------------
* TORQUE
*-------------------------------------------------------------------------------
rename pote_t torque

* Corrigindo o torque do BMW Series 3, 2 litros
replace torque = 200 if torque == 2000

local instr `instr' torque

*-------------------------------------------------------------------------------
* VELOCIADADE M�XIMA
*-------------------------------------------------------------------------------
generate veloc_max_ln = ln(dese_v)
rename   dese_v veloc_max

local instr `instr' veloc_max
local outros `outros' veloc_max_ln

*-------------------------------------------------------------------------------
* ACELERA��O DE 0 A 100
*-------------------------------------------------------------------------------
rename dese_a aceleracao

local instr `instr' aceleracao

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

*-------------------------------------------------------------------------------
* CILINDRADAS
*-------------------------------------------------------------------------------
rename moto_cc cilindradas

local outras `outras' cilindradas litros

local instr `instr' cilindradas litros

*-------------------------------------------------------------------------------
* CILINDRADAS-ACORDO
*-------------------------------------------------------------------------------
generate cilindrada_acordo = .

replace cilindrada_acordo = 1 if litros == 1 & acordo == 1
replace cilindrada_acordo = 2 if litros == 1 & acordo == 0
replace cilindrada_acordo = 3 if litros >  1 & litros <= 2 & acordo == 1
replace cilindrada_acordo = 4 if litros >  1 & litros <= 2 & acordo == 0
replace cilindrada_acordo = 5 if litros >  2 & acordo == 1
replace cilindrada_acordo = 6 if litros >  2 & acordo == 0

* Removendo fora destes conjuntos
drop if cilindrada_acordo == .

* Criando dummies de cilindrada-acordo
quietly tabulate cilindrada_acordo, generate(cilindrada_dummy)

* local instr `instr' cilindradas //n�o faz sentido vai estar refletido na pot do mot
local outras `outras' cilindrada_acordo cilindrada_dummy*

*-------------------------------------------------------------------------------
* SEGMENTO
*-------------------------------------------------------------------------------
replace jato = trim(jato)

encode jato, generate(jato_e)

generate segmento = 1 if jato=="AS Carro Grande"
replace  segmento = 2 if jato=="AS Carro Luxo"
replace  segmento = 3 if jato=="AS Carro M�dio+" ///
                       | jato=="AS Carro M�dio-"
replace  segmento = 4 if jato=="AS Esporte"
replace  segmento = 5 if jato=="AS MPV" ///
                       | jato=="AS Perua Grande" ///
                       | jato=="AS Perua Luxo" /// 
                       | jato=="AS Perua M�dia"
replace  segmento = 6 if jato=="AS Pequeno"
replace  segmento = 7 if jato=="AS Popular"
replace  segmento = 8 if jato=="AS SUV"

label define TIPO 1 "CARRO GRANDE" ///
                  2 "CARRO DE LUXO" ///
                  3 "CARRO MEDIO" ///
                  4 "ESPORTIVO" ///
                  5 "MPV_PERUA" ///
                  6 "CARRO PEQUENO" ///
                  7 "CARRO POPULAR" ///
                  8 "SUV"

label values segmento TIPO

local outras `outras' segmento jato jato_e

*-------------------------------------------------------------------------------
* CARROCERIA
*-------------------------------------------------------------------------------
drop carroceria
rename carr carroceria

local outras `outras' carroceria

*-------------------------------------------------------------------------------
* MARCA
*-------------------------------------------------------------------------------
encode marca, generate(marca_e)

local outras `outras' marca marca_e

*-------------------------------------------------------------------------------
* MOLDELO
*-------------------------------------------------------------------------------
local outras `outras' modelo

*-------------------------------------------------------------------------------
* VERS�O
*-------------------------------------------------------------------------------
local outras `outras' versao

*-------------------------------------------------------------------------------
* PORTAS
*-------------------------------------------------------------------------------
drop portas

rename port portas

* Verificar se n�o existe van
replace portas = 2 if portas == 3
replace portas = 4 if portas == 5

local outras `outras' portas

*-------------------------------------------------------------------------------
* COMBUST�VEL
*-------------------------------------------------------------------------------
encode combustivel, generate(combustivel_e)

* flex
generate flex = strmatch(versao,"*FLEX*")  

local outras `outras' combustivel combustivel_e flex

*-------------------------------------------------------------------------------
* EMISSAO CO2 (g/km)
*-------------------------------------------------------------------------------
rename emis_c CO2

local instr `instr' CO2

*-------------------------------------------------------------------------------
* CATEGORIA IMPOSTOS
*-------------------------------------------------------------------------------
generate cat_ipi = 1 if litros <= 1.0 & flex == 0
replace  cat_ipi = 2 if litros <= 1.0 & flex == 1
replace  cat_ipi = 3 if litros >  1.0 & litros <= 2.0 & combustivel == "gasolina"
replace  cat_ipi = 4 if litros >  1.0 & litros <= 2.0 & combustivel == "�lcool"
replace  cat_ipi = 5 if litros >  2.0 & combustivel == "gasolina"
replace  cat_ipi = 6 if litros >  2.0 & combustivel == "�lcool"

local outras `outras' cat_ipi
* ______________________________________________________________________________
*
*                        REMOVENDO VARI�VEIS N�O UTILIZADAS 
* ______________________________________________________________________________

keep `instr' `outras'


* ______________________________________________________________________________
*
*                       		 PAINEL LONGO 
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* DADOS DUPLICADOS
*-------------------------------------------------------------------------------
* Excluindo (Verificar com mais cuidado)
* duplicates drop ///
* 	marca modelo versao ano combustivel litros carroceria transmiss portas ///
* 	subregiao cidadeprincipal, ///
* 	force
	
*-------------------------------------------------------------------------------
* TRANSFORMANDO EM PAINEL LONGO 
*-------------------------------------------------------------------------------
* Transformando vendas mensais(sales) na forma longa:
* reshape long sales_, ///
* 	i(marca modelo ano combustivel litros carroceria transmiss portas ///
* 		subregiao cidadeprincipal) ///
* 	j(mes)

* rename sales_ vendas

* ______________________________________________________________________________
*
*                             CORRE��ES NO PRE�O 
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* CORRIGINDO INFLA��O
*-------------------------------------------------------------------------------
* Abrindo tabela de infla��o
* merge m:1 ano mes using "inflacao.dta"
* drop if _merge != 3
* drop _merge

* * Corrigindo
* replace preco = preco * inflacao


* ______________________________________________________________________________
*
*                         UNINDO MES E ANO 
* ______________________________________________________________________________

* generate mes_ano = (ano - 2008) * 12 + mes


* ______________________________________________________________________________
*
*                             EVENTOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* MODIFICA��ES AO LONGO DO TEMPO NO VAT
*-------------------------------------------------------------------------------
* merge m:1 ano mes cilindrada_acordo combustivel using "VAT.dta"
* drop if _merge != 3
* drop _merge

*-------------------------------------------------------------------------------
* ITERA��O ENTRE QUEDA DO IPI E A CILINDRADA-COMBUST�VEL
*-------------------------------------------------------------------------------
* Criando var�vel de tempo para os per�odos de redu��o do ipi e pol�ticas comerciais.
* generate queda_1 = 0
* replace  queda_1 = 1 if mes_ano >= 12 & mes_ano <= 27

* generate queda_2 = 0
* replace  queda_2 = 1 if mes_ano >= 49 & mes_ano <= 65

/* Criando vari�veis de intera��es da capacidade em litros dos carros (importados
e nacionais) com os per�odos de queda do IPI. N�o esquecer que s�o seis categorias 
de cilindradas-combust�vel comforme acima */

* forvalues i = 1 / 6 {
*     generate cc`i'__queda_1 = cilindrada_dummy`i' * queda_1
*     generate cc`i'__queda_2 = cilindrada_dummy`i' * queda_2
* }

* ______________________________________________________________________________
*
*               SALVANDO PARA GERAR AS ESTATISTICAS DESCRITIVAS 
* ______________________________________________________________________________

save base_descritiva.dta, replace

* ______________________________________________________________________________
*
*               REMOVENDO 
* ______________________________________________________________________________

drop if marca=="FERRARI"
drop if marca=="ASTON MARTIN"
drop if marca=="BENTLEY"
drop if marca=="JAGUAR"
drop if marca=="LAMBORGHINI"
drop if marca=="LEXUS"
drop if marca=="MASERATI"
drop if marca=="ROLLS-ROYCE"
drop if jato_e == 1 ///
      | jato_e == 2 ///
      | jato_e == 5 ///
      | jato_e == 8 ///
      | jato_e == 9 ///
      | jato_e == 10
drop if ano == 2013
drop if combustivel == "diesel"


* ______________________________________________________________________________
*
*                             MERCADO POTENCIAL 
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* UNINDO A BASE DE MERCADO POTENCIAL
*-------------------------------------------------------------------------------
merge m:1 ano regiao subregiao cidade using "Pot_mkt.dta"
drop if _merge != 3
drop _merge

********************************************************************************
* CORRIGINDO TAMANHO DO MERCADO POTENCIAL
********************************************************************************
* O consumidor troca de carro a cada 5 anos
generate mercado_potencial = mkt_pop_ * 0.2


*-------------------------------------------------------------------------------
* CONSTRUINDO MERCADO POTECIAL E CALCULANDO A PARTICIPA��O NOS MERCADOS
*-------------------------------------------------------------------------------
* Construindo vari�vel de share do bem j e do bem externo
bysort ano subregiao cidadeprincipal: egen vendas_total = sum(vendas_ano)
generate share_geral = vendas_ano / mercado_potencial

bysort ano subregiao cidadeprincipal: egen share_insidegood = total(share_geral)
generate share_outsidegood = 1 - share_insidegood
generate share_geral_ln = ln(share_geral)
generate share_outsidegood_ln = ln(share_outsidegood)
generate dif_share = ln(share_geral) - ln(share_outsidegood)

********************************************************************************
* GREGOS
********************************************************************************
* /*
* s_jt:   share de cada ve�culo no ano
* outshr: share que n�o comprou
* lnsj0:  ln do share normalizado

* sg1: Share do ninho ano combustivel
* sg2: Share do subninho ano combustivel segmento
* */

* generate s_jt = vendas_ano / mercado_potencial
* bysort ano subregiao cidadeprincipal: egen outshr = sum(s_jt)
* replace outshr = 1 - outshr
* generate lnsj0 = ln(s_jt / outshr)

* * Share dos Ninhos
* egen sg1 = sum(s_jt), by(segmento ano subregiao cidadeprincipal)
* egen sg2 = sum(s_jt), by(segmento combustivel ano subregiao cidadeprincipal)

* * Algumas rela��es
* generate sg2g1   = sg2 / sg1
* generate lnsg2g1 = ln(sg2g1)
* generate sjg2    = s_jt / sg2
* generate lnsjg2  = ln(s_jt/sg2)
* generate sjg1    = s_jt / sg1 //Mudei o nome de sjgg para sjg1


* drop if mercado_potencial <= 50000

* ______________________________________________________________________________
*
*                                   CRIANDO GRUPOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* CIDADE E ANO
*-------------------------------------------------------------------------------
egen ano_local = group(ano subregiao cidadeprincipal), label

*-------------------------------------------------------------------------------
* ESTADO E ANO
*-------------------------------------------------------------------------------
* egen ano_local = group(ano subregiao), label


* ______________________________________________________________________________
*
*                         CRIANDO VARI�VEIS INSTRUMENTAIS
* ______________________________________________________________________________

foreach var of local instr{
	sum `var', detail
	keep if inrange(`var', `r(p1)', `r(p99)')
}


*-------------------------------------------------------------------------------
* INSTRUMENTOS BLP (Berry, Levinsohn and Pakes (1995))
*-------------------------------------------------------------------------------
sort ano_local marca_e
foreach variable of local instr {
    bysort ano_local marca_e: egen ownsum = total(`variable')
    * Instrumento BLP (2) para outros produzidos pela mesma firma dentro do mercado.
    qui generate BLP_1_`variable' = ownsum - `variable'
    bysort ano_local: egen totsum = total(`variable')
    * Instrumento BLP (3) para produtos produzidos por outras firmas fora do mercado.
    qui generate BLP_2_`variable' = totsum - ownsum
    drop ownsum
    drop totsum
}

*-------------------------------------------------------------------------------
* INSTRUMENTOS BST (Berry, S. T. (1994))
*-------------------------------------------------------------------------------
sort ano_local marca_e carroceria
foreach variable of local instr {
    bysort ano_local marca_e carroceria: egen ownsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
	mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma
	localizados no mesmo segmento. */
    qui generate BLP_s_1_`variable' = ownsum - `variable'   
    bysort ano_local carroceria: egen totsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
	mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas
	localizados no mesmo segmento. */ 
    qui generate BLP_s_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}


*-------------------------------------------------------------------------------
* INSTRUMENTOS BST (Berry, S. T. (1994))
*-------------------------------------------------------------------------------
sort ano_local marca_e jato_e
foreach variable of local instr {
    bysort ano_local marca_e jato_e: egen ownsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma
  localizados no mesmo segmento. */
    qui generate BLP_j_1_`variable' = ownsum - `variable'   
    bysort ano_local jato_e: egen totsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas
  localizados no mesmo segmento. */ 
    qui generate BLP_j_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}

*-------------------------------------------------------------------------------
* INSTRUMENTOS BST (Berry, S. T. (1994))
*-------------------------------------------------------------------------------
sort ano_local marca_e flex jato_e
foreach variable of local instr {
    bysort ano_local marca_e flex jato_e: egen ownsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma
  localizados no mesmo segmento. */
    qui generate BLP_fj_1_`variable' = ownsum - `variable'   
    bysort ano_local flex jato_e: egen totsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas
  localizados no mesmo segmento. */ 
    qui generate BLP_fj_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}

*-------------------------------------------------------------------------------
* INSTRUMENTOS BST (Berry, S. T. (1994))
*-------------------------------------------------------------------------------
sort ano_local marca_e combustivel_e
foreach variable of local instr {
    bysort ano_local marca_e combustivel_e: egen ownsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma
  localizados no mesmo segmento. */
    qui generate BLP_c_1_`variable' = ownsum - `variable'   
    bysort ano_local combustivel_e: egen totsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas
  localizados no mesmo segmento. */ 
    qui generate BLP_c_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}


*-------------------------------------------------------------------------------
* INSTRUMENTOS BST (Berry, S. T. (1994))
*-------------------------------------------------------------------------------
sort ano_local marca_e jato_e combustivel_e
foreach variable of local instr {
    bysort ano_local marca_e jato_e combustivel_e: egen ownsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma
  localizados no mesmo segmento. */
    qui generate BLP_jc_1_`variable' = ownsum - `variable'   
    bysort ano_local jato_e combustivel_e: egen totsum = total(`variable') 
    //Troquei carroceria por segmento
    /* Instrumento BST (5.2) para produtos produzidos por outras firmas fora do
  mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas
  localizados no mesmo segmento. */ 
    qui generate BLP_jc_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}


*-------------------------------------------------------------------------------
* PROXY DA SUBSTITUTIBILIDADE
*-------------------------------------------------------------------------------
/* N�mero de modelos de uma mesma montadora vendidos em um mesmo grupo como 
proxy da substitubilidade dos produtos. */
bysort ano_local marca_e segmento: egen BST_1 = count(preco) 
//Troquei carroceria por segmento

/* N�mero de modelos em um dado grupo do mercado como proxy da substitubilidade
 dos produtos. */
bysort ano_local marca_e: egen BST_1_1 = count(preco)

* N�mero de empresas pertencentes num mesmo grupo como proxy do grau de concorr�ncia.
*-------------------------------------------------------------------------------


* ______________________________________________________________________________
*
*                                   SALVANDO
* ______________________________________________________________________________

save base_limpa_instr.dta, replace
* outsheet using base_limpa_instr.csv, comma replace



keep preco_ln BLP_j_*
save base_py.dta, replace

