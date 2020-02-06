*Question 1;
DATA birthday;
MyBirthDate ='18jan1998'd;
	put MyBirthDate=;
	
today = TODAY();* the today() function returns today’s date;
	put today=;
days = today - MyBirthDate;
	put days=;
age = (days/365);
	format age 9.1;
	put age=;
FILE PRINT;
PUT "I was born on" MyBirthDate worddate18.". " "I am " age "years old.";
/*if I use worddate.(13-17), I get "Jan" with/without extra spaces before,
but if I use worddate.18, I finally get "January" but am stuck with an extra space too!
I'm not sure how to get exactly "January" without the extra spaces. Is there another format I should use?*/
PROC PRINT;
RUN;
      
*Question 2;
*Have SAS output any observations where the e-mail variable does not contain an “@” to a dataset named Error,
and output all the other observations to a dataset named GradStudents;
*WHERE expression enables you to conditionally select a subset of observations, so that SAS processes only the observations that meet a set of specified conditions;
DATA GradStudents(where=(email ? '@')) Error(where=(email NOT ? '@'));

*Making sure variables are long enough so no truncation occurs;
LENGTH email $ 50 name $ 50 program $ 50 supervisor $ 100 area $ 50;

*Specifying delimiter as < because that's what separates the lines of text in our file;
INFILE '/folders/myfolders/STAT466/Assignment 1/GradStudentsWebPage.html' DLM='"<(' ;

*Finding & reading the lines we want;
INPUT @'<h3><a href="mailto:' email @'>' name @'Program:</strong> ' program @'Supervisor(s):</strong> ' supervisor @'Area:</strong> ' area;

*Changing name and supervisor variables from all uppercase to proper mixed case;
name = PROPCASE(name);
supervisor = PROPCASE(supervisor);

/*replace the string “&amp;” with a single ampersand “&”,;*/
*TRANWRD specifies a character constant, variable, or expression that you want to translate
*TRANWRD(source, target, replacement);
supervisor = TRANWRD(supervisor, '&amp', '&');
area = TRANWRD(area, '&amp', '&');

*make a variable named FirstName that contains only the first name of each student and
create a variable named LastName that contains only the last name of each student.;
*From SAS Support:
SCAN(string, count<,charlist <,modifiers>>)
	string specifies a character constant, variable,...
	count a nonzero # specifying # of the word- 1 indicates the first word
COUNTW(<string><, chars><, modifiers>)
	chars specifies character constant that initializes a list of characters;
FirstName = SCAN(name, 1, ' ');
LastName = SCAN(name, COUNTW(name), ' ');

RUN;

*Question #3;
*(a) i;
DATA _null_;
ProbChipsGtrThan1 = 1 - PROBBNML(0.2, 20, 0);
PUT ProbChipsGtrThan1=;
RUN;

*(a) ii;
DATA chips;
Chips = 0;
Prob = 1;

OUTPUT;
DO Chips=1 To 20;
Prob = 1 - PROBBNML(0.2, 20, Chips - 1);
OUTPUT;

END;
RUN;

*(b) i;
DATA _null_;
P25TrickorTreaters = 1 - poisson(20, 25);
put P25TrickorTreaters=;

RUN;

*(b) ii;
DATA _null_;
MinChocolate=quantile('poisson', 0.95, 20);
put MinChocolate=;

RUN;

*Question 4
*(a)  Write SAS code to read the data into a data set.;
DATA weather (drop =i);  /*This i is being dropped from part (c), but is 'out of order' if I leave it in (c)*/
INFILE "/folders/myfolders/STAT466/Assignment 1/weather.txt" /*MISSOVER*/;

LENGTH WHERE $23;
INPUT WHERE & JAN FEB MAR APR MAY JUN JUL AUG SEPT OCT NOV DEC;
REGION = substr(WHERE,1,1);
CITY = substr(WHERE,2,20);

*(b) Create a new variable named avg_temp which is the average annual temperature.
Label as ‘Average Annual Temperature’.;
avg_temp = SUM(JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEPT, OCT, NOV, DEC)/12; /*sum each col per city and ave their respective temps*/
LABEL avg_temp = "Average Annual Temperature";

*(c) Convert all the temperatures to Celsius using a DO loop with an ARRAY.; 
*Used SAS Support for conversion steps https://support.sas.com/resources/papers/proceedings16/6406-2016.pdf;

array temperature_array [13] JAN FEB MAR APR MAY JUN JUL AUG SEPT OCT NOV DEC avg_temp; /*each monthly temperature*/;
array celsius_array[13] celsius_temp1-celsius_temp13; /*collection of our new celcius conversions*/
do i = 1 to 13;
celsius_array{i} = (5/9)*(temperature_array{i} - 32); /*conversion F to C*/

end;

*(d) Create a user-defined format to display the region codes by their proper names, i.e. West, Prairie,
North, Ontario, Quebec, Atlantic. Have this format permanently assigned to the region variable.;
/*This is splitting up the first letter (W,P,O,A,Q) from the name of the actual city*/

PROC FORMAT;
VALUE $names W = 'West' P = 'Prairie' N= 'North' O= 'Ontario' Q= 'Quebec' A = 'Atlantic';
LABEL REGION = $names.;

*(e) Create another user-defined format for temperatures such that temperatures (in Celsius) below -20
are displayed as ‘Brutally Cold', temperatures between -20 and -10 are displayed as ‘Very Cold’,
temperatures between -10 and 0 are 'Cold', temperatures between 0 and 10 are displayed as 'Cool',
temperatures between 10 and 20 are displayed as 'Mild', temperatures between 20 and 30 are
displayed as ‘Warm’, and temperatures 30 and above are displayed as 'Hot'.;

PROC FORMAT;
VALUE celsius_temp low -< -20 = 'Brutally Cold' -20 -< -10 = 'Very Cold' -10 -<0='Cold' 0 -< 10 ='Cool' 10-<20='Mild' 20-<30='Warm' 30<-high ='Hot';

*(f) Print out the city names with their monthly and annual average temperatures. Display the
temperature ranges using your user defined format from part e. Make sure the label of avg_temp
is displayed in the printout rather than the variable name.;

Proc Print data= weather Label;

VAR REGION CITY celsius_temp1-celsius_temp13;

FORMAT celsius_temp1-celsius_temp13 temps. REGION $names.;

RUN;