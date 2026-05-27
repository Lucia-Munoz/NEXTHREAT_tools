#Here we define how the statistics were calculated
#First, for comparisons between two groups, first we load all the packages we need
library(tidyverse)
library(rstatix)

#Now we define the values in the groups
grupo1 <- c(0.67,0,0.5,1,0.125,0,0.5,1,0)
grupo2 <- c(0.86,1,1,1,1,0,0.5)

#Perform the t-test
t.test(grupo1,grupo2)

#Now for more than two group comparison is more complex, we start just like before defining the values in them
grupo_1 <- c(203,4,2,4,150,1,90,70,5,100) 
grupo_2 <- c(3,0,0,0,10,0,6,5,0,8) 
grupo_3 <- c(250,4,7,6,100,3,100,150,10,320)

#Now, as ANOVA does not allow different sized groups we first calculate which group has the maximun lenght
max_len <- max( length(grupo_1), 
               length(grupo_2), length(grupo_3))

#Then we turn our vectors into dataframes, they are all filled until reaching max_len using NA
datos <- data.frame(
  bitscore_50 = c(grupo_1, rep(NA, max_len - length(grupo_1))),
  evalue_5 = c(grupo_2, rep(NA, max_len - length(grupo_2))),
  bitscore_80 = c(grupo_3, rep(NA, max_len - length(grupo_3))))

#Next step is to impute the NAs, as we don't have many data, just eliminating them would meaing losing too much information, so instead I am imputating them, using the median, which is the most probable value
datos_imputados <- datos %>%
  mutate(across(everything(), 
                ~ifelse(is.na(.), median(., na.rm = TRUE), .)))
