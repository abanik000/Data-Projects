##############################################################
## 
## Before Running this Rscript, be sure to set
## the working directory to that of this Rscript
## By doing the following
## 
## 1. open this R script file
## 2. click on the drop down menu `Session'
## 3. click `Set Working Directory'
## 4. click `To Source File Location'
##
##############################################################

library(data.table); seed <-2556271

power.t.test(n=NULL,delta = 15,sig.level = 0.05,sd=20,power=0.8,alternative = 'one.sided')
############################################################

## complete the columns in Sweets data table below by
## 1) Adding the appropriate number of subjects, assign them subject numbers, and
n<-23*2
Sweets <- data.table(SubjectNumber = 1:n)

## 2) assigning them either "Treatment" or "Control" by completing the code below

set.seed(seed)
## finish the incomplete code below
Sweets[, TransitionTreatment := sample(c("Control", "Treatment"), size = nrow(Sweets), replace = TRUE)]


## SubjectNumber = individual ID number for each subject
## TransitionTreatment = assigned "Treatment" or "Control" value
##                       for each subject
##                       (needs to be assigned below)
##
##                "Control" = control group transitioning with method A
##                "Treatment" = treatment group transitioning with method B


## After completing the code above, follow the steps at the top
## of this Rscript and click "source" to run the experiment 
## and collect your data

############################################################


## After assigning treatment values the code below will ask you to
## confirm that you are ready to run the experiment.


print(Sweets, topn = 5)
cat("
Preview of treatment assignments shown above 
Run experiment? (y)es or (n)o?
Type answer and press return/enter.
")
answer <- tolower(readline())

if(!(answer %in% c("y", "yes"))){stop("Stopping Experiment. When ready to complete experiment, 
click \"Source\" and select (y)es when prompted")}

collectData <- function(DT, seed){if(any(is.na(DT[,TransitionTreatment]))){stop("
################################################################
Need to assign values for treatment variable before running experiment
################################################################
")};if(any(!(DT[,TransitionTreatment] %in% c("Treatment", "Control")))){stop("
################################################################
Some values for treatment variable are unexpected, check spelling and/or capitalization
################################################################
")};nVal <- nrow(DT);  set.seed(seed);  e <- round(rnorm(nVal, sd = 15),0); while(  shapiro.test(e[DT$TransitionTreatment=="Treatment"])$p.value <0.9 | shapiro.test(e[DT$TransitionTreatment=="Control"])$p.value <0.9){e <- round(rnorm(nVal, sd = 15),0);};set.seed(seed);m <- round(rnorm(1, 30, sd = 5),0); d <- round(rnorm(1, 13.5, sd = 1),0);base <- round(rnorm(nVal, 250, 10), 0);DT[, PlayTimeBefore :=base];DT[, PlayTimeAfter :=base + m+d*(DT$TransitionTreatment == "Treatment") +e ];DT;};Sweets <- collectData(Sweets, seed);folderName <- getwd();fileName <- "Sweets.csv";filePath <- paste0(folderName, "/",fileName);if(!(any(c("SOLUTIONrunExperimentSweets.R", "runExperimentSweets.R")  %in% list.files()))){cat(paste0("################################################################
Do you want to save the data in the folder

",folderName, "

(y)es or (n)o?
Type answer and press return/enter.
"));answer <- tolower(readline());if(!(answer %in% c("y", "yes"))){stop("Stopping Experiment. Be sure to set working directory to Source file before running the Rscript by following the instructions at the top of the .R file")};};write.csv(Sweets, file = fileName, row.names = FALSE);cat(paste0("##########################################################################################

Data successfully saved in the file 
", filePath,"
##########################################################################################"));rm(list= ls())

