################################################################################
#
# run_analysis.R
#
# This R script was written on September 7, 2015 by henry2016, as a programming
# assignment for the Coursera course "Getting and Cleaning Data", created by
# the Data Science Team at the Johns Hopkins Bloomberg School of Public Health.
#
# According to the assignment's instructions, this script should:
#
# 1. Merge the training and the test sets to create a single data set.
# 2. Extract only the measurements on the mean and standard deviation for each
#    measurement.
# 3. Use descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set
#    with the average of each variable for each activity and each subject.
#
#
################################################################################
#
# The training and the test sets are in the "UCI HAR Dataset" folder.  The
# license in the README.txt file of that folder mentions:
#
# Use of this dataset in publications must be acknowledged by referencing the
# following publication [1]
#
# [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L.
# Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass
# Hardware-Friendly Support Vector Machine. International Workshop of Ambient
# Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
#
# This dataset is distributed AS-IS and no responsibility implied or explicit
# can be addressed to the authors or their institutions for its use or misuse.
# Any commercial use is prohibited.
#
################################################################################
library (plyr)

# Main routine, to summarize the data for step 5
main <- function() {
    df <- makeTidyData() # Get step 4 data frame
    newDf <- data.frame()

    # Get a list of activities
    activityList <- sort(unique(df[, "activity"]))

    for (activity in activityList) {
        # get a list of subjects for this activity
        subjectList <- sort(unique(
            df[df$activity == activity, "subject"]))
        for (subject in subjectList) {
            # print(paste("subjectId =", subjectId, ", activity =", activity))
            indices <- (df$subject == subject) & (df$activity == activity)
            sliced <- df[indices, ]
            newRow <- list(activity, subject)
            means <- NULL
            for (i in 3:ncol(sliced)) {
                meanVal = mean(sliced[, i])
                newRow[length(newRow) + 1] <- meanVal
            }
            rowDf <- as.data.frame(matrix(newRow, ncol = length(newRow)), stringsAsFactors = FALSE)
            newDf <- rbind(newDf, rowDf)
        }
    }
    names(newDf) <- names(df)
    newerDf <- data.frame(lapply(newdf, as.character), stringsAsFactors=FALSE)
    write.table(newerDf, "output.txt", row.names = FALSE)
    return(newerDf)
}



makeTidy <- function(nameFrag = "test", baseDir = "UCI Har Datase",
                     colLabels = NULL) {
    # Read the data file into a data frame
    dataFileName <- sprintf("%s/%s/x_%s.txt", baseDir, nameFrag, nameFrag)
    df <- read.table(dataFileName)

    # Create a logic vector indicating which columns have averages or
    # standard deviations.
    aveL <- grepl("-mean()", colLabels, fixed = TRUE)
    stdL <- grepl("-std()", colLabels, fixed = TRUE)
    aveOrStdL <- aveL | stdL

    # Make a list of the column names having averages or standard deviations.
    aveOrStdColNames <- colLabels[aveOrStdL]

    # Sanitize the column names
    for (i in 1:length(aveOrStdColNames)) {
        aveOrStdColNames[i] <- gsub("-mean()", "Mean", aveOrStdColNames[i],
                                    fixed = TRUE)
        aveOrStdColNames[i] <- gsub("-std()", "Std", aveOrStdColNames[i],
                                    fixed = TRUE)
        aveOrStdColNames[i] <- sub("-", "", aveOrStdColNames[i],
                                    fixed = TRUE)
    }

    # select only those columns from the data frame.
    df <- df[, aveOrStdL]

    # Get the activity labels
    activityLabelsFileName <- sprintf("%s/activity_labels.txt", baseDir)
    activityLabels <- read.table(activityLabelsFileName,
                                 stringsAsFactors = FALSE)[, 2]

    # Get the vector of activity factors
    activityFactorsFileName <- sprintf("%s/%s/y_%s.txt",
                                       baseDir,
                                       nameFrag,
                                       nameFrag)
    activityFactors <- read.table(activityFactorsFileName)[, 1]
    for (i in 1:length(activityFactors)) {
        activityFactors[i] <- activityLabels[as.numeric(activityFactors[i])]
    }

    # Get the vector of subjects
    subjectsFileName <- sprintf("%s/%s/subject_%s.txt", baseDir, nameFrag, nameFrag)
    subjects <- read.table(subjectsFileName)

    # Combine the activities, subjects, and data into a frame
    combinedFrame <- cbind(activityFactors, subjects, df,
                           stringsAsFactors = FALSE)

    # Set the column names in the combinedFrame
    names(combinedFrame) <- c("activity", "subject", aveOrStdColNames)
    combinedFrame <- combinedFrame[order(combinedFrame[, 1],
                                         combinedFrame[, 2]), ]
    return( combinedFrame )
}

# Helper function to create a merged tidy data frame, corresponding to
# steps 1-4 of the assignment's instructions.
makeTidyData <- function() {
    baseDir <- "UCI Har Dataset"
    colNameFileName <- sprintf("%s/features.txt", baseDir)
    colLabels <- read.table(colNameFileName,
                            stringsAsFactors = FALSE)[, 2]

    trainDataFrame <- makeTidy("train", baseDir, colLabels)
    testDataFrame <- makeTidy("test", baseDir, colLabels)
    mergedDataFrame <- rbind(trainDataFrame, testDataFrame)
}


