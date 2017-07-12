* ______________________________________________________________________________
*
* 							CONTRAÇÃO
* ______________________________________________________________________________

replace mc = __mc
replace markup = __mrkp

* Chuta um pivo e um imposto sobre a emissão
scalar tax = 10      // imposto sobre a emissão
scalar PP  = 160     // Pivot


generate ataxtemp = 0
replace  ataxtemp = tax if CO2 <= PP

generate simco2tax = (CO2 - PP) * ataxtemp

* generate VAT = 0 // MUDAR !!!!
generate effmc = mc * (1 + VAT) + simco2tax



rcl share_geral prec, ///
    market(ano_cidade) ///
    msize(mkt_pop_) ///
    nests(combustivel_e segmento) ///
    noestimation ///
    alpha(`=alpha') ///
    sigmas(`=sigma_1' `=sigma_2') ///
	msimulation(marca_e) ///
    mc(effmc) ///
    xb0(xb0) ///
    ksi(ksi)


generate share_novo = __s_post
generate preco_novo = __p_post

