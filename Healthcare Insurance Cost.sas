FILENAME REFFILE '/folders/myfolders/Project 1/P1_Dataset1F(1).XLSX';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=TotalCost;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=TotalCost; RUN;

PROC MEANS DATA=TotalCost NMISS N; RUN;

title "Summary Statistics for Cost";
PROC MEANS DATA=TotalCost;
VAR Cost;
RUN;

** boxplots, qqplots, histograms by proc univariate **;
PROC UNIVARIATE DATA=TotalCost Normal Plot;
	Var Cost;
	qqplot Cost;
	histogram Cost / normal;
RUN;

title "Summary Statistics for Each Explanatory Variable";
PROC MEANS DATA=TotalCost (DROP=ID Cost) ;
RUN;

PROC MEANS DATA=TotalCost (DROP=ID Cost) SUM;
RUN;

** boxplots, qqplots, histograms by proc univariate **;
PROC UNIVARIATE DATA=TotalCost Normal Plot;
	Var Age Gender Drugs Emergency Comorbidities Duration;
	qqplot Age Gender Drugs Emergency Comorbidities Duration;
	histogram Age Gender Drugs Emergency Comorbidities Duration / normal;
RUN;


/* Full Model with All Variables */
PROC REG DATA=TotalCost;
MODEL Cost = Age Gender Drugs Emergency Comorbidities Duration / dwprob clb corrb tol vif collin;
OUTPUT OUT = result1 residual = residual;
TITLE 'Full Model';
RUN;

PROC UNIVARIATE DATA=result1 NORMAL PLOT;
VAR residual;
RUN;

/* Transformation on Y required.  Use Box-Cox Transformation. */
/* Note: Box-Cox only works for independent variable(s) */
PROC TRANSREG DATA=TotalCost DETAIL;
MODEL BOXCOX(Cost / convenient lambda = -3 to 3 by 0.1)
	= identity(Age Gender Drugs Emergency Comorbidities Duration);
TITLE 'Boxcox Transformation';
RUN;

/* Perform a transformation on Y */
DATA Logy;
SET TotalCost;
logCost = log(Cost);
RUN;

/* Full Model with All Variables After Transformation */
PROC REG DATA=Logy;
MODEL logCost = Age Gender Drugs Emergency Comorbidities Duration /dwprob clb corrb tol vif collin;
OUTPUT OUT = result2 residual = residual;
TITLE 'Full Model After Transformation';
RUN;

PROC UNIVARIATE DATA=result2 NORMAL PLOT;
VAR residual;
RUN;

/* Run FORWARD Selection on Model - with logy */
PROC REG DATA=Logy;
MODEL logCost = Age Gender Drugs Emergency Comorbidities Duration
	/ selection = forward clb corrb tol vif collin CP SLENTRY = 0.10;
TITLE 'FORWARD SELECTION';
OUTPUT OUT = result5 residual = residual;
RUN;
	
PROC UNIVARIATE NORMAL PLOT DATA = result5;
	VAR residual;
RUN;