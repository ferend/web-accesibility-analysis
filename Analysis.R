library(dplyr)
library(MASS)
library(ISLR)
library(forecast)
library(corrplot)
library(car)
library(plotrix)
library(ggplot2)


setwd(getwd())

data<-read.csv2("web-accessibility.csv", header = TRUE, stringsAsFactors = F, sep=",",dec=".")
    
data <- na.omit(data)

data <- subset (data, select = -has_issue_title) # Only 3 website has this issue

################################################# DATA MANIPULATION PART ##########################################################
data <- data %>%                               
  mutate(has_issue_headings = replace(has_issue_headings, has_issue_headings == "True", 1))

data <- data %>%                               
  mutate(has_issue_headings = replace(has_issue_headings, has_issue_headings == "False", 0))

data <- data %>%                               
  mutate(has_issue_image = replace(has_issue_image, has_issue_image == "True", 1), )

data <- data %>%                               
  mutate(has_issue_image = replace(has_issue_image, has_issue_image == "False", 0))

data <- data %>%                               
  mutate(has_issue_regions = replace(has_issue_regions, has_issue_regions == "True", 1))

data <- data %>%                               
  mutate(has_issue_regions = replace(has_issue_regions, has_issue_regions == "False", 0))

data <- data %>%                               
  mutate(has_issue_anchor = replace(has_issue_anchor, has_issue_anchor == "True", 1))

data <- data %>%                               
  mutate(has_issue_anchor = replace(has_issue_anchor, has_issue_anchor == "False", 0))

data <- data %>%                               
  mutate(has_issue_table = replace(has_issue_table, has_issue_table == "True", 1))

data <- data %>%                               
  mutate(has_issue_table = replace(has_issue_table, has_issue_table == "False", 0))

data <- data %>%                               
  mutate(has_issue_form = replace(has_issue_form, has_issue_form == "True", 1))

data <- data %>%                               
  mutate(has_issue_form = replace(has_issue_form, has_issue_form == "False", 0))

data<- data %>%                               
  mutate(has_issue_lang = replace(has_issue_lang, has_issue_lang == "True", 1))

data <- data %>%                               
  mutate(has_issue_lang = replace(has_issue_lang, has_issue_lang == "False", 0))




data$Score <-  as.numeric(data$Score)
data$has_issue_headings <- as.numeric(data$has_issue_headings)
data$has_issue_image <- as.numeric(data$has_issue_image)
data$has_issue_regions <- as.numeric(data$has_issue_regions)
data$has_issue_anchor <- as.numeric(data$has_issue_anchor)
data$has_issue_table <- as.numeric(data$has_issue_table)
data$has_issue_form <- as.numeric(data$has_issue_form)
data$has_issue_lang <- as.numeric(data$has_issue_lang)



################################################# DATA MANIPULATION PART 2 ##########################################################

sapply(data, class)
summary(data)
str(data)

dftest <- data%>%     #Selecting the related example for analysis
  slice(1:200)

bothdfs <- rbind(data, dfedu) # assignig 2 df together
  
data <- data %>%                               
  mutate(Domain = 1)        #Tüm domain deðiþtirme iþlemi

dfedu <- data %>%                                    
mutate(Domain = replace(Domain, Domain == ".edu.tr/", 1 & ".ac.uk/", 1)) # Bu þekilde sadece e commerce ve uni alýnýp karþýlaþtýrýlmasý yapýlabilir
                                                                         #Üstteki iþlemlerden sonra domainler deðiþtirilip score karþýlatþýrýlmasý

################################################# ANALYSIS PART ##########################################################


lm.fit1 <- lm(Score ~ Language + Domain + has_issue_headings + has_issue_regions + has_issue_image + has_issue_anchor +has_issue_table + has_issue_form  +  has_issue_lang , data =data)
summary(lm.fit1)


lm.fit2 <- lm(Score ~  has_issue_headings + has_issue_regions + has_issue_image + has_issue_anchor + has_issue_table + has_issue_form + has_issue_lang , data = data )
summary(lm.fit2)

lm.fit3 <- lm(Score ~ Domain , data =data)
summary(lm.fit3)

correlations <- cor(data[,c (2,5,6,7)])
corrplot(correlations, method="circle")

#Decision Tree

library(tree)
set.seed(123)
tree.sites <- tree(has_issue_image ~ has_issue_anchor + Score  + has_issue_regions  + has_issue_table + has_issue_form + has_issue_lang , data = data)
summary(tree.sites)
plot(tree.sites)
text(tree.sites)

cv.sites <- cv.tree(tree.sites)
plot(cv.sites$size,cv.sites$dev,type='b')


prune.sites <- prune.tree(tree.sites,best=6)
plot(prune.sites)
text(prune.sites,pretty=0)

library(rpart)
library(rpart.plot)

treee <- rpart(has_issue_image ~  + has_issue_anchor + Score + has_issue_regions  + has_issue_table + has_issue_form + has_issue_lang , data = data)
rpart.plot(treee)

#Random Forest

library(randomForest)
set.seed(1)

cvdata <- data[sample(nrow(data)),]
folds <- cut(seq(1,nrow(cvdata)),breaks=5,labels=FALSE)

total_mse <- rep(NA,11)
for (i in 1:7) {
  mse <- rep(NA,5)
  #5-fold cross validation
  for (t in 1:5){
    set.seed(1)
    # cv_train_index <- sample(1:500,400)
    cv_test_index <- which(folds==t,arr.ind=TRUE)
    cv_train <- data[-cv_test_index,]
    cv_test <- data[cv_test_index,]
    rf.sites <- randomForest(Score ~  has_issue_headings + has_issue_regions + has_issue_image + has_issue_anchor + has_issue_table + has_issue_form + has_issue_lang, data=data, mtry= i, ntree=500, importance=TRUE, na.action = na.omit)
    pred <- predict(rf.sites,newdata=cv_test)
    mse[t] <- (1/nrow(cv_test))*sum((pred-cv_test$Score)^2)
  }
  total_mse[i] <- mean(mse)
}


min_mtry <- which.min(total_mse)
min_mtry


#According to random forests, which variables are import

importance(rf.sites)
varImpPlot(rf.sites, type=1)
varImpPlot(rf.sites) 



################################################# DATA VISUALIZATION PART ##########################################################

#################
dataedu<-read.csv2("web-accessibility-edu.csv", header = TRUE, stringsAsFactors = F, sep=",",dec=".")
dataretail<-read.csv2("web-accessibility-retail.csv", header = TRUE, stringsAsFactors = F, sep=",",dec=".")
datagov <- read.csv2("web-accessibility-gov.csv", header = TRUE, stringsAsFactors = F, sep=",",dec=".")

dataedu <- dataedu %>%                               
  mutate(Domain = "edu") 
dataretail <- dataretail %>%                               
  mutate(Domain = "com")
datagov <- datagov %>%                               
  mutate(Domain = "gov")


##################

lm.fit4 <- lm(Score ~ Domain , data = eduretailgov)
summary(lm.fit4)

#Plot 1 of Edu vs Retail vs Gov Score

eduretailgov <- rbind(dataretail, dataedu, datagov)


par(
  mfrow=c(1,3),
  mar=c(4,4,1,0)
)

hist(dataedu$Score, breaks=30 , xlim=c(0,100) , ylim=c(0,40), col=rgb(1,0,0,0.5) , xlab="Score" , ylab="Count" , main="Score Distribution of University Websites")
hist(dataretail$Score, breaks=30 , xlim=c(0,100) , ylim=c(0,40) , col=rgb(0,0,1,0.5) , xlab="Score" , ylab="" , main="Score Distribution of ECommerce Websites")
hist(datagov$Score, breaks=30 , xlim=c(0,100) , ylim=c(0,40) , col=rgb(0,0,1,0.9) , xlab="Score" , ylab="" , main="Score Distribution of Goverment Websites")
                                            
#Plot 2 Pie Chart 
observation_count <-  c(172, 80, 126)
labels <-  c("Univ.","Gov.","Ecomm.")

piepercent<- round(100*observation_count/sum(observation_count), 1)

pie3D(observation_count,labels = labels,explode = 0.1, main = "Pie Chart of the Websites")


#Plot 3 [] 

dataedu <- dataedu%>%     #Selecting the related example for analysis
  slice(1:145)

data %>%
  ggplot(aes(x = Language, y = Score, colour = has_issue_lang)) +
  geom_point() + 
  geom_smooth()

#Plot 4 [Tüm Scorelar alýndýgýnda genel olarak sitelerin ne kadar dikkat ettiði yorumlanabilir] 

outliers <- boxplot.stats(data$Score)$out

boxplot(data$Score,
        height = 400,
        width= 400,
        ylim = c(0,100),
        ylab = "Score",
        main = "Boxplot of Score With Outliers",
        col ="orange")

out <- which(data$Score %in% c(outliers)) #[For now there is no outlier]



#Plot 5 [Total score distribution]


Score= ggplot(aes(x=Score), data=data)+
  geom_histogram(binwidth = 1, fill='darkred', color='black')+
  ggtitle("Score Distribution")
Score


#Example plot 6 [yine ilk x kadar observation alýnýp mesela bunlar uni ise uni sitelerinin yuksek coðunluðu lang bile belirtmemiþ denilebilir]

boxplot(Score ~ has_issue_image, data = data)
################################################# PLOT EXAMPLES ##########################################################


#example plot
plot <- ggplot(data = data , aes(Language, Score)) +
  geom_point(alpha = 0.5)+
  geom_smooth(method = "lm" , se = FALSE)
plot


#example plot 2
scatterplotMatrix ( ~ Score + has_issue_headings + has_issue_regions + has_issue_image +has_issue_lang  , data = data )

#example plot 3 [Mesela ilk x kadar observation alýnýp bunlar e commerce veya edu sitesi denebilir ve language tr olan siteler onem sýrasýnda ilk 200 e girememiþ denilebilir]
Language= ggplot(data, aes(x=Language)) +
  geom_bar(fill='darkgreen')
Language 





#Example Plot 5

table(data$Languge)
region= ggplot(data=data,aes(x=Language,fill=Language))+geom_bar()
region

#Example Plot 6 [Having issue in lanuage leads to error.]

my_graph <- ggplot(data, aes(x = Name, y = Score )) +
  geom_point(aes(color = 172)) +
  stat_smooth(method = "lm",
              col = "#C42126",
              se = TRUE,
              size = 1)

my_graph

#Example Plot 7
plot(dataedu$Score,dataedu$has_issue_headings)


#Example Plot 8
dataretail %>%
  ggplot(aes(x = Language, y = Score, colour = has_issue_lang)) +
  geom_point() + 
  geom_smooth()

