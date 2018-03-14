WITH magic_ AS (
   SELECT 300000 mortgage_sum
      , 1200 installment , 2.6 int_pct 
   FROM dual
), months_of_year_ AS (
   SELECT ROWNUM AS month 
   FROM dual 
   CONNECT BY LEVEL <= 12
), mortgage_years_ AS (
   SELECT 2013+ROWNUM AS year 
   FROM dual 
   CONNECT BY LEVEL <= 20 /* magic number for years*/ 
)
SELECT *
FROM (
SELECT 
      month_seq
    , year
    , month
    , int_pct
    , special_payoff
    , installment
    , ROUND(int_amt, 0)  int_amt
    , ROUND(payoff, 0)  payoff
    , ROUND(mortgage_rest, 0) mortgage_rest
FROM       months_of_year_ mo
CROSS JOIN mortgage_years_ yr 
CROSS JOIN magic_ m
MODEL 
   DIMENSION BY (   
      ROW_NUMBER () OVER ( ORDER BY year, month) month_seq 
   )  
   MEASURES ( year, month -- year and month are not constant, hence must be declared as measures! even though we do not plan to reference them in RULES   
   -- well, indirectly we do reference year and month via column month_seq which is based on year and month. 
   -- month_seq in turn is referenced indirectly via the CV() function 
   , installment
   , int_pct
   ,  -1 payoff   
   , mortgage_sum   
   , mortgage_sum as mortgage_rest     
   , -1 as int_amt   
   , 0 as special_payoff   
   ) 
   RULES /* formulas you would put in an spreadsheet */ AUTOMATIC ORDER (     
      int_amt[ month_seq = 1] = mortgage_sum[ CV() ]  * int_pct[CV()]/100/12  
   , int_amt[ month_seq > 1] = mortgage_rest[ CV()-1] * int_pct[CV()]/100/12
   --
   , payoff[ month_seq = 1]=  installment[CV()] - int_amt [ CV() ]
   , payoff[ month_seq > 1]=  installment[CV()] - int_amt [ CV() ] 
   --
   , mortgage_rest[ month_seq = 1] =  mortgage_sum[ CV() ] 
   , mortgage_rest[ month_seq > 1] =  mortgage_rest[ CV() - 1] - payoff [ CV() ]
   - special_payoff [ CV() ]
   --
   -- interest rate and installments after the fix interest period
   -- 
   , int_pct [ month_seq > 10*12]=  5 /* assumed interest rate of N % after fix interest period  */
   , installment [ month_seq > 10*12]= 1000 /* assumed installment after 10 years */
   --
   -- include special payoff done once per year
   -- 
      , special_payoff [ mod(month_seq ,12) = 0 and month_seq < 120 ]=  15000    
   ) -- end rules 
)
WHERE 1=1   
   AND MORTGAGE_REST > 0
ORDER BY month_seq ASC
;