#setting the working directory and loading relevant libraries
setwd("~/R")
library(dplyr)
library(data.table)


#reading the test and train files
xtest <- fread("X_test.txt")
ytest <- fread("y_test.txt")
xtrain <- fread("X_train.txt")
ytrain <-  fread("y_train.txt")
subtest <- fread("subject_test.txt")
subtrain <- fread("subject_train.txt")

#combining the test and train file into a single dataframe
xytest <- cbind(subtest,ytest,xtest)
xytrain <- cbind(subtrain,ytrain,xtrain)
xy <- rbind(xytest,xytrain)

#reading the features file and extracting mean and std measurements
features <- fread("features.txt")
pattern <- "mean|std"
#featindex is for column numbers to extract mean/std measurements
featindex <- features[grepl(pattern,features$V2),1]
#featname is for the descriptive variable names
featname <- features[grepl(pattern,features$V2),2]
xy <- as.data.frame(xy, stringsAsFactors = FALSE)

featindex <- unlist(featindex)
featname <- unlist(featname)
xymeanstd <- xy[,c(1,2,featindex+2)]

#reading the activity labels file and using subsetting to replace the 2nd column with descriptive activity names
activitylabel <- fread("activity_labels.txt")
activitylabel <- as.data.frame(activitylabel, stringsAsFactors = FALSE)
xymeanstd$V1.1 <- activitylabel[xymeanstd$V1.1,2]

colnames(xymeanstd) <- c("subject","activity", featname)

#using gsub to clean up the colnames
colnames(xymeanstd) <- gsub("-",".",colnames(xymeanstd))
colnames(xymeanstd) <- gsub("^t","time",colnames(xymeanstd))
colnames(xymeanstd) <- gsub("f","freq",colnames(xymeanstd))
colnames(xymeanstd) <- gsub("[()]","",colnames(xymeanstd))

#using the summarise, across and group by functions in dplyr to obtain a new dataset 
summarydf <- xymeanstd %>%
  group_by(subject,activity) %>%
  summarise(across(.cols = (3:79), .fns = mean))
#writing the dataframe to a text file
write.table(summarydf, file="summary.txt", sep = "\t", row.names = FALSE)