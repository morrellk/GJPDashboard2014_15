##   GJP_category.R
##   
##   Function getCategoryScores() finds forecaster Brier scores by category and
##   Plots the running Brier scores for forecaster and group by date questions
##   close.
##   
##   Usage:
##   cat_df <- getCategoryScores( qGJPdt, outFile="cat_df.csv")
##   
##   Arguments:
##        qGJPdt:  data table object as returned from processGJPDashboard()
##        outFile: name of the csv file where results will be stored.
##
##   Output:
##        Returns and writes to a csv file:
##        cat_df: data frame containing columns:
##                       Category  - character name of category
##                       N         - number of questions categorized with this
##                       Brier     - forecaster Brier score, averaged among 
##                                      questions in category
##                       Group     - Group Brier score, averaged among questions
##                                      in category
##                       Diff      - Difference between group and individual
##                                      scores, Group - Brier
##                       Better    - Sign of Diff, 1 for forecaster beat group
##                                                0 for the same
##                                                -1 for forecaster worse than group
##
##        plots of running Brier and Group scores
##   
##   
##   Assumes that datatable output from processGJPDashboard() is available
##   in the environment
##
##   8 - Sep - 15   K. Morrell
##
getCategoryScores <- function( qGJPdt, outFile="cat_df.csv") {
     
     ##   Make sure the category columns are logicals
     ##   hard-coded category column start and end - should fix
     cat_col_start = 7
     cat_col_end = length(names(qGJPdt))-4
     cat_name = ""
     nques = 0
     cat_scores = 0
     grp_scores =0
     ## surely a better way to do this than a for loop
     for (c in cat_col_start:cat_col_end){
          qGJPdt[[c]] <- as.logical(qGJPdt[[c]])
          cat_scores[c-cat_col_start+1] <- 
               round( mean( qGJPdt$BrierScore[ which(qGJPdt[[c]])]),digits=3)
          grp_scores[c-cat_col_start+1] <- 
               round( mean( qGJPdt$GroupScore[ which(qGJPdt[[c]])]),digits=3)
          nques[c-cat_col_start+1] <- sum(qGJPdt[[c]])
          cat_name[c-cat_col_start+1] <- names(qGJPdt)[c]
     }
     
     ## Put the information together into a data frame
     cat_df <- data.frame(cat_name, nques, cat_scores, grp_scores, stringsAsFactors=FALSE)
     colnames(cat_df) <- c("Category","N", "Brier","Group")
     
     ## Pull out the information comparing individual to group.
     cat_df <- mutate(cat_df, Diff=Group-Brier, Better=sign(Diff))
     
     ## Sort the results by whether better or worse than group, then by how
     ## much better than the group (from better to worse), then by number of
     ## questions in the category.
     cat_df <- arrange(cat_df, desc(Better), desc(Diff), desc(N), Category)
     
     ##
     ##   Add here quick plot of running scores
     y1 <- min( qGJPdt$runBrier, qGJPdt$runGroup)
     y2 <- max( qGJPdt$runBrier, qGJPdt$runGroup)
     x1 <- min( as.Date(qGJPdt$DateClosed,"%m/%d/%Y"))
     x2 <- max( as.Date(qGJPdt$DateClosed,"%m/%d/%Y"))
     
     plot(as.Date(qGJPdt$DateClosed,"%m/%d/%Y"), qGJPdt$runBrier, col="blue",
          xlab="Date Closed", ylab="Brier scores", main="Scores vs Time",
          ylim=c(y1,y2), xlim=c(x1,x2) )
     points(as.Date(qGJPdt$DateClosed,"%m/%d/%Y"), qGJPdt$runGroup, col="red",
          xlab="", ylab="", ylim=c(y1,y2), xlim=c(x1,x2) )
     
     lines(as.Date(qGJPdt$DateClosed,"%m/%d/%Y"), qGJPdt$runGroup, col="red",
           xlab="", ylab="", ylim=c(y1,y2), xlim=c(x1,x2) )
     
     lines(as.Date(qGJPdt$DateClosed,"%m/%d/%Y"),qGJPdt$runBrier, col="blue",
           xlab="", ylab="", ylim=c(y1,y2), xlim=c(x1,x2) )
     
     ## Write the data frame to a csv file for later use
     write.csv( cat_df, outFile)
     
     return(cat_df)
} 
     
     
  
     
     