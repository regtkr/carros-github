rm(list = ls())

library(haven) # Biblioteca para o STATA
library(dplyr) 
library(ggplot2)
library(zoo)
library(reshape2)
#library(xts)

Sys.setlocale(locale = "en_US.UTF-8")

# Lendo os arquivos de Interesse
amostra  = read.csv("SmallData.csv", fileEncoding="iso-8859-1", nrows=50000)

amostra = select(amostra, versao, litros, combustivel, ano,
                  jan = sales_1,
                  feb = sales_2,
                  mar = sales_3,
                  apr = sales_4,
                  may = sales_5,
                  jun = sales_6,
                  jul = sales_7,
                  aug = sales_8,
                  sep = sales_9,
                  oct = sales_10,
                  nov = sales_11,
                  dec = sales_12)

# Extraindo Diesel
amostra = subset(amostra, combustivel != "diesel")

# Criando indicador de FLEX
amostra$flex = 0
amostra[grep("FLEX", amostra$versao), ]$flex = 1

amostra_longa = melt(amostra, id.vars = c("versao", "litros", "combustivel", "ano", "flex"), variable.name = "mes")

amostra_longa = mutate(amostra_longa, data = as.yearmon(paste(ano, mes, sep = "-"), format = "%Y-%b"))

amostra_longa = filter(amostra_longa, data < as.yearmon("Jun 2013"))

amostra_longa = mutate(amostra_longa, cat = 0 
                       + 1*(litros <= 1.0 & flex == 0)
                       + 2*(litros <= 1.0 & flex == 1)
                       + 3*(litros >  1.0 & litros <= 2.0 & combustivel == "gasolina")
                       + 4*(litros >  1.0 & litros <= 2.0 & combustivel == "álcool")
                       + 5*(litros >  2.0 & combustivel == "gasolina")
                       + 6*(litros >  2.0 & combustivel == "álcool"))

amostra_longa = mutate(amostra_longa, cat2 = 0
                       + 1*(litros <= 1.0)
                       + 2*(litros >  1.0 & litros <= 2.0)
                       + 3*(litros >  2.0))

soma = summarise(group_by(amostra_longa, cat), value = sum(value))
soma = soma$value

am_long_int = summarise(group_by(amostra_longa, data, cat), value = sum(value))
am_long_int = mutate(am_long_int, value = value*((cat == 1) / soma[1]
                     + (cat == 2) / soma[2]
                     + (cat == 3) / soma[3]
                     + (cat == 4) / soma[4]
                     + (cat == 5) / soma[5]
                     + (cat == 6) / soma[6]))

am = filter(am_long_int, cat == 3 | cat == 5)
lp1 = ggplot(am, aes(data,value, color = factor(cat, labels = c("1.0 a 2.0", "> 2.0"))))

am = filter(am_long_int, cat == 4 | cat == 6)
lp2 = ggplot(am, aes(data,value, color = factor(cat, labels = c("1.0 a 2.0", "> 2.0"))))

soma = summarise(group_by(amostra_longa, cat2), value = sum(value))
soma = soma$value

am_long_int = summarise(group_by(amostra_longa, data, cat2), value = sum(value))
am_long_int = mutate(am_long_int, value = value * ((cat2 == 1) / soma[1]
                                                 + (cat2 == 2) / soma[2]
                                                 + (cat2 == 3) / soma[3]))

lp3 = ggplot(am_long_int, aes(data,value, color = factor(cat2, labels = c("< 1.0", "1.0 a 2.0", "> 2.0"))))

datas = read.csv("datas.csv")
datas = as.Date(datas$Datas)
datas = as.yearmon(datas)

pdf("gasolina.pdf",width = 8, height=5)
lp1 +
  geom_line() +
  geom_point() +
  geom_vline(xintercept=as.numeric(datas), linetype=3) +
  labs(x = "Mês", y = "Vendas / Total de Vendas", color = "Volume")
dev.off()

pdf("alcool.pdf",width = 8, height=5)
lp2 +
  geom_line() +
  geom_point() +
  geom_vline(xintercept=as.numeric(datas), linetype=3)+
  labs(x = "Mês", y = "Vendas / Total de Vendas", color = "Volume")
dev.off()

pdf("tres.pdf",width = 8, height=5)
lp3 +
  geom_line() +
  geom_point() +
  geom_vline(xintercept=as.numeric(datas), linetype=3) +
  labs(x = "Mês", y = "Vendas / Total de Vendas", color = "Volume")
dev.off()

# am_long_int = select(amostra_longa, data, cat, value)
# cat1 = dcast(am_long_int, data ~ cat, fun.aggregate = sum)