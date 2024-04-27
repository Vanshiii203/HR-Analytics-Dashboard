create database f_project;
use f_project;
select * from hr;
-- data cleaning -- 
alter table hr rename column ï»¿id to emp_id;
desc hr;
select birthdate from hr;
update hr 
set birthdate= case
	when birthdate like'%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like'%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
	else null
end;
alter table hr modify column birthdate date;
-- hire_date data type and format change
update hr
set hire_date=case
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
	else NULL
end;
alter table hr modify column hire_date date;
-- termdate data type and format change
update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate !='';
update hr 
set termdate= null where termdate='';
alter table hr modify column termdate date;

-- create age column
alter table hr add column age int;

update hr
set age = timestampdiff(year,birthdate,curdate());
select min(age),max(age) from hr;

-- what is the gender breakdown of employees in the company?
select gender,count(*) as count from hr where termdate is null group by gender;

-- what is the race breakdown of employees in company?
select race, count(*) as count from hr where termdate is null group by race;

-- what is age distribution of employee in comapny?
select case 
	when age>=18 and age<=24 then '18-24'
	when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group, count(*) as count 
    from hr where termdate is null group by age_group order by age_group;
-- how many work at headquarter vs how many at remote?
select location,count(*) as count from hr where termdate is null group by location;

-- what is the average length of employment for employees who have been terminated
SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- how does the gender distributon vary across department and job titles?
select department,jobtitle,gender,count(*)as count from hr where termdate is  null group by department,jobtitle,gender order by department,jobtitle,gender;
select department,gender,count(*)as count from hr where termdate is null group by department,gender order by department,gender;

-- what is distribution of job title across compamy?
select jobtitle,count(*) as count from hr where termdate is null group by jobtitle;

-- Which dept has the higher turnover/termination rate
SELECT department,
		COUNT(*) AS total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
                    END)/COUNT(*))*100,2) AS termination_rate
		FROM hr
        GROUP BY department
        ORDER BY termination_rate DESC;
        
-- 9. What is the distribution of employees across location_state
select location_state,count(*)as count from hr where termdate is null group by location_state;  

-- 10. How has the companys employee count changed over time based on hire and termination date.
SELECT year,
		hires,
        terminations,
        hires-terminations AS net_change,
        ((Hires - Terminations) / Terminations) * 100 AS change_percent
	FROM(
			SELECT YEAR(hire_date) AS year,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hr
            GROUP BY YEAR(hire_date)) AS subquery
GROUP BY year
ORDER BY year;

-- What is the tenure distribution for each dept
select department, round(avg(datediff(termdate,hire_date)/365),0)as avg_tenure from hr where termdate is not null and termdate<curdate() group by department;

select department,count(*) as count from hr where termdate is null group by department order by department;

-- termination rate by gender
select race,total_hire,total_termination,round((total_termination/total_hire)*100,2)as termination_rate
from
	(select race, count(*) as total_hire,
	count(case when termdate is not null and termdate<=curdate() then 1
	end)as total_termination from hr group by race)as subquery
group by race;