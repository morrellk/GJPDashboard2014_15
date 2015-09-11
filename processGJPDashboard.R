##   processGJPDashboard.R
##   
##   Functions to read in HTML code for the GJP dashboard page for an
##   individual forecaster and store the information in dataframes for
##   later analysis.
##   
##   Written for dashboard that was presented for 2014/15 season, forecaster 
##   experimental condition of: individual, score/reputation feedback 
##   only (top 20 leaderboard), rating "tips" from unidentified other forecasters.  
##   Not sure if other important aspects of experimental condition.  
##
##   Upshot: this code is only useful to a subset of 2014/15 GJP forecasters, and 
##   only if they saved an html copy of their dashboard and can get an RTF copy
##   of question page.
##
##   Arguments:   
##        dashFile: 
##             default="scorepage.html"
##             Name of html file containing source code for the dashboard page (site is 
##             no longer live, need to have saved source before went down.)
##        questFile: 
##             default="questions.rtf"
##             RTF file containing contents of the "Question" page from
##             forecasting site.  File used here was converted from PDF copy
##             of the page. (Regrettably, did not save page source.) 
##        outFile:
##             default="qGJPdt.csv"
##             Name of the .csv file where the data frame will be stored. Defaults
##             to working directory.
##             
##
##
##   Output:
##        Saves to .csv file and
##        returns data table of leaderboard scores and question categories
##             Row for each question number
##             Columns are:
##                  QuestionNumber:  Character, integer identifier of question  
##                  QuestionName:  Character,  of text identifying question
##                  DateClosed:    Character, date the question closed, mm/dd/yy
##                  Forecasts:     int, Number of forecasts on question made by this forecaster
##                  BrierScore:   numeric, Brier score on this question for this forecaster
##                  GroupScore:   numeric, Group brier score on this question
##                  Columns (25) for each question category (eg: "International Relations")
##                       logical, indicate which categories the question fits
##                  Diff:          numeric, Group score - Brier Score 
##                  Direction:     numeric, sign of Diff 
##                  runBrier:      numeric, Brier score through close date of that question
##                  runGroup:      numeric, Group Brier score through close date
##
##   Usage:
##        >out <- processGJPDashboard("scorepage.html","questions.rtf","out.csv")
##
##        (Where "scorepage.html" and "questions.rtf" are appropriate files 
##         located in the working directory or at location given.)
##
##   26-Aug-2015    K. Morrell
##

processGJPDashboard <- function(dashFile="scorepage.html", questFile="questions.rtf",
                                outFile="qGJPdt.csv") {
     library(XML)
     library(data.table)
     library(dplyr)
     
     ##   Read the dashboard file in
     html <- htmlTreeParse(dashFile, useInternalNodes=T)
     
     ##   This returns all the tables in the document
     t <- getNodeSet(html,"//table")
     
     ##  sort the question scores into a data frame
     
     qdf <- parseQuestionInfo( t )
     
     ##   Now the question file - could be another separate function
     
     qcatdf <- parseCategories( questFile )
     
     ##  Still have issue of different number of categories for each question.
     ##  But, can separate them on spaces, and resolve later.
     
     ##  Do an inner join of the two data frames - may as well change to datatable -
     ##  and return the result.  Keeps the rows in qdt that have values in qcatdt,
     ##  don't need to specify "by" because will use "Question Number"
     
     qdt <- data.table(qdf)
     qcatdt <- data.table(qcatdf)
     qGJPdt <- inner_join(qdt, qcatdt, by = "QuestionNumber")
     
     ##   This is not actually a tidy data set yet, because there are many question 
     ##   categories and varying numbers of them appear in a single column.  
     ##   One way to tidy would be to create columns for each of the categories,
     ##   then mark whether that question number had a value in that category.
     ##   That (wide format) makes sense to me.  Other columns seem tidy enough
     
     ##  In order to do this, need to extract all the unique category names. 
     ##  If just use unique() as is, will take every entry...
     ##  Need to read all the question categories into a list, broken at every space    
     ##
     qcatNames <- unique( unlist( strsplit( qGJPdt$QuestionCategories, " ")))
     
     ##   Get rid of empty string if one occurs and alphabetize
     qcatNames <- sort( qcatNames[ which( nchar(qcatNames)>0) ] )
     
     ##   Create a new table with column names for question number and all of the
     ##   category names.
     ##   Or, add columns to
         
     ##  Could give up on doing neatly..
     qcat_bin = qGJPdt$QuestionNumber
     for (i in 1:length(qcatNames)){
          qcat_bin <- cbind(qcat_bin, grepl(qcatNames[i], qGJPdt$QuestionCategories))
     }
     qcat_bin_dt <- data.table(qcat_bin)
     setnames(qcat_bin_dt, old=names(qcat_bin_dt)[1], new="QuestionNumber")
     
     ##   Hyphens cause warnings - check for other undesirable characters
     qcatNames <- gsub("-",".", qcatNames, fixed=TRUE)
     
     ##   Use setnames format
     setnames(qcat_bin_dt, 2:length(names(qcat_bin_dt)), qcatNames)
     
     qGJPdt <- inner_join(qGJPdt, qcat_bin_dt, by = "QuestionNumber")

     ## Now drop the Question Categories column, add a Difference column
     ## and a direction column
     qGJPdt <- select(qGJPdt, -ends_with("Categories"))
     qGJPdt <- mutate(qGJPdt, Diff=GroupScore-BrierScore, Direction=sign(Diff))

     ##   Could also arrange these all by date closed, then compute a running
     ##   Brier score by date  
     ##
     qGJPdt <- arrange(qGJPdt, as.Date(DateClosed,"%m/%d/%Y"))
     
     ##  This does correctly sort it...do a running Brier score
     ##  Obviously a for loop will do it, could neaten
     runBrier=0
     runGroup=0
     for (n in 1:length(qGJPdt$QuestionNumber)){
          runBrier[n] <- round(mean(qGJPdt$BrierScore[1:n]), digits=3)
          runGroup[n] <- round(mean(qGJPdt$GroupScore[1:n]), digits=3)       
     }
     qGJPdt <- data.table(qGJPdt, runBrier, runGroup)
     
     ## Write to .csv file for later use
     write.csv( qGJPdt, outFile)
     
     return(qGJPdt)
}
##   Function to sort out the dashboard question information
##   into a data frame
##   Arguments:
##        table_nodes:  list, XMLNodeSet
##
##   Output:
##        quest_df:      dataframe, contains: question number, question name,
##                       date closed, number of forecasts made, brier score, 
##                       and group brier score.
##
parseQuestionInfo <- function ( table_nodes ){
     ##   Read in the table that gives score information by question number.
     ##
     ##   The table of scores by question is the one before the last table,
     ##   for my scorepage anyway.
     
     col_names <- sapply(table_nodes[[length(table_nodes)-1]][["tr"]]["td"], xmlValue)
     
     vals = sapply(table_nodes[[length(table_nodes)-1]]["tr"],  
                   function(x) sapply(x["td"], xmlValue))
     
     ##   9/6/2015 Found a difference in scorepage html from another forecaster
     ##   probably because sorted by something other than question number.
     ##   "thead" and "tbody" was used in that case, but not in the unsorted case
     
     if ( !( length(col_names)>0 ) ){
          col_names <- sapply(table_nodes[[length(table_nodes)-1]][["thead"]][["tr"]]["td"],
                              xmlValue)
          vals = sapply(table_nodes[[length(table_nodes)-1]][["tbody"]]["tr"],  
                        function(x) sapply(x["td"], xmlValue))
     }
     else {
          ## vals in this case will include the column names, drop those
          vals <- vals[,2:length(vals[1,])]
     }
     rows <- length(vals[1,])
     
     
     ##   create a dataframe with the column names
     ## and values...hardcoding some things here...this could be cleaned up
     
     qn <- vals[1,]          
     qnum <- substr(qn, 1, 4)
     qname <- substr(qn, 6, nchar(qn))
     qdate <- vals[2,]
     qfcasts <- vals[3,]
     qscore <- vals[4,]
     qg_score <- vals[5,]
     
     quest_df <- data.frame(qnum, qname, qdate, qfcasts, qscore, qg_score, stringsAsFactors = F)
     colnames(quest_df) <- c("QuestionNumber","QuestionName","DateClosed","Forecasts",
                             "BrierScore","GroupScore")
     quest_df$Forecasts <- as.numeric(quest_df$Forecasts)
     quest_df$BrierScore <- as.numeric(quest_df$BrierScore)
     quest_df$GroupScore <- as.numeric(quest_df$GroupScore)
     
     return(quest_df)
     
}

##   Function to get the category information from an rtf file containing the
##   text from the page of questions.  Category here refers to the labels given
##   to the individual questions in the forecaster interface, not to the larger
##   groupings/bundles which GJP determined.  
##
##   Arguments:
##        questionFile:  path and name of rtf file
##
##   Output:
##        qcat_df:  dataframe of the category information.  Contains question 
##                  number and character string of question categories for each
##                  question number.
##
##   Note:  This works for the rtf file that I have, but not confident that will
##             work for others.
parseCategories <- function (questionFile){
     ##   Now, for reading in information from rtf file:
     ##   modify the solution provided on Stack Overflow
     ##   at http://stackoverflow.com/questions/23634298/parsing-rtf-files-into-r
     ##   by G. Grothendieck
     rtfLines <- readLines(questionFile)
     
     ## This pattern marks the question categorization
     format_pattern <- "\\\\fs12 \\\\cf10 \\\\up0"
     
     g <- grep(format_pattern, rtfLines, value=TRUE)
     noq <- gsub("\\\\'", "'", g)
     g_1 <- sub("\\\\.*", "", sub(format_pattern, "", noq))
     ##  This ends up with clean lists of question categories in g_1, but
     ##  still need to associate question number and also there is the issue
     ##   that the categories will not separate cleanly - may need to go through the 
     ##   RTF file and put in underlines in place of spaces - or perhaps add commas
     
     ##   Limited number of multi-word categories - could try to do with sub
     g_2 <- gsub("International ", "International_", g_1)
     g_2 <- gsub("Domestic ","Domestic_", g_2)
     g_2 <- gsub("Diplomatic ", "Diplomatic_", g_2)
     g_2 <- gsub("Economic ", "Economic_", g_2)
     g_2 <- gsub("Leader ", "Leader_", g_2)
     g_2 <- gsub("Public ", "Public_", g_2)
     
     ## Now - pull out the associated question numbers
     ## pattern is 4 numbers enclosed in # and :
     format_2 = "#[0-9]+:"
     q <- grep( format_2, rtfLines, value=TRUE)
     noq <- gsub("\\\\","",q)
     ##  This drops the initial formatting code
     a <- unlist( strsplit( noq,"#"))[seq(2, 2*length(noq), by=2)]
     
     ##   Now separate from the question text
     q_num <- unlist( strsplit(a,":"))[seq(1, 2*length(a), by=2)]
     
     ## Create a new dataframe that has these question numbers and categories
     qcat_df <- data.frame( q_num, g_2, stringsAsFactors=FALSE)
     colnames(qcat_df) <- c("QuestionNumber","QuestionCategories")
     
     return(qcat_df)
}



