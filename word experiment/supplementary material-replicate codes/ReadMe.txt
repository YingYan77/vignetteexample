## ReadMe for replication materials:
## Moderator Placement in Survey Experiments: 
## Racial Resentment and the “Welfare” vs. 
## “Assistance to the Poor” Question Wording Experiment
##
## Bethany Albertson and Stephen Jessee
##
## Journal of Experimental Political Science

The following files are required to produce the article's results:

"raw_data.dta" - the survey experimental data analyzed in the article (this data file is used by "moderator-analysis.R", the file "survey codebook.docx" contains more information about the variables included in the dataset.)

"moderator-analysis.R" - the main code conducting the analysis and producing results

"permutation ks test function.R" - a code file containing a function written to perform permutation-based KS tests (this code file is used by "moderator-analysis.R")

Note that you should be sure when running the code in "moderator-analysis.R" that R's working directory is the directory containing all of the above files.

Running this code will produce output in the R console and also will produce some separate files for figures ("FigA1.pdf" and "FigA2.pdf") and also nicely formatted versions of the main paper's tables (at least more nicely formatted than R's default output...) called "Table1.txt", "Table2.txt" and "Table3.txt". 

We have also included the file "all-output.txt" which includes all of the output from the R console when running the code in the file "moderator-analysis.R". Appendix table results can be found this output file since they are generally formatted in a nonstandard way that would not be as straightforward to output.

Any questions or comments on these replication materials can be sent to Stephen Jessee at sjessee@utexas.edu.