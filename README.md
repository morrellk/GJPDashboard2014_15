# GJPDashboard2014_15
R code to read in forecaster dashboard from 2014-15 and other information.

This was a project to read in and process individual results from the 2014-15 Good Judgment Project [1] forecasting tournament, for one of the experimental 
conditions. The experimental conditions in this case were: working
as an individual, receiving and rating anonymous "tips", feedback of individual 
and group Brier scores as well as leaderboard for top 20 in the same experimental
group.  The code was written to look at what types of questions
a given forecaster was better or worse at answering. It may not be useful to GJP 
participants who were working under other conditions. 

The function _processGJPDashboard()_ takes an html copy of the forecaster dashboard
page and an rtf copy of the questions page as inputs and outputs a csv file of
the forecaster's results by question number.  A datatable of the results is also
returned by the function.  

The function _getCategoryScores()_, in the file GJP_category.R, takes as input the
datatable returned by _processGJPDashboard()_ and produces a csv file of the mean
score for each question category.  "Category" in this case refers to the label(s)
associated with individual questions, such as "Africa-North", "InternationalOrganizations",
or "Weapons", not to question groups defined elsewhere by GJP.  

## To Run
* Get a copy of processGJPDashboard.R and GJP_category.R in a suitable working
directory. 

* Install and load the R packages data.table, dplyr, and XML

* Source processGJPDashboard.R and GJP_Category.R

* Run:

     qGJPdt <- processGJPDashboard( dashFile = "dashFile.html", 
                                   questFile = "questFile.rtf",
                                   outFile = "qGJPdt.csv")

     
     cat_df <- getCategoryScores( qGJPdt, dropNA = FALSE, outFile = "cat_df.csv")
          + dropNA is logical and indicates whether to drop (TRUE) or use (FALSE) 
          questions with no forecast by this participant.
     

## Inputs
* Files used:
     + Dashboard HTML file: default is "dashFile.html".  Will need to have saved 
     this from 2014-2015 GJP site.
     + Question file, RTF: default is "questFile.rtf".  Will need to have saved 
     an RTF file of the questions page, or be able to convert that saved page to
     RTF.  (File used so far was converted from PDF via Automator.) 


## Output
* Files output:
     + qGJPdt.csv --- file containing the datatable of forecaster results by
     question.  See codebook for information on variables.
     + cat_df.csv --- file containing the mean results for the forecaster and the
     group by question category. See codebook for information on variables.    


[1]  The Good Judgment Project was an IARPA-funded research project into 
crowd-sourced prediction of geo-political events.  The original research project
has ended, but information about it can be found at:  http://www.goodjudgment.com/index.html 

My only affiliation with Good Judgment Project has been as one of the crowd of 
participants/dart-throwing monkeys.
