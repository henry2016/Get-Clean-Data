# Get-Clean-Data
A student project for the online Coursera course,
_Getting and Cleaning Data_,
 presented by Jeff Leek, PhD, Roger D. Peng, PhD, and Brian Caffo, PhD,
of Johns Hopkins University
Bloomberg School of Public Health.

#### Repo Contents
This repo contains:
* _run_analysis.R_ -- an R Scipt that cleans and tidies data from a specific experiment's data set.
* _output.txt_ -- a text table corresponding to dataframe obtained from running _run_analysis.R_.
* _CodeBook.md_ -- describing the variables, the data, and what was done to clean and tidy the data.

#### Data Source Files
To run the _run_analysis.R_ script, first the experimental data must be downloaded and unzipped into the working directory.  When properly extracted, several datasets will be in a subfolder named "UCI HAR Dataset".

The experimental data can be found here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#### Experiment Overview
Briefly, the original experiment involved capturing accelerometer and gyroscope sensor data from a smartphone while a group of thirty subjects each performed
half a dozen different activities multiple times. The experimenters used time-domain and frequency domain signal-processing techniques to further process their measurement data. This pre-processed data was then split into two
parts: a training set and a test set.


A full description of the experiment is 
available at the site where the data was originally obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

#### What the R Script Does
##### Overview
The _run_analysis.R_ script creates a function called _main()_ that reads the experiment's pre-processed data, performs several additional processing steps, creates a data frame that summarizes the results, and both writes those results to an _output.txt_ file, and returns the results as a data frame.

The additional processing steps include filtering the data to select certain variables, adding activity and subject information to the measurement data, and merging data from both the training and test data sets.  To minimize the amount of memory needed to store the data, and the amount of data copying done during processing, the filtering was done before merging the data sets.  Furthermore, since similar processing would be needed to filter both the training and test data sets, a single subroutine named _makeTidy()_ was created to handle the filtering of each dataset.

The _makeTidy()_ subroutine is called twice; once for the test dataset, and once for the training data set. The subroutine that calls _makeTidy()_ twice is named _makeTidyData()_, and after _makeTidyData()_ makes the two filtered datasets, it merges them into a single result. Details of the filtering performed by the _makeTidy()_ subroutine are described later.

After calling _makeTidyData()_ to get the filtered, merged result, the _main()_ routine creates a new dataframe that shows the average of the (filtered) variables for each combination of activity type and subject.  This new data frame is written as a table to the _output.txt_ file, and returned as a data frame by the _main()_ routine.

The _main()_ routine takes 19.37 seconds to execute on a 2.67 GHz Core i7.

##### Details about the _makeTidy()_ subroutine
The prototype of the _makeTidy()_ subroutine looks like this:
````R
makeTidy <- function(nameFrag = "test", baseDir = "UCI Har Datase", colLabels = NULL) 
````
This function takes three parameters:
* nameFrag -- a text string indicating whether the "test" or "training" dataset is being processed.
* baseDir -- the relative path of the directory containing the experimental datasets.
* colLabels -- A list of label strings to be applied to the dataset's columns.

The _makeTidy()_ subroutine creates a path to an experimental dataset from its parameters, and reads the data into a data frame.  It then filters the columns of the data frame to those containing means or standard deviations, by retaining only those columns whose labels contain either the substring "-mean()" or "-std()".

This filtering excludes labels such as "fBodyAccJerk-meanFreq()-X" and "angle(tBodyGyroMean,gravityMean)", since although these labels include the substring "mean", the underlying variable isn't an arithmetic mean.

The resulting column labels are further sanitized by removing the parentheses and hyphens that otherwise might confuse R, and columns of data for the activity type and subject id are inserted into the data frame.
