/*
PREPARA.DO:

Trata os dados para que a estima��o;
Cria vari�veis instrumentais
*/

* ______________________________________________________________________________
*
*                             ABRINDO A BASE DE DADOS
* ______________________________________________________________________________

cd "/mnt/84DC97E6DC97D0B2/carros"
use "BIG_File_with_fuel.dta", clear


* ______________________________________________________________________________
*
* 							    FORMATANDO OS DADOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* TEMPO
*-------------------------------------------------------------------------------
* Excluido os anos irrelevantes
keep if inrange(ano, 2008, 2013)

*-------------------------------------------------------------------------------
* PRE�O
*-------------------------------------------------------------------------------
* Removendo carros sem pre�o
drop if prec == .
* Pre�os est�o multiplicados por 100, dividindo-os:
replace prec = prec / 100

*-------------------------------------------------------------------------------
* DADOS DUPLICADOS
*-------------------------------------------------------------------------------
* Excluindo
* duplicates drop marca modelo ano litros transmiss carroceria, force

*-------------------------------------------------------------------------------
* LISTA DE VARI�VEIS A INSTRUMENTALIZAR
*-------------------------------------------------------------------------------
* Criando uma lista de vari�veis para instrumentos a partir desta usando Berry
local instr 

*-------------------------------------------------------------------------------
* TRANSMISS�O
*-------------------------------------------------------------------------------
generate transmissao = .
replace  transmissao = 1 if transmiss == "autom�tica"
replace  transmissao = 0 if transmiss == "manual"

local instr `instr' transmissao 

*-------------------------------------------------------------------------------
* TRA��O
*-------------------------------------------------------------------------------
generate tracao = 0
replace  tracao = 1 if trca == "4x4"

local instr `instr' tracao

*-------------------------------------------------------------------------------
* PILOTO AUTOM�TICO
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
replace  direcao = 1 ///
	if dira_t == "hidr�ulica" | dira_t=="el�rica" | dira_t=="eletro-hidr�ul."

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
* POT�CIA DO MOTOR
*-------------------------------------------------------------------------------
*qui 
generate potencia_categorica = irecode(pote_c, 100, 200, 300, 400, 500, 750)
generate potencia_ln = ln(pote_c)
rename pote_c potencia
rename moto_cc cilindradas

local instr `instr' potencia potencia_ln

*-------------------------------------------------------------------------------
* ESPA�O INTERNO
*-------------------------------------------------------------------------------
* diex_X, X corresponde a: a(altura), l(largura), c(comprimento)
generate area_frontal   = diex_l * diex_a
generate area_superior  = diex_l * diex_c
generate volume_externo = diex_l * diex_c * diex_a

generate area_frontal_ln = ln(area_frontal)
generate area_superior_ln = ln(area_superior)
generate volume_externo_ln = ln(volume_externo)

* Espa�o interno: dist�ncia entre os eixos X largura
generate espaco_interno    = diex_l * diex_e
generate espaco_interno_ln = ln(espaco_interno)

local instr `instr' area_frontal area_superior volume_externo ///
	area_frontal_ln area_superior_ln volume_externo_ln ///
	espaco_interno espaco_interno_ln

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
* VELOCIADADE M�XIMA
*-------------------------------------------------------------------------------
generate veloc_max_ln = ln(dese_v)
rename   dese_v veloc_max

local instr `instr' veloc_max

*-------------------------------------------------------------------------------
* ACELERA��O DE 0 A 100
*-------------------------------------------------------------------------------
rename dese_a aceleracao

local instr `instr' aceleracao

*-------------------------------------------------------------------------------
* CILINDRADAS
*-------------------------------------------------------------------------------
* acordo?
/*
generate capacidade_litros = 1 if litros==1 & acordo ==1
replace capacidade_litros = 2 if litros==1 & acordo==0
replace capacidade_litros = 3 if litros>=1.1 & litros<=2 & acordo ==1
replace capacidade_litros = 4 if litros>=1.1 & litros<=2 & acordo == 0
replace capacidade_litros = 5 if litros>2 & acordo ==1
replace capacidade_litros = 6 if litros>2 & acordo ==0

* Removendo fora destes conjuntos

drop if capacidade_litros==.
*/

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


* ______________________________________________________________________________
*
*                        REMOVENDO VARI�VEIS N�O UTILIZADAS 
* ______________________________________________________________________________

local outras ///
    cidadeprincipal prec ano marca carroceria brasil mercosul acordo importado

keep `instr' `outras'


* ______________________________________________________________________________
*
* BASE DE VOLUME ORIGINAL
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* UNINDO A BASE DE MERCADO POTENCIAL
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* CONSTRUINDO MERCADO POTECIAL
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* CORRIGINDO A INFLA��O
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* CRIANDO GRUPOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* CIDADE E ANO
*-------------------------------------------------------------------------------
egen ano_cidade = group(ano cidadeprincipal), label


* ______________________________________________________________________________
*
*                         CRIANDO VARI�VEIS INSTRUMENTAIS
* ______________________________________________________________________________


sort ano_cidade marca
foreach variable of local instr {
    bysort ano_cidade marca: egen ownsum = total(`variable')
    * Instrumento BLP (2) para outros produzidos pela mesma firma dentro do mercado.
    qui gen BLP2_`variable' = ownsum - `variable'
    bysort ano_cidade: egen totsum = total(`variable')
    * Instrumento BLP (3) para produtos produzidos por outras firmas fora do mercado.
    qui gen BLP3_`variable' = totsum - ownsum
    drop ownsum
    drop totsum
}


sort ano_cidade marca carroceria
foreach variable of local instr {
    bysort ano_cidade marca carroceria: egen ownsum = total(`variable')
    * Instrumento BST (5.1) para outros produzidos pela mesma firma dentro do mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos pela mesma firma localizados no mesmo segmento.
    qui gen BLP5_1_`variable' = ownsum - `variable'   
    bysort ano_cidade carroceria: egen totsum = total(`variable')
    * Instrumento BST (5.2) para produtos produzidos por outras firmas fora do mercado no mesmo segmento.
    * Soma das caracter�sticas dos outros produtos produzidos por outras firmas localizados no mesmo segmento.
    qui gen BLP5_2_`variable' = totsum - ownsum  
    drop ownsum
    drop totsum
}


* N�mero de modelos de uma mesma montadora vendidos em um mesmo grupo como proxy da substitubilidade dos produtos.
*-------------------------------------------------------------------------------------------------------------------
bysort ano_cidade marca carroceria: egen BST_1 = count(prec)

* N�mero de modelos em um dado grupo do mercado como proxy da substitubilidade dos produtos.
*-------------------------------------------------------------------------------------------------------------------
bysort ano_cidade marca: egen BST_1_1 = count(prec)

* N�mero de empresas pertencentes em um mesmo grupo como proxy do grau de concorr�ncia.
*----------------------------------------------------------------------------------------



* ______________________________________________________________________________
*
*                                   SALVANDO
* ______________________________________________________________________________

save base_limpa_instr.dta

