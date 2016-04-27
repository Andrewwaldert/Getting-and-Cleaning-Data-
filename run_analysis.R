## Set Working Directory

##Opening Reshape2

library(reshape2)

filename <- "getdata_dataset.zip"

## Downloading and unzipping the file: 

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracting only the desired data on mean and standard deviation of the data set

featuresDesired <- grep(".*mean.*|.*std.*", features[,2])
featuresDesired.names <- features[featuresDesired,2]
featuresDesired.names = gsub('-mean', 'Mean', featuresDesired.names)
featuresDesired.names = gsub('-std', 'Std', featuresDesired.names)
featuresDesired.names <- gsub('[-()]', '', featuresDesired.names)

## Loading the Datasets

# Train
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresDesired]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)

# Test 
Test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresDesired]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

## Merging the Data Sets 
Merged_Data <- rbind(Train, Test)
colnames(Merged_Data) <- c("Subject", "Activity", featuresDesired.names)

## Turning into factor variables 

Merged_Data$Activity <- factor(Merged_Data$Activity, levels = activityLabels[,1], labels = activityLabels[,2])
Merged_Data$Subject <- as.factor(Merged_Data$Subject)

## Melting 
Merged_Data.melted <- melt(Merged_Data, id = c("Subject", "Activity"))
Merged_Data.mean <- dcast(Merged_Data.melted, Subject + Activity ~ variable, mean)

## Writing Table

write.table(Merged_Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
