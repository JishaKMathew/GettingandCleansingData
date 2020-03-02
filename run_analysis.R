# Getting and Cleansing Data Project
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load required packages
library(dplyr)
library(data.table)
library(tidyr)

# Download the dataset
filename<-"Course3UCIDataSet.Zip"

# Check if folder exists already
if(!file.exists(filename))
{
  fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL,filename,method="curl")
}

# Check if destination folder exists, if not create it
if(!file.exists("UCI HAR Dataset"))
{
  unzip(filename)
}

# Read the available datasets
# Features
dataFeaturesTest  <- read.table("UCI HAR Dataset/test/X_test.txt",header = FALSE)
dataFeaturesTrain <- read.table("UCI HAR Dataset/train/x_train.txt",header = FALSE)

#Activity
dataActivityTest  <- read.table("UCI HAR Dataset/test/y_test.txt",header = FALSE)
dataActivityTrain <- read.table("UCI HAR Dataset/train/y_train.txt",header = FALSE)

#Subject
dataSubjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt",header = FALSE)
dataSubjectTest  <- read.table("UCI HAR Dataset/test/subject_test.txt",header = FALSE)

str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

# Merge the training and the test sets to create one data set
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# Set Names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table("UCI HAR Dataset/features.txt",head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# Extract  the measurements on the mean and standard deviation for each measurement only
tidydataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(tidydataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",header = FALSE)
head(Data$activity,30)

#Appropriately labels the data set with descriptive variable names.
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

#creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

