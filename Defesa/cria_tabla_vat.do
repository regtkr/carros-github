/*
CRIA_TABELA_VAT:
Cria tabela de imposto sobre o valor adicionado com base no anuário da ANFAVEA.
O valor aqui apresentado é a agregação dos impostos que incidem sobre veículos
*/


clear

* ______________________________________________________________________________
*
* 							CRIANDO O NÚMERO DE OBSEVAÇÕES 
* ______________________________________________________________________________

/*
Temos as seguintes variáveis:
cilindrada: 	Varia de 1 a 6
combustível:	Podendo ser gasolina ou álcool
mes_ano: 		De janeiro de 2008 a maio de 2013, totalizando 65 meses
VAT: 			Imposto sobre valor agregado
*/

* cilindradas X combustível X mes_ano
scalar N = 6 * 2 * 65

set obs `=N'

* ______________________________________________________________________________
*
* 									VARIÁVEIS 
* ______________________________________________________________________________

********************************************************************************
* MES E ANO
********************************************************************************
* criando a variável mes_ano no banco
egen mes_ano = seq(), f(1) t(65)
sort mes_ano

********************************************************************************
* CILINDRADA
********************************************************************************
* Criando variável cilindrada
egen cilindrada = seq(), f(1) t(6)
sort mes_ano cilindrada

********************************************************************************
* COMBUSTÍVEL
********************************************************************************
* Criando variável combustível
generate combustivel = "álcool"   if mod(_n, 2) == 1
replace  combustivel = "gasolina" if mod(_n, 2) == 0

* generate combustivel = "álcool" if _n <= N / 2
* replace  combustivel = "gasolina" if combustivel == ""

* generate comb = seq(), f(1) t(2)
* sort comb
* generate combustivel = "álcool" if comb == 1
* replace  combustivel = "gasolina" if comb == 2

********************************************************************************
* ORGANIZANDO
********************************************************************************
sort cilindrada combustivel mes_ano

********************************************************************************
* DIVIDINDO MES E ANO
********************************************************************************
generate ano = int((mes_ano - 1) / 12) + 2008
generate mes = mod(mes_ano - 1, 12) + 1


* ______________________________________________________________________________
*
* 									A TABELA 
* ______________________________________________________________________________

generate VAT = .

replace VAT = 0.271 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.222 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.244 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 27)
replace VAT = 0.271 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >= 28 & mes_ano <= 52)
replace VAT = 0.222 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.236 if cilindrada == 1 & combustivel== "álcool"   & (mes_ano >= 61 & mes_ano <= 65)

replace VAT = 0.271 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.222 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.257 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >= 22 & mes_ano <= 24) 
replace VAT = 0.271 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 52)
replace VAT = 0.222 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.236 if cilindrada == 1 & combustivel== "gasolina" & (mes_ano >= 61 & mes_ano <= 65)

replace VAT = 0.271 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.222 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.244 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 27)
replace VAT = 0.271 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 28 & mes_ano <= 48) 
replace VAT = 0.455 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 49 & mes_ano <= 52)
replace VAT = 0.406 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.420 if cilindrada == 2 & combustivel== "álcool"   & (mes_ano >= 61 & mes_ano <= 65)

replace VAT = 0.271 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.222 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.257 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 22 & mes_ano <= 24) 
replace VAT = 0.271 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 48) 
replace VAT = 0.455 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 49 & mes_ano <= 52)
replace VAT = 0.406 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.420 if cilindrada == 2 & combustivel== "gasolina" & (mes_ano >= 61 & mes_ano <= 65)
                                                                    
replace VAT = 0.292 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.258 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.278 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 27)
replace VAT = 0.292 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >= 28 & mes_ano <= 52)
replace VAT = 0.258 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.268 if cilindrada == 3 & combustivel== "álcool"   & (mes_ano >= 61 & mes_ano <= 65)
                                                                  
replace VAT = 0.304 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.264 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.292 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >= 22 & mes_ano <= 24) 
replace VAT = 0.304 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 52)
replace VAT = 0.264 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.274 if cilindrada == 3 & combustivel== "gasolina" & (mes_ano >= 61 & mes_ano <= 65)
                                                                    
replace VAT = 0.292 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.258 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.278 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 27)
replace VAT = 0.292 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 28 & mes_ano <= 48)  
replace VAT = 0.476 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 49 & mes_ano <= 52)
replace VAT = 0.446 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 52 & mes_ano <= 60) 
replace VAT = 0.456 if cilindrada == 4 & combustivel== "álcool"   & (mes_ano >= 61 & mes_ano <= 65) 
                                                                              
replace VAT = 0.304 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.264 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.292 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 22 & mes_ano <= 24)
replace VAT = 0.304 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 48)  
replace VAT = 0.488 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 49 & mes_ano <= 52)
replace VAT = 0.448 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 53 & mes_ano <= 60)
replace VAT = 0.458 if cilindrada == 4 & combustivel== "gasolina" & (mes_ano >= 61 & mes_ano <= 65)

replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 20) 
replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 26)
replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >= 27 & mes_ano <= 52) 
replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >= 53 & mes_ano <= 60)
replace VAT = 0.331 if cilindrada == 5 & combustivel== "álcool"   & (mes_ano >= 61 & mes_ano <= 65)

replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 20)
replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >= 21 & mes_ano <= 24)
replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 52)
replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >= 53 & mes_ano <= 60) 
replace VAT = 0.364 if cilindrada == 5 & combustivel== "gasolina" & (mes_ano >= 61 & mes_ano <= 65) 

replace VAT = 0.331 if cilindrada == 6 & combustivel== "álcool"   & (mes_ano >=  1 & mes_ano <= 11) 
replace VAT = 0.331 if cilindrada == 6 & combustivel== "álcool"   & (mes_ano >= 12 & mes_ano <= 21)
replace VAT = 0.331 if cilindrada == 6 & combustivel== "álcool"   & (mes_ano >= 22 & mes_ano <= 27)
replace VAT = 0.331 if cilindrada == 6 & combustivel== "álcool"   & (mes_ano >= 28 & mes_ano <= 48) 
replace VAT = 0.516 if cilindrada == 6 & combustivel== "álcool"   & (mes_ano >= 49 & mes_ano <= 65)

replace VAT = 0.331 if cilindrada == 6 & combustivel== "gasolina" & (mes_ano >=  1 & mes_ano <= 11)
replace VAT = 0.331 if cilindrada == 6 & combustivel== "gasolina" & (mes_ano >= 12 & mes_ano <= 21) 
replace VAT = 0.331 if cilindrada == 6 & combustivel== "gasolina" & (mes_ano >= 22 & mes_ano <= 24) 
replace VAT = 0.331 if cilindrada == 6 & combustivel== "gasolina" & (mes_ano >= 25 & mes_ano <= 48)
replace VAT = 0.545 if cilindrada == 6 & combustivel== "gasolina" & (mes_ano >= 49 & mes_ano <= 65)


* ______________________________________________________________________________
*
* 									SALVANDO 
* ______________________________________________________________________________

rename cilindrada cilindrada_acordo

cd "/mnt/84DC97E6DC97D0B2/carros"
save "VAT.dta"
