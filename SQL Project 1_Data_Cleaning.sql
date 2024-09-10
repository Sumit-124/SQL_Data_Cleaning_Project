--DATA CLEANING PROJECT

--STEPS WE NEED TO DO:
--1. Remove Duplicates
--2. Standardized the data
--3. Null values or blank values
--4. Removing any columns or rows


--We are making new table structure using existing table.
select *
into layoffs_staging
from layoffs$
where 0 = 1

select *
from layoffs_staging


--We are inserting the rows from layoffs$ into layoffs_staging table
insert layoffs_staging
select *
from layoffs$

select *
from layoffs_staging
--NOW WE WILL USE Layoffs_staging table for data cleaning and at the end compare it with the raw data of layoffs$ table.


--1. REMOVING OF DUPLICATES:

--ROW_NUMBER() actually assigns unique no. to each row.
select *,
ROW_NUMBER() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, 'date',country,funds_raised_millions
order by company asc) as row_num
from layoffs_staging


--CREATE CTE:
--This CTE_Duplicates is table that contains duplicates that are needed to be removed.
with CTE_Duplicates as 
(
select *,
ROW_NUMBER() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, 'date',country,funds_raised_millions
order by company asc) as row_num
from layoffs_staging
)

--delete
--from CTE_Duplicates
--where row_num > 1

select *
from CTE_Duplicates;

--**IN SQL SERVER:-
--**IF WE DELETE THE DUPLICATES FROM CTE TABLE THEN THOSE DUPLiCATES WILL ALSO GET REMOVED/DELETED FROM THE ACTUAL TABLE**
--*THIS DOESNOT HAPPENS IN MYSQL

---2. STANDARDIZING DATA
--means finding issues in the data and fixing it.

select count(company) as num_of_companies, count(distinct(company)) as distinct_num_of_companies
from layoffs_staging

select company, trim(company)
from layoffs_staging

UPDATE layoffs_staging    --here we are updating layoffs_staging table by replacing company column with trim(company) column
SET company = TRIM(company)

select distinct(industry)
from layoffs_staging
order by 1;

select *
from layoffs_staging
where industry like 'crypto%'


update layoffs_staging        --yha pe hum table of update kar rhe, jaha pe bhi 
set industry = 'crypto'       --industry ka name 'crypto%' hoga usko 'crypto' se replace krdo.
where industry like 'crypto%'

select *
from layoffs_staging
where country like 'United States.%'

update layoffs_staging
set country = 'United States'
where country = 'United States.'

--3. REMOVE NULL AND BLANK COLUMNS

select *
from layoffs_staging
where industry is null --or industry = ''

select *
from layoffs_staging
where company = 'Juul'

update layoffs_staging
set industry='Travel'
where company = 'Airbnb'


--VERY VERY IMPORTANT QUERY
select t1.industry, t2.industry
from layoffs_staging  as t1
join layoffs_staging as t2
	on t1.company = t2.company 
	and t1.location = t2.location
where (t1.industry is null)  and (t2.industry is not null)


--update layoffs_staging
--select t1.industry, t2.industry
--update(select layoffs_staging  as t1
--join layoffs_staging as t2
--	on t1.company = t2.company 
--	and t1.location = t2.location
--set t1.industry = t2.industry
--where (t1.industry is null)  and (t2.industry is not null)
--IT IS STILL SHOWING AN ERROR. WHY?>>BECAUSE WE NEED TO REPLACE '' BY NULL IN INDUSTRY COLUMN.
UPDATE layoffs_staging
SET industry = Null
where industry = ''


update layoffs_staging
set industry='Transportation'
where company='Carvana'

update layoffs_staging
set industry = 'Consumer'
where company = 'Juul'


select *
from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null

delete      ---this query will delete all those data where total laid off and percentage laid off are simultaneously null
from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null

select *
from layoffs_staging


--4.REMOVING ANY COLUMNS AND ROWS:
--HOW TO DROP/DELETE A COLUMN FROM THE TABLE?
-- for eg. there is column name: row_num and we need to delete it then write a query to execute it
--ALTER TABLE layoffs_staging
--DROP COLUMN row_num