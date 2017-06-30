/*
PREPARA.DO:

Trata os dados para que a estimação;
Cria variáveis instrumentais
*/


cd "/mnt/84DC97E6DC97D0B2/carros"
use "BIG_File_with_fuel.dta", clear


* ______________________________________________________________________________
*
* 							FORMATANDO OS DADOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* TEMPO
*-------------------------------------------------------------------------------
* Excluido os anos irrelevantes
keep if inrange(ano, 2008, 2013)

*-------------------------------------------------------------------------------
* PREÇO
*-------------------------------------------------------------------------------
* Removendo carros sem preço
drop if prec == .
* Preços estão multiplicados por 100, dividindo-os:
replace prec = prec / 100

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

*-------------------------------------------------------------------------------
* TRAÇÃO
*-------------------------------------------------------------------------------
generate tracao = 0
replace  tracao = 1 if trca == "4x4"

*-------------------------------------------------------------------------------
* PILOTO AUTOMÁTICO
*-------------------------------------------------------------------------------
generate pilotoauto = 0
replace  pilotoauto = 1 if pilo == "std"

*-------------------------------------------------------------------------------
* AR CONDICIONADO
*-------------------------------------------------------------------------------
generate arcondicianado = 0
replace arcondicianado = 1 if arco == "std"

*-------------------------------------------------------------------------------
* MATERIAL DA RODA
*-------------------------------------------------------------------------------
generate rodaleve = 0
replace  rodaleve = 1 if roda_m == "liga leve"

*-------------------------------------------------------------------------------
* SOM
*-------------------------------------------------------------------------------
generate SOM = 0
replace  SOM= 1 if som == "std"

*-------------------------------------------------------------------------------
* DVD
*-------------------------------------------------------------------------------
generate DVD = 0
replace  DVD = 1  if dvd == "std"

*-------------------------------------------------------------------------------
* VIDROS ELÉRICOS
*-------------------------------------------------------------------------------
generate vidros = 0
replace  vidros = 1 if viel == "std"

*-------------------------------------------------------------------------------
* COMPUTADOR DE BORDO
*-------------------------------------------------------------------------------
generate computer = 0
replace  computer = 1 if copt == "std"

*-------------------------------------------------------------------------------
* DIREÇÃO CHIC
*-------------------------------------------------------------------------------
generate direcao = 0
replace  direcao = 1 ///
	if dira_t == "hidráulica" | dira_t=="elérica" | dira_t=="eletro-hidrául."

*-------------------------------------------------------------------------------
* TRAVAMENTO CENTRAL
*-------------------------------------------------------------------------------
generate travcentral = 0
replace  travcentral = 1 if trav == "std"

*-------------------------------------------------------------------------------
* ALARME
*-------------------------------------------------------------------------------
generate alarme = 0
replace  alarme = 1 if alam == "std"

*-------------------------------------------------------------------------------
* AIRBAG
*-------------------------------------------------------------------------------
generate airbag = 0
replace airbag = 1 if aird == "std"
replace airbag = 0 if aird != "std" & aird!=""

*-------------------------------------------------------------------------------
* FREIOS
*-------------------------------------------------------------------------------
generate ABS1 = 0
replace  ABS1 = 1 if abs == "std"

generate EBD1 = 0
replace  EBD1 = 1 if ebd == "std"

*-------------------------------------------------------------------------------
* ACABAMENTO DE LUXO
*-------------------------------------------------------------------------------
generate acabamento_luxo = 0
replace  acabamento_luxo = 1 if aclu == "std"

*-------------------------------------------------------------------------------
* GARANTIA
*-------------------------------------------------------------------------------
rename gato_d garantia

*-------------------------------------------------------------------------------
* POTÊCIA DO MOTOR
*-------------------------------------------------------------------------------
*qui 
generate potencia_categorica = irecode(pote_c, 100, 200, 300, 400, 500, 750)
generate potencia_ln = ln(pote_c)
rename pote_c potencia
rename moto_cc cilindradas

*-------------------------------------------------------------------------------
* ESPAÇO INTERNO
*-------------------------------------------------------------------------------
* diex_X, X corresponde a: a(altura), l(largura), c(comprimento)
generate area_frontal   = diex_l * diex_a
generate area_superior  = diex_l * diex_c
generate volume_externo = diex_l * diex_c * diex_a

generate area_frontal_ln = ln(area_frontal)
generate area_superior_ln = ln(area_superior)
generate volume_externo_ln = ln(volume_externo)

* Espaço interno: distância entre os eixos X largura
generate espaco_interno    = diex_l * diex_e
generate espaco_interno_ln = ln(espaco_interno)

*-------------------------------------------------------------------------------
* CONSUMO
*-------------------------------------------------------------------------------
generate consumo_ln = ln(cons_c)
rename   cons_c consumo

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

*-------------------------------------------------------------------------------
* VELOCIADADE MÁXIMA
*-------------------------------------------------------------------------------
generate veloc_max_ln = ln(dese_v)
rename   dese_v veloc_max

*-------------------------------------------------------------------------------
* ACELERAÇÃO DE 0 A 100
*-------------------------------------------------------------------------------
rename dese_a aceleracao

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
* CORRIGINDO A INFLAÇÃO
* ______________________________________________________________________________


* ______________________________________________________________________________
*
* CRIANDO GRUPOS
* ______________________________________________________________________________

*-------------------------------------------------------------------------------
* CIDADE E ANO
*-------------------------------------------------------------------------------
egen ano_cidade = group(ano cidade),label

* ______________________________________________________________________________
*
* 					CRIANDO AS VARIÁVEIS INSTRUMENTAIS
* ______________________________________________________________________________


sort ano_cidade marca
foreach var of varlist transmissao tracao pilotoauto garantia lngarantia cilindradas lncilindradas som2 computer vidroselé EBD1 Aca_de_luxo direcão ABS1 alarme desempenho lndesempenho eficiencia lneficiencia travcentral airbag arcondicionado potencia_motor potencia lnpotencia_motor lnpeso_bruto peso_bruto peso_carga carga lnespaco espaco lnespaço_interno espaço_interno diex_l diex_a diex_c diex_e carga_carro lncarga_carro peso_m peso_c lnpeso_m lnpeso_c lncarga lndiex_c lndiex_l lndiex_e HP_peso lnHP_peso {
    bysort ano_cidade marca: egen ownsum = total(`var')
    qui gen BLP2_`var' = ownsum -`var'   // Instrumento BLP (2) para outros produzidos pela mesma firma dentro do mercado.
    bysort ano_cidade: egen totsum = total(`var')
    qui gen BLP3_`var' = totsum - ownsum   // Instrumento BLP (3) para produtos produzidos por outras firmas fora do mercado.
    drop ownsum
    drop totsum
}


* ______________________________________________________________________________
*
* NESTED LOGIT
* ______________________________________________________________________________


