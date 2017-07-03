/* CORRIGE.DO:
Retira a variável _merge do base para que seja possível a união com outra base.
*/

clear
cd "/mnt/84DC97E6DC97D0B2/carros"
use "Pot_mkt_3.dta"
drop _merge
save "Pot_mkt.dta"
