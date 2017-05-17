# Limpando as variáveis antigas
rm(list = ls())

# Abrindo as bibliotecas necessárias
library(haven) # Biblioteca para o STATA
library(dplyr) 
library(ggplot2)


# Dados

## Lendo a base de carros
amostra  = read.csv("SmallData.csv", fileEncoding="iso-8859-1")
amostra_s = amostra

## Removendo dados estranhos
amostra = subset(amostra, cidadeprincipal != "AAAAA")
outro   = grep("OTHERS", amostra$cidadeprincipal)
amostra = amostra[-outro, ]

## Agregando as cidades
amostra = amostra %>%
  group_by(ano, A) %>%
  summarise(jato[1], combustivel[1], marca[1], dese_a[1], dese_v[1], pote_t[1], moto_cc[1], diex_c[1], pote_c[1], prec[1],
            vendas_ano = sum(vendas_ano))

colnames(amostra) = c("ano", "A", "jato", "combustivel", "marca", "dese_a", "dese_v", "pote_t", "moto_cc", "diex_c", "pote_c", "prec", "vendas_ano")

## Lendo a base de mercado potencial
merc_pot = read_dta("Pot_mkt_3.dta")
## Mantendo apenas o ano a cidade e o mercado potencial
merc_pot = select(merc_pot, ano, cidadeprincipal, mkt_pop_)
merc_pot$ano = as.integer(merc_pot$ano)
merc_pot$cidadeprincipal = as.factor(merc_pot$cidadeprincipal)
merc_pot$mkt_pop_ = as.integer(merc_pot$mkt_pop_ )
## Removendo dados estranhos
merc_pot = subset(merc_pot, cidadeprincipal != "AAAAA")
outro   = grep("OTHERS", merc_pot$cidadeprincipal)
merc_pot = merc_pot[-outro, ]
## Somando para o pais e por ano
merc_ano = merc_pot %>%
  group_by(ano) %>%
  summarise(M = sum(mkt_pop_))

## Unindo as bases
amostra =  amostra %>%
  left_join(merc_ano, by = "ano")

### Calculando a participação
amostra = amostra %>%
  mutate(share = vendas_ano / M) %>%
  group_by(ano) %>%
  mutate(out = 1 - sum(share),
         ln_sj0 = log(share/out))

## Criando classes de veículos

## Marketshare das Classes
### carroceria ou jato
amostra = amostra %>%
  group_by(combustivel, ano) %>%
  mutate(share1 = sum(share)) %>%
  group_by(jato, combustivel, ano) %>%
  mutate(share2   = sum(share)) %>%
  mutate(s2s1     = share2 / share1,
         ln_s2s1  = log(s2s1),
         s_share2 = share / share2,
         ln_s_share2 = log(share / share2),
         s_share1 = share / share1)

## Deflacionando o preco
ipca_br  = read_dta("IPCA_BR.dta")
ipca_est = read_dta("IPCA_EST.dta")

ipca_br$ano = as.integer(ipca_br$ano)
ipca_br$defl_BR = as.double(ipca_br$defl_BR)

amostra = amostra %>% 
  left_join(ipca_br, by = "ano") %>%
  mutate(preco_defl = prec / defl_BR) %>%
  select(-defl_BR)


# Instrumentos

## Contando fabricantes
amostra = amostra %>%
  group_by(ano, combustivel, jato) %>%
  summarise(temp1 = sum(vendas_ano)) %>%
  left_join(amostra, by = c("ano", "combustivel", "jato"))

amostra = amostra %>%
  group_by(ano, combustivel, jato, marca) %>%
  summarise(temp2 = sum(vendas_ano)) %>%
  left_join(amostra, by = c("ano", "combustivel", "jato","marca"))

amostra = amostra %>%
  mutate(firmas.n  = temp1 - temp2,
         firmas.n2 = firmas.n^2) %>%
  select(-temp1, -temp2)

## Desempenho
amostra = amostra %>%
  group_by(ano, combustivel, jato) %>%
  summarise(temp.a1 = min(dese_a, na.rm = T),    # Aceleração de 0 a 100
            temp.s1 = max(dese_v, na.rm = T),    # Velocidade
            temp.t1 = max(pote_t, na.rm = T),    # Torque
            temp.c1 = max(moto_cc, na.rm = T),   # CC
            temp.l1 = max(diex_c, na.rm = T),    # Comprimento
            temp.h1 = max(pote_c, na.rm = T)) %>% # HP
            #temp.co1 = max(emis_c)) %>% # CO2
  left_join(amostra, by = c("ano", "combustivel", "jato"))

amostra = amostra %>%
  group_by(ano, combustivel, jato, marca) %>%
  summarise(temp.a2 = min(dese_a, na.rm = T),    # Aceleração de 0 a 100
            temp.s2 = max(dese_v, na.rm = T),    # Velocidade
            temp.t2 = max(pote_t, na.rm = T),    # Torque
            temp.c2 = max(moto_cc, na.rm = T),   # CC
            temp.l2 = max(diex_c, na.rm = T),    # Comprimento
            temp.h2 = max(pote_c, na.rm = T)) %>% # HP
  left_join(amostra, by = c("ano", "combustivel", "jato","marca"))

amostra = amostra %>%
  mutate(firmas.acc     = temp.a1 - temp.a2,
         firmas.speed   = temp.s1 - temp.s2,
         firmas.torque  = temp.t1 - temp.t2,
         firmas.cc      = temp.c1 - temp.c2,
         firmas.compr   = temp.l1 - temp.l2,
         firmas.cv      = temp.h1 - temp.h2,
         firmas.acc2    = firmas.acc^2,
         firmas.speed2  = firmas.speed^2,
         firmas.torque2 = firmas.torque^2,
         firmas.cc2     = firmas.cc^2,
         firmas.compr2  = firmas.compr^2,
         firmas.cv2     = firmas.cv^2) %>%
  select(-temp.a1, -temp.s1, -temp.t1, -temp.c1, -temp.l1, -temp.h1,
         -temp.a2, -temp.s2, -temp.t2, -temp.c2, -temp.l2, -temp.h2)

## Retirando Infinito
amostra = subset(amostra, ln_sj0 != -Inf)

## Ano de 2012
# amostra_s2 = amostra
# amostra = amostra %>% filter(ano == 2012)

# Estimação
library(AER)

## OLS
reg0 = lm(ln_sj0 ~ preco_defl, data = amostra)
summary(reg0)

reg1 = lm(ln_sj0 ~ preco_defl + ln_s_share2 + ln_s2s1 
           + dese_a 
           + dese_v
           + pote_t 
           + moto_cc 
           + diex_c + pote_c
          , data = amostra)
summary(reg1)

painel1 = plm(ln_sj0 ~ preco_defl + ln_s_share2 + ln_s2s1 
          + dese_a 
          + dese_v
          + pote_t 
          + moto_cc 
          + diex_c + pote_c, 
          data = amostra, index = c("A", "ano"), model = "random")
summary(painel1)

## 2SLS
ivreg1 = ivreg(ln_sj0 ~ preco_defl
               + ln_s_share2 + ln_s2s1
               + dese_a + dese_v + pote_t + moto_cc + diex_c + pote_c
               | ln_s_share2 + ln_s2s1 
               + dese_a + dese_v 
               + pote_t + moto_cc + diex_c + pote_c
               # Instrumentos
               + firmas.n + firmas.acc + firmas.speed + firmas.torque + firmas.cc + firmas.compr + firmas.cv,
               data = amostra)
summary(ivreg1, diagnostics = T)

piv1 = plm(ln_sj0 ~ log(preco_defl)
               + ln_s_share2 + ln_s2s1
               + dese_a + dese_v + pote_t + moto_cc + diex_c + pote_c
               | ln_s_share2 + ln_s2s1 +
             dese_a + dese_v + pote_t + moto_cc + diex_c + pote_c
               # Instrumentos
               + firmas.n + firmas.acc + firmas.speed + firmas.torque + firmas.cc + firmas.compr + firmas.cv,
               data = amostra, index = c("A", "ano"), model = "random")
summary(piv1, diagnostics = T)

t.test(amostra$ln_s_share2, amostra$ln_s2s1)

iv1 = lm(preco_defl ~ firmas.n + firmas.acc + firmas.speed+ dese_v
         #+ firmas.torque 
         + firmas.cc 
         #+ firmas.compr + firmas.cv
         ,
         data = amostra)
summary(iv1, diagnostics = T)
preco_hat = predict(iv1)

# Markup
sigma1 =  ivreg1$coefficients[["ln_s_share2"]]
sigma2 =  ivreg1$coefficients[["ln_s2s1"]]
alpha  = -ivreg1$coefficients[["preco_defl"]]

amostra = amostra %>%
  mutate(ownelas = -alpha * (1 / (1 - sigma1) - ( 1 / (1 - sigma1) - 1 / (1 - sigma2)) * s_share2 - (sigma2 / (1 - sigma2)) * s_share1 - share) * preco_defl,
         crosssubgroup =  alpha * ((1 / (1 - sigma1) - 1 / (1 - sigma2 )) * s_share2 + (sigma2 / (1 - sigma2)) * s_share1 + share) * preco_defl,
         crossgroup =  alpha * ((sigma2 / (1 - sigma2)) * s_share1 + share) * preco_defl,
         crossoutgroup = alpha *  share * preco_defl)

amostra %>%
  group_by(combustivel, jato) %>% 
  summarise(median(ownelas),
            median(crosssubgroup),
            median(crossgroup),
            median(crossoutgroup))

amostra = amostra %>%
  group_by(marca, combustivel, jato, marca) %>%
  mutate(sm = sum(share)) %>%
  left_join(amostra, by = c("marca", "combustivel", "jato", "marca")) %>%
  mutate(sjggm = sm / share1,
         sjg2m = sm / share2)

amostra = amostra %>% 
  mutate(markups = 1 / (alpha * (1 / (1 - sigma1) - (1 / (1 - sigma1) - 1 / (1 - sigma2)) * sjg2m - (sigma2/(1 - sigma2)) * sjggm - sm)))

amostra %>%
  group_by(combustivel, jato) %>% 
  summarise(median(markups))

# amostra = amostra %>% 
#   mutate(mc = (price - markups) / (1 + vatrate))

# xi: reg mc eng_cc  co2_level  hp lengXwid   dum_manual dum_climate    yr* cn*
#   encode make, gen(makenum)

