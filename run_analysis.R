# # Data Science Specialization:
# # Course 3: Getting and Cleaning Data - Course Project
# 
# The purpose of this project is to demonstrate your ability to collect, work with, 
# and clean a data set. The goal is to prepare tidy data that can be used for later 
# analysis. You will be graded by your peers on a series of yes/no questions related 
# to the project. You will be required to submit: 
#     1) a tidy data set as described below, 
#   2) a link to a Github repository with your script for performing the analysis, and 
#   3) a code book that describes the variables, the data, and any transformations 
#      or work that you performed to clean up the data called CodeBook.md. 
# 
# You should also include a README.md in the repo with your scripts. This repo explains 
# how all of the scripts work and how they are connected.  
# 
# One of the most exciting areas in all of data science right now is wearable 
# computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up 
# are racing to develop the most advanced algorithms to attract new users. The data 
# linked to from the course website represent data collected from the accelerometers 
# from the Samsung Galaxy S smartphone. A full description is available at the site 
# where the data was obtained: 
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# 
# Here are the data for the project: 
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# You should create one R script called run_analysis.R that does the following. 
# Merges the training and the test sets to create one data set.

Extracts only the measurements on the mean and standard deviation for each measurement. 
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names. 
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Install and load any packages required for this project:
# data.table:
if(require("data.table")){
  print("data.table is loaded correctly")
} else {
  print("trying to install data.table")
  install.packages("data.table")
  if(require(data.table)){
    print("data.table installed and loaded")
  } else {
    stop("could not install data.table")
  }
}
# reshape2:
if(require("reshape2")){
  print("reshape2 is loaded correctly")
} else {
  print("trying to install reshape2")
  install.packages("reshape2")
  if(require(reshape2)){
    print("reshape2 installed and loaded")
  } else {
    stop("could not install reshape2")
  }
}

# Set working directory: please change as necessary:
setwd("C:\\Users\\gagan.mathur\\OneDrive\\Data Science Specialization\\Course 3 Getting and Cleaning Data\\UCI HAR Dataset")
# getwd(); list.files()

# Step 1. Merge the training and the test sets to create one data set: x - features, y - labels, subject - id
x_train <- read.table("./train/X_train.txt", sep="", header=FALSE)
y_train <- read.table("./train/y_train.txt", sep="", header=FALSE)
sbj_train <- read.table("./train/subject_train.txt", sep="", header=FALSE)
class(x_train);class(y_train);class(sbj_train)
nrow(x_train);nrow(y_train);nrow(sbj_train)
dtTraining <- cbind(x_train,y_train,sbj_train)

x_test <- read.table("./test/X_test.txt", sep="", header=FALSE)
y_test <- read.table("./test/y_test.txt", sep="", header=FALSE)
sbj_test <- read.table("./test/subject_test.txt", sep="", header=FALSE)
class(x_test);class(y_test);class(sbj_test)
nrow(x_test);nrow(y_test);nrow(sbj_test)

dtTest <- cbind(x_test,y_test,sbj_test)

dtRawAll <- rbind(dtTraining,dtTest)
nrow(dtRawAll) ; ncol(dtRawAll)

# Step 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
activity_labels <- read.table("./activity_labels.txt") %>% rename(ID=V1,Label=V2)
features <- read.table("./features.txt")  %>% rename(ID=V1,Label=V2)
# head(activity_labels); head(features)

id <- as.numeric(1:563); act <- c(as.character(features$Label),"ActivityID","SubjectID")
length(id);length(act); class(id);class(act)
features <- as.data.frame(cbind(id,act)); names(features) <- c("ID","Label")
names(dtRawAll) <- features$Label
extract_features <- c(as.character(features[grep("mean|std", features$Label),2]),"ActivityID","SubjectID")
dtRawAll <- dtRawAll[,extract_features]
dtRawAll <- merge(dtRawAll,activity_labels,by.X="ActivityID",by.Y="ID",all=TRUE)

# Step 3. Uses descriptive activity names to name the activities in the data set
# Step 4. Appropriately labels the data set with descriptive variable names. 
dtRawAll <- select(dtRawAll,1:81,83)
names(dtRawAll)[82]<-"ActivityName"

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

id_labels   = c("SubjectID", "ActivityID", "ActivityName")
data_labels = setdiff(colnames(dtRawAll), id_labels)
melt_data      = melt(dtRawAll, id = id_labels, measure.vars = data_labels)
dtMeans <- dcast(melt_data, SubjectID+ActivityID+ActivityName ~ mean)
