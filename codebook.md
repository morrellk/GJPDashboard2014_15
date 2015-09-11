#CodeBook:  <small>Data from 2014-15 GJP forecaster dashboard</small>
*************
This codebook documents the code in processGJPDashboard.R and GJP_category.R 
and the variables stored in the output files from those functions.

### Data 
The function _processGJPDashboard()_ reads in data on user performance from an html
copy of the user dashboard.   

### Data Processing
* User data from the table of results by question is placed in a data frame.  
* Information on the categorization of questions is read from an rtf copy of the
questions page and added into the data frame
* Categories are separated into individual variables in the data table, true/false
for each question
* CSV file containing question information and results is output.
* Mean scores calculated by category 
* Category results placed in data table and output to CSV file.

### Output
* Output for _processGJPDashboard()_ is a CSV file, default = "qGJPdt.csv", which contains the information from the question table on the dashboard as well as question categories.

* Output for _getCategoryScores()_ (in GJP_category.R) is a CSV file, default =
"cat_df.csv", containing question categories and information on how the forecaster
did by category.



### Variables in output files/data tables
__qGJPdt.csv__

1. Index (No column name)
     + Integer as a character string

2. QuestionNumber
     + Identifying number for the IFP assigned by GJP
     + Integer character string

3. QuestionName
     + Short descriptive question name 
     + Character string

4. DateClosed
     + Date on which the question closed
     + Format as mm/dd/yy
     + Character string

5. Forecasts
     + Number of forecasts made by this participant
     + Integer

6. BrierScore
     + Brier score achieved on the question by this participant
     + Floating point number

7. GroupScore
     + Brier score on the question for the group of forecasters
     + Floating point number

8. Africa.North
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

9. Africa.Sub.Saharan
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

10. America.Central/South
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

11. America.North
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

12. Arctic
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

13. Asia.Central/South
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

14. Asia.East/Southeast
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

15. Commodities
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

16. Currencies
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

17. Diplomatic_Relations
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

18. Domestic_Conflict
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

19. Economic_Growth/Policy
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

20. Elections
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

21. Europe.Eastern
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

22. Europe.Western
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

23. International_Organizations
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

24. International_Security/Conflict
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

25. Leader_Entry/Exit
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

26. Middle.East
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

27. Oceania
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

28. Public_Health
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

29. Resources/Environment
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

30. Trade
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

31. Treaties/Agreements
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

32. Weapons
     + One of the categories assigned to questions
     + Character, TRUE/FALSE
          - TRUE - question is in this category
          - FALSE - question is not in this category 

33. Diff
     + Performance difference between participant and group
     + Diff = Group - Brier
          - larger value indicates better participant performance relative to group
     + Floating point number

34. Direction
     + Whether the forecaster did better or worse than the group
     + Sign(Diff)
	+ Integer [-1:1]
	     + 1: Forecaster did better
	     + 0: Equal scores
	     + -1: Group did better

35. runBrier
     + Forecaster overall Brier score at date question closed
     + Floating point number

36. runGroup
     + Group overall Brier score at date question closed
     + Floating point number

__cat_df.csv__

1. Category Number (no column name)     
	+ Character string for integer 1:25
	+ Categories ordered by forecaster performance relative to group, better to
     worse.

2. Category	
	+ Name of the category, from text used on question page with substitution for
     some problematic characters.
	+ Character
     
3. N	
	+ Number of questions which had this category label   
     + If dropNA == TRUE, then this will only be questions where a forecast was
     entered by this forecaster.  If dropNA == FALSE, all questions are used.
	+ Integer

4. Brier	
	+ Mean forecaster Brier score for questions with this category label 
     + If dropNA == TRUE, then this will only be calculated using questions with a 
     forecast entered by this forecaster.  If dropNA == FALSE, all questions are used.
	+ Floating point number, rounded to three digits after decimal
     
5. Group
	+ Mean group Brier score for questions with this category label
     + If dropNA == TRUE, then this will only be calculated using questions with a 
     forecast entered by this forecaster.  If dropNA == FALSE, all questions are used.
	+ Floating point number, rounded to three digits after decimal

6. Diff
	+ Difference between group and forecaster Brier scores. 
     + Group - Brier
	+ Floating point number, rounded to three digits after decimal

7. Better
	+ Whether the forecaster did better or worse than the group
     + Sign(Diff)
	+ Integer [-1:1]
	     + 1: Forecaster did better
	     + 0: Equal scores
	     + -1: Group did better


