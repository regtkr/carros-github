/* CORRIGE.DO:
Retira a vari�vel _merge do base para que seja poss�vel a uni�o com outra base.
*/

clear
cd "/mnt/84DC97E6DC97D0B2/carros"
use "Pot_mkt_3.dta"
drop _merge
save "Pot_mkt.dta"
