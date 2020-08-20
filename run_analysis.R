#Get the DATA
filesPath <- "D:/USERS/OneDrive/Documentos/R Files/Course 3/UCI HAR Dataset"
setwd(filesPath)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Load the required packages
library(dplyr)

#Read the data

features <- read.table("features.txt", col.names = c("n","functions"))
activityLabels <- read.table("activity_labels.txt", col.names = c("code", "activity"))

subjectTest <- read.table("test/subject_test.txt", col.names = "subject")
xTest <- read.table("test/X_test.txt", col.names = features$functions)
yTest <- read.table("test/y_test.txt", col.names = "code")

subjectTrain <- read.table("train/subject_train.txt", col.names = "subject")
xTrain <- read.table("train/X_train.txt", col.names = features$functions)
yTrain <- read.table("train/y_train.txt", col.names = "code")

#Merge the training and the test sets to create one data set

X <- rbind(xTrain,xTest)
Y <- rbind(yTrain,yTest)
SubjectXY <- rbind(subjectTrain,subjectTest)

DataXY <- cbind(SubjectXY, Y, X)

#Extract only the measurements on the mean and standard deviation 
#for each measurement.

DataMeanStd <- DataXY %>% select(subject, code, contains("mean"), contains("std"))

#Use descriptive activity names to name the activities in the data set

DataMeanStd$code <- activityLabels[DataMeanStd$code, 2]

names(DataMeanStd)[2] = "activity"
names(DataMeanStd) <- gsub("std()","SD", names(DataMeanStd))
names(DataMeanStd) <- gsub("mean()", "MEAN", names(DataMeanStd))
names(DataMeanStd) <- gsub("^t", "time", names(DataMeanStd))
names(DataMeanStd) <- gsub("^f", "frequency", names(DataMeanStd))
names(DataMeanStd) <- gsub("Acc", "Accelerometer", names(DataMeanStd))
names(DataMeanStd) <- gsub("BodyBody", "Body", names(DataMeanStd))
names(DataMeanStd) <- gsub("Gyro", "Gyroscope", names(DataMeanStd))
names(DataMeanStd) <- gsub("Mag", "Magnitude", names(DataMeanStd))
names(DataMeanStd) <- gsub("tBody", "TimeBody", names(DataMeanStd))
names(DataMeanStd) <- gsub("angle", "Angle", names(DataMeanStd))
names(DataMeanStd) <- gsub("gravity", "Gravity", names(DataMeanStd))

#Create a second, tidy Data set with average of each variable
#for each activity and each subject

TidyData <- DataMeanStd %>% 
  group_by(subject, activity) %>%
  summarise_all(list(mean))
write.table(TidyData, "TidyData.txt", row.name=FALSE)
