## Depends on packages
# data.table
# reshape2

require("data.table")
require("reshape2")

## Assume data is in $PWD/data/
## Read activity labels and features into variables
act_labels <- read.table("data/activity_labels.txt")[,2]
features <- read.table("data/features.txt")[,2]

## Grep for mean and standard deviation for each measurement record
measure_features <- grepl("mean|std", features)

## Read x, y and subject test data
x_test <- read.table("data/test/X_test.txt")
y_test <- read.table("data/test/y_test.txt")
subjects <- read.table("data/test/subject_test.txt")

## Set headers for a vector x_test and filter only the measurements
names(x_test) = features
x_test = x_test[,measure_features]

## Filter activity labels
y_test[,2] = act_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subjects) = "subject"

## Combine into a new data frame
test_data <- cbind(as.data.table(subjects), y_test, x_test)

## Read training data
x_train <- read.table("data/train/X_train.txt")
y_train <- read.table("data/train/y_train.txt")
subject_train <- read.table("data/train/subject_train.txt")

## Set headers for data frame x_train and filter the mean and std deviation
names(x_train) = features
x_train = x_train[,measure_features]

## Load activity data
y_train[,2] = act_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

## Combine training data into a new data frame
train_data <- cbind(as.data.table(subject_train), y_train, x_train)
data = rbind(test_data, train_data)
ids = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), ids)
melt_data = melt(data, id = ids, measure.vars = data_labels)

## Calculate average
avg = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(avg, file = "averages.txt", row.names=FALSE)
