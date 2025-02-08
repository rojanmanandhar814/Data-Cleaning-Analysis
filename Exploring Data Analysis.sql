-- Exploratory Data Analysis -- 

select *
from layoff_staging2;

-- Made the blank value of percentage_laid_off column into null
UPDATE layoff_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

-- checking the max laid off from the table
select max(total_laid_off), max(percentage_laid_off)
from layoff_staging2;

-- checking who had 1.0% laid off 
select *
from layoff_staging2
where percentage_laid_off = 1.0;

-- checking which company has the largest laid off--
select *
from layoff_staging2
where percentage_laid_off = 1.0
order by total_laid_off desc;

-- checking its sum for company, location column and group by of total_laid_off
select company, location, sum(total_laid_off)
from layoff_staging2
group by company, location
order by 2 desc; 

-- checking who has the highest fund raising 

select company, funds_raised
from layoff_staging2
group by company, funds_raised
order by 2 desc;

-- checking min and max date range between layoff to check when was the layoff made 

select min(`date`), max(`date`)
from layoff_staging2;

-- checking what industry got hit the most during layoffs
select company, industry, country, location, avg(total_laid_off)
from layoff_staging2
group by company, industry, country, location
order by 2 desc; 

-- checking to see what year had the highest layoffs
select company, industry, stage, country, location, year(`date`), sum(total_laid_off)
from layoff_staging2
group by company, industry, stage, country, location, year(`date`)
order by 1 desc;

select*
from layoff_staging2;

-- checking out the month using substring on date 6 is the 6th index and 2 is number of decimal to choose 
select substring(`date`, 1,7) as Month, sum(total_laid_off)
from layoff_staging2
group by Month;


-- using cte funtion--

with rolling_total as 
(
select substring(`date`, 1,7) as `Month`, sum(total_laid_off)
from layoff_staging2
where substring(`date`, 1,7) is not null
group by `Month`
order by 1 asc
)
select `Month`, total_off
,sum(total_off) over(order by `Month`) as rolling_total
from rolling_total;

select*
from layoff_staging2;

-- checking compnies, their layoff year and total_laid_off in sum 
select company, year(`date`), sum(total_laid_off)
from layoff_staging2
group by company, year(`date`)
order by 3 desc;

-- using cte calling funtion "Common Table Expression"
-- we created the company by the year in how many ppl they laid of 

-- by the company year we created our 1st CTE company_year 

with company_year (company, years, total_laid_off) as 
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging2
group by company, year(`date`)
), Company_Year_Rank as  -- this is another cte for the ranking column 
(select *,
dense_rank() over (partition by years order by total_laid_off desc) as Ranking 
from company_year -- we have to call the cte funtion at the end of the statement
)
select *
from Company_Year_Rank
where Ranking <=5;


 
-- Now we want to partition it using windows funtion as we want to rank it based on the number of laid off and year as well 










