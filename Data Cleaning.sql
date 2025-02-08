-- Project SQL data cleaning -- 

select *
from layoffs;

-- Step 1 : Remove Duplicates
-- Step 2 : Standardize data (spelling mistakes, upper/lower case)
-- Step 3: NUll values or Blank values 
-- Step 4 : Remove coloumns or row that aren't necessary 

create table layoff_staging  -- creating another table to clean the data first in the staging database a lot if we make a mistake there will be no worries as it is in the staging database 
like layoffs; 
	
select *
from layoff_staging;

insert layoff_staging
select * 
from layoffs;


-- Remove Duplicates
-- 1: Use windows funtion as row_num the number 2 are the dupilcates over(partition by)
-- 2: use cte  as row_number > 1; with naming cte () after this call the naming cte
-- 3:  

with duplicate_cte as 
(
select *, 
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date',
 stage, country) as row_num
from layoff_staging
)
select *
from duplicate_cte
where row_num > 1;

select *  -- checking which companies row have dulpicates 
from layoff_staging
where company = 'Casper';

-- deleting row = 2 

with duplicate_cte as 
(
select *, 
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date',
 stage, country) as row_num
from layoff_staging
)
delete
from duplicate_cte
where row_num > 1;


CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoff_staging2
where row_num > 1;

insert into layoff_staging2
select *, 
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date',
 stage, country) as row_num
from layoff_staging;

DELETE
from layoff_staging2
where row_num > 1;

select *
from layoff_staging2;


--  Standerdizing DATA 

-- Distinct takes out the unique row we need
-- Trim removes the unwanted white spaces on the end from a coloum 

select company, trim(company) as Companies 
from layoff_staging2;

update layoff_staging2
set company = trim(company);

select *
from layoff_staging2
where industry like 'Crypto%';  -- % means similar to the word 
	
update layoff_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select distinct industry
from layoff_staging2
order by 1;


select *
from  layoff_staging2
where country like 'United States%';

-- Lets say in the country coloums one of the rows out of many has a small unwanted . at the end of united states. 
-- HOW DO WE REMOVE IT ? 

select distinct country, trim(trailing '.' from country) -- trailing helps to remove object at the end of the word 
from layoff_staging2									 -- the '.' specifies that there is a . after the word it does not remove white 	space 
order by 1;

update layoff_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- Converting a string into a date
select `date`
						-- this is the date format the string_to_Date converts from string to date format 
from  layoff_staging2;

update layoff_staging2
set `date`= str_to_date(`date`, '%m/%d/%Y'); 

-- changing the data type of the date table 
alter table layoff_staging2
modify column `date` Date;

select *
from layoff_staging2;


 -- Step 3: NUll values or Blank values 
 
-- we check something specific by here we want to check where are the null values in the table

select * 
from layoff_staging2 
where total_laid_off is null; -- In my table they arent any null values rather blank values 

update layoff_staging2
set industry = null
where industry = TRIM(industry) = '';

select *
from layoff_staging2
where industry is null 
	 OR TRIM(industry) = '';
     
select *
from layoff_staging2
where company = 'Airbnb';


select *
from layoff_staging2 as t1 
join layoff_staging2 as t2 
	on t1.company = t2.company
where (t1.industry is null or  t1.industry = '')
and t2.industry is not null;

update 	layoff_staging2 as t1 
join layoff_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or  t1.industry = '')
and t2.industry is not null;


select *
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;
    
select *
from layoff_staging2;

alter table layoff_staging2 -- deleting a column 
drop column row_num;





