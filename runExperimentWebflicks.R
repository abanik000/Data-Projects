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

library(data.table)
library(pwr)


## total Sample size
## Need to provide!

#w/o interaction
pwr.f2.test(u = (3-1), v = NULL, f2 = 0.25^2,sig.level = 0.05, power = 0.8)
pwr.f2.test(u = (4-1), v = NULL, f2 = 0.25^2,sig.level = 0.05, power = 0.8)


c<-3
r<-4
v1=154.1898
v2 = 174.3971
N1 <- v1+c+r-1 #N1=160.1898
N2 <- v2 + c + r - 1 #N2 = 180.3971
n1<- 180.3971/(3*4) #15.033
n2<-160.1898/(3*4) #13.349
N1_final<-16*12 #192
N2_final<-14*12 #168

# n2 = 16; N = 16 * 12 = 192
N<-180
# Final Sample Size
# N = 180, n = 15, because we ran both tests and it is the closest
## Our Subject data
Webflicks <- data.table(SubjectNumber = 1:N, 
                     ReleaseSchedule = NA, 
                     Genre = NA)
## SubjectNumber = individual ID number for each subject
## ReleaseSchedule = assigned "Drop", "Weekly", "DualDrop"
##                for each subject
##                (needs to be assigned below)
##
##                "Drop" = Show released in a single drop 
##                "Weekly" = Show released in a weekly format
##                "DualDrop" = Show released in two batches
## Genre = assigned "Comedy", "Drama", "Mystery", or "Fantasy" value
##                for each subject
##                (needs to be assigned below)
##
##                "Comedy" = Show falls into the Comedy genre
##                "Drama" = Show falls into the Drama genre
##                "Mystery" = Show falls into the Mystery/Crime genre
##                "Fantasy" = Show falls into the Fantasy/SciFi genre

seed <- 2556271
############################################################


set.seed(seed)
## put code assigning each subject to a combination 
## of Release Schedule and Genre here

Assignments <-data.table(A = rep(c("Drop", "Weekly", "DualDrop"),
                                 each = 15*4, times = 1),
                         B = rep(c("Comedy","Drama","Mystery", "Fantasy"),
                                 each = 15, times = 3))

Assignments <- Assignments[sample(1:N)]
Webflicks$ReleaseSchedule <- Assignments[,A]
Webflicks$Genre <- Assignments[,B]
# Do not add code beyond this point
# Everything below should remain unchanged

############################################################

## After assigning treatment values the code below will ask you to
## confirm that you are ready to run the experiment.

print(Webflicks, topn = 5)
cat("
Preview of treatment assignments shown above 
Run experiment? (y)es or (n)o?
Type answer and press return/enter.
")
answer <- tolower(readline())

if(!(answer %in% c("y", "yes"))){stop("Stopping Experiment. When ready to complete experiment, 
click \"Source\" and select (y)es when prompted")}

v1Name <- "ReleaseSchedule";
v1Vals <- c("Drop", "Weekly", "DualDrop");
v1ValsGen <- c("G1", "G2", "G3");
v2Name <- "Genre";
v2Vals <- c("Comedy", "Drama", "Mystery", "Fantasy");
v2ValsGen <- c("H1", "H2", "H3", "H4");
vNames <- c(v1Name, v2Name)
yName <- "Views";
collectData <- function(inputDT, seed){
  if(any(is.na(inputDT[,..vNames]))){stop("
################################################################
Need to assign values for treatment variable before running experiment
################################################################
")}
  if(any(!(inputDT[[v1Name]] %in% v1Vals) | !(inputDT[[v2Name]] %in% v2Vals))){stop(paste0("
################################################################
Some values for treatment variable are unexpected, values for treatment variable should be spelled as:

",paste0(v1Vals, collapse = " ") ,"
 and 
",paste0(v2Vals, collapse = " ") , "

check spelling and/or capitalization
################################################################
"))}
  
  #Scramble Levels  
  if(TRUE){
    set.seed(seed)
    v1ValsGen <- v1ValsGen[sample(1:length(v1ValsGen))]
  }
  
  DT <- copy(inputDT);
  for(i in 1:length(v1Vals)){
    DT[eval(parse(text = v1Name)) == eval(v1Vals)[i], TreatmentG :=..v1ValsGen[i]];
  }  
  for(i in 1:length(v2Vals)){
    DT[eval(parse(text = v2Name)) == eval(v2Vals)[i], TreatmentH :=..v2ValsGen[i]];
  }  
  DT[,orderNum := 1:nrow(DT)]
  setkey(DT, TreatmentG, TreatmentH)
  
  
  
  
  nVal <- nrow(DT);  
  if(seed == 1){ SZ1 <- "Small"}else {set.seed(seed); SZ1 <- sample(c("Medium", "Large"), 1)}
  if(nVal>900){f1 <- 0.1} else if(nVal<100){f1 <- 0.4}else {f1<-0.25} 
  
  set.seed(seed);  
  sigFig <- 3; s<- 15*(0.25/f1);
  alphG1 <- 0.001
  alphG2 <- 0.01
  alphH1 <- 0.05
  alphH2 <- 0.1
  UB <- min(max(c(0.3, 4*alphG2, 4*alphH2)), 0.5)
  
  
  e <- round(rnorm(nVal, sd = s),sigFig); 
  partial <- aov(e ~ DT$TreatmentG + DT$TreatmentH)
  p1 <- summary(partial)[[1]][[5]][1]
  p2 <- summary(partial)[[1]][[5]][2]
  while( shapiro.test(e)$p.value <0.9 | p1  < UB | p2 < UB){
    e <- round(rnorm(nVal, sd = s),sigFig);
    partial <- aov(e ~ DT$TreatmentG + DT$TreatmentH)
    p1 <- summary(partial)[[1]][[5]][1]
    p2 <- summary(partial)[[1]][[5]][2]
  };
  
  
  
  
  OBar <- mean(e)
  partial <- aov(e ~ DT$TreatmentG + DT$TreatmentH)
  MSE <- summary(partial)[[1]][[3]][3]
  MSEdf <- summary(partial)[[1]][[1]][3]  
  c <- length(unique(DT$TreatmentG))
  r <- length(unique(DT$TreatmentH))
  littleN <- nVal/(r*c)
  
  
  set.seed(seed)
  m <- round(rnorm(1, 64, sd = 1), sigFig); 
  
  
  
  ## A
  GLevel <- "G1"
  
  MSG <- summary(partial)[[1]][[3]][1]
  MSGdf <- summary(partial)[[1]][[1]][1]
  
  GBar <- mean(e[DT$TreatmentG == GLevel])
  Gdiff <- GBar-OBar
  cStar <- c/(c-1)
  
  Ga <- qf(1-alphG2, MSGdf, MSEdf)
  Gb <- qf(1-alphG1, MSGdf, MSEdf)
  
  set.seed(seed)
  d1 <- round(runif(n = 1, 
                    min = (sqrt((Ga*MSE-MSG)*(c-1)/(littleN*r) + (cStar)*Gdiff^2)-sqrt(cStar)*Gdiff)*sqrt(cStar),
                    max = (sqrt((Gb*MSE-MSG)*(c-1)/(littleN*r) + (cStar)*Gdiff^2)-sqrt(cStar)*Gdiff)*sqrt(cStar)), 
              sigFig)
  
  
  
  ## B
  HLevel <- "H1"
  
  MSH <- summary(partial)[[1]][[3]][2]
  MSHdf <- summary(partial)[[1]][[1]][2]
  
  HBar <- mean(e[DT$TreatmentH == HLevel])
  Hdiff <- HBar-OBar
  rStar <- r/(r-1)
  
  Ha <- qf(1-alphH2, MSHdf, MSEdf)
  Hb <- qf(1-alphH1, MSHdf, MSEdf)
  
  set.seed(seed)
  d2 <- round(runif(n = 1,
                    min = (sqrt((Ha*MSE-MSH)*(r-1)/(littleN*c) + (rStar)*Hdiff^2)-sqrt(rStar)*Hdiff)*sqrt(rStar),
                    max = (sqrt((Hb*MSE-MSH)*(r-1)/(littleN*c) + (rStar)*Hdiff^2)-sqrt(rStar)*Hdiff)*sqrt(rStar)),
              sigFig)
  
  d2 <- 0# round(rnorm(1, 5, sd = 1), sigFig)
  
  DT[, y :=  m+d1*(TreatmentG ==GLevel) + d2*(TreatmentH ==HLevel) + e ]
  setkey(DT, orderNum)
  inputDT[,(yName) := DT[,y]]
  inputDT
}

Webflicks <- collectData(Webflicks, seed)

folderName <- getwd();
fileName <- "Webflicks.csv";
exptNames <- c("SOLUTIONrunExperimentWebflicks.R", "runExperimentWebflicks.R")
filePath <- paste0(folderName, "/",fileName);
if(!(any(exptNames   %in% list.files()))){
  
  cat(paste0("################################################################
Do you want to save the data in the folder

",
             folderName, "

(y)es or (n)o?
Type answer and press return/enter.
"));
  answer <- tolower(readline());
  if(!(answer %in% c("y", "yes"))){stop("Stopping Experiment. Be sure to set working directory to Source file before running the Rscript by following the instructions at the top of the .R file")};
}
write.csv(Webflicks, file = fileName, row.names = FALSE)
cat(paste0("##########################################################################################

Data successfully saved in the file 
", filePath,"
##########################################################################################"));rm(list= ls())

