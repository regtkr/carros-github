# Carregando dados 
bigdata = read.csv("BigData.csv")

# Sorteando uma pequena amostra
smallsample <- bigdata[sample(1:nrow(bigdata), 50000),]

# Salvando a amostra
write.csv(smallsample,"SmallData.csv")
#write.csv(smallsample,"SmallDataSQ.csv", quote = FALSE, col.names = FALSE)
