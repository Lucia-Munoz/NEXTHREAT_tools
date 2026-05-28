#Here we define how the statistics were calculated.
#This scripts serves as a 'protocol' to understand how the statistical analysis of the samples was performed, there is no specific data, it is just an example
#First, for comparisons between two groups, first we load all the packages we need
library(tidyverse)
library(rstatix)

#Now we define the values in the groups
grupo1 <- c()
grupo2 <- c()

#Perform the t-test, in this case, paired because we are working with the same samples in different 'conditions'
t.test(grupo1,grupo2, paired = TRUE)

#Now for more than two group comparison is more complex, we start just like before defining the values in them
grupo_1 <- c() 
grupo_2 <- c() 
grupo_3 <- c()

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

#Now we have to change the data format from wide to long, the test requires it this way
datos_largo <- datos_imputados %>%
  mutate(sujeto = row_number()) %>%
  pivot_longer(
    cols = c(grupo_1, grupo_2, grupo_3),
    names_to = "metodo",
    values_to = "valor")

#Now we perform normality analysis, using Shapiro-Wilkin
datos_largo %>%
  group_by(metodo) %>%
  summarise(shapiro_p = shapiro.test(valor)$p.value)

#In case that pvalue < 0.05 the data does not follow a normal distribution, in this case we use the Friedman Test
friedman <- friedman_test(datos_largo, valor ~ metodo | sujeto)
friedman

# If the resulting pvalue < 0.05 then we perform post hoc analysis to see where are the significant differences, we use bonferroni to adjust, as
#we are doing many comparations, the probability of obtaining a significant result by chance is higher

post_hoc <- datos_largo %>%
  dunn_test(valor ~ metodo, p.adjust.method = "bonferroni")

post_hoc

#If in the pvalue > 0.05 in the normality test, then the data follows a normal distribution, so we can perform an ANOVA
#We perform ANOVA od repeated measures which would be equivalent of the previous paired t-test
anova <- anova_test(
  data = datos_largo,
  dv = valor,
  wid = sujeto,
  within = metodo)

anova

#If pvalue < 0.05 then we perform pairwise t-test as post hoc
posthoc <- datos_largo %>%
  pairwise_t_test(
    valor ~ metodo,
    paired = TRUE,
    p.adjust.method = "bonferroni")

posthoc
