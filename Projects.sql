-- Creating database
create database project;

-- Command that we are going to project in our query
use project;

-- To see the data
select * from hr;

-- To change the name of the first column
alter table hr
change column ï»¿id emp_id varchar(20) null;

-- To see the type of data
describe hr;

-- To see the birthdate and change it into date format
select birthdate from hr;

-- To remove the safety feature from sql so that we can make the changes in the database
set sql_safe_updates = 0;

-- Update the birthdate column
update hr
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d') else null
end;

select birthdate from hr;

alter table hr
modify column birthdate date;

-- Update the termdate column
select termdate from hr;

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

update hr 
set termdate = null
where termdate = '';

alter table hr 
modify column termdate date null;

update hr
set termdate = '9999-12-31'
where termdate is null;

alter table hr
modify column termdate date not null;

-- Create new column by the name of age
alter table hr add column age int;

-- To find the age
update hr
set age = timestampdiff(year, birthdate, curdate());

select age from hr;

-- To see the maximum and minimum age
select max(age) as max_age, min(age) as min_age from hr;

-- To see the number of people less then the age of 18
select count(*) as count from hr
where age < 18 and termdate = '9999-12-31';

-- What is the gender breakdown of employees in the company
select * from hr;

select gender, count(*) as count
from hr
where age >= 18 and termdate = '9999-12-31'
group by gender
order by count desc;

-- What is the race breakdown of employees in the company
select * from hr;

select race, count(*) as count
from hr
where age >= 18 and termdate = '9999-12-31'
group by race
order by count desc;

-- What is the age distribution of employees in the company
select * from hr;

select
  case
    when age >= 18 and age <= 24 then '18-24'
    when age >= 25 and age <= 34 then '25-34'
    when age >= 35 and age <= 44 then '35-44'
    when age >= 45 and age <= 54 then '45-54'
    when age >= 55 and age <= 64 then '55-64'
    else '65+'
    end as age_group,
    count(*) as count from hr
    where age >= 18 and termdate = '9999-12-31'
    group by age_group
    order by age_group;

-- How many employees work at the headquater vs at remote location
select * from hr;

select location, count(*) as count
from hr 
where age >= 18 and termdate = '9999-12-31'
group by location
order by count desc;

-- What is the average length of employment of the employees who have been terminated
select round(avg(datediff(termdate, hire_date))/365,2) as avg_length_employment
from  hr
where termdate <= curdate() and termdate <> '9999-12-31' and age >= 18;

-- How does gender distribution vary across departments and job titles
select * from hr;

select department, gender, count(*) as count
from hr
where age >= 18 and termdate = '9999-12-31'
group by department, gender
order by department;

-- What is the distribution of job titles across the company
select jobtitle, count(*) as count
from hr
where age >= 18 and termdate = '9999-12-31'
group by jobtitle
order by jobtitle desc;

-- Which department has the turnover rate
select department, 
  total_count, 
  terminated_count, 
  terminated_count/total_count as termination_rate
from(
select department,
count(*) as total_count,
sum(case when termdate <> '9999-12-31' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr 
where age >= 18 
group by department) as subquery
order by termination_rate desc;

-- What is the distribution of employees across locations by city and state
select * from hr;

select location_state, count(*) as count
from hr 
where termdate = '9999-12-31' and age >= 18
group by location_state;

-- How has the company employee count change over time based on hire and term dates
select * from hr;

select year, hire, terminations, (hire-terminations)/hire*100 as net_change_percent
from(
select year(hire_date) as year,
count(*) as hire,
sum(case when termdate <> '9999-12-31' and termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age >= 18
group by year(hire_date)) as subquery
order by year asc;

-- Change the format of hire_date
update hr
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d') else null
end;

alter table hr
modify column hire_date date;

-- What is the tenure distribution for each department
select * from hr;

select department, round(avg(datediff(termdate, hire_date)/365)) as avg_tenure
from hr
where termdate <> '9999-12-31' and termdate <= curdate() and age >= 18
group by department
order by department;



