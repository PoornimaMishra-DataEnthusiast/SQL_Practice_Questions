--Creating Employee table
CREATE TABLE Employee (
EmpID int NOT NULL,
EmpName Varchar,
Gender Char,
Salary int,
City Char(20) )
--Inserting Records in Employee table
INSERT INTO Employee
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura')

--Creating EmployeeDetails Table
CREATE TABLE EmployeeDetail (
EmpID int NOT NULL,
Project Varchar,
EmpPosition Char(20),
DOJ date )

--Inserting Records into Employee table
INSERT INTO EmployeeDetail
VALUES (1, 'P1', 'Executive', '26-01-2019'),
(2, 'P2', 'Executive', '04-05-2020'),
(3, 'P1', 'Lead', '21-10-2021'),
(4, 'P3', 'Manager', '29-11-2019'),
(5, 'P2', 'Manager', '01-08-2020')

--Viewing the data from both the tables
select * from employee
select * from employeedetail

--Q1(a): Find the list of employees whose salary ranges between 2L to 3L.
select * from employee 
where salary between 200000 and 300000

--Alternative way
select * from employee 
where salary > 200000 and salary <300000

--Q1(b): Write a query to retrieve the list of employees from the same city.
select E1.empname,E1.city from employee E1,employee E2
where E1.city=E2.city and E1.empid!=E2.empid

--Q1(c): Query to find the null values in the Employee table.
select * from employee
where empid is Null 

--Q2(a): Query to find the cumulative sum of employee’s salary.
select empname,salary,sum(salary) over(order by empid) as CumulativeSum from employee

--Q2(b): What’s the male and female employees ratio.
select 
round((count(*) filter (where gender='M')*100.0/count(*)),2) as MaleRatio,
round((count(*) filter (where gender='F')*100.0/count(*)),2) as FemaleRatio
from employee

--Q2(c): Write a query to fetch 50% records from the Employee table.
select * from employee
where empid <= (select count(*)/2 from employee)

--Alternative way
select * from
(select *,row_number() over (order by empid) as Rownumber
 from employee) as EMP
 where EMP.Rownumber<=(select count(*)/2 from employee)

--Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’ i.e 12345 will be 123XX
select salary,concat(substring(salary::text,1,length(salary::text)-2),'XX' )as masked_salary
from employee

--Alternative way
select salary ,concat(left(cast(salary as text),length(cast(salary as text))-2),'XX') as masked_salary
from employee

--Q4: Write a query to fetch even and odd rows from Employee table.
--one way(when you have an auto-icremented value in your table,like empid then we can simply use mod() to get odd/even rows)
select * from employee
where mod(empid,2)=0 --to fetch even rows
select * from employee
where mod(empid,2)!=0 --to fetch odd rows

--Other way using Row_Number
select * from
   (select *, row_number() over(order by empid) as S_No
	   from employee)as emp
where emp.S_No%2=1 --to fetch odd records

select * from
(select *,row_number() over (order by empid) as S_No from employee) as Emp
where emp.S_No%2=0 --to fetch even records

--Q5(a): Write a query to find all the Employee names whose name:
--• Begin with ‘A’
select empname from employee
where empname like'A%'
--• Contains ‘a’ alphabet at second place
select  empname from employee
where empname like '_a%'
--• Contains ‘t’ alphabet at second last place
select empname from employee
where empname like '%t_'
--• Ends with ‘n’ and contains 5 alphabets
select empname from employee
where empname like '____n'
--• Begins with ‘V’ and ends with ‘a’
select  empname from employee
where empname like 'V%a'

--Q5(b): Write a query to find the list of Employee names which is:
--• starting with vowels (a, e, i, o, or u), without duplicates
select distinct empname
from employee
where lower(empname) similar to'[aeiou]%'

--• ending with vowels (a, e, i, o, or u), without duplicates
select distinct empname
from employee
where lower(empname) similar to'%[aeiou]'
--• starting & ending with vowels (a, e, i, o, or u), without duplicates
select distinct empname
from employee
where lower(empname) similar to'[aeiou]%[aeiou]'

--Q6: Find Nth highest salary from employee table with and without using the TOP/LIMIT keywords.
--using limit
select salary from employee
order by salary desc
limit 1 --to get first highest salary
select salary from employee
order by salary desc
limit 1 offset 1 --to get second highest salary
select salary from employee
order by salary desc
limit 1 offset 3 --to get third highest salary

--without using limit
select salary from employee E1
where n-1=(
select count(distinct(E2.salary))from employee E2 where E2.salary>E1.salary); --to get nth highest salary
--Similarly we can write the above query as this:
select salary from employee E1
where n=(
select count(distinct(E2.salary))from employee E2 where E2.salary>=E1.salary); --to get nth highest salary

select salary from employee E1
where 0=(
select count(distinct(E2.salary))from employee E2 where E2.salary>E1.salary);  --to get first highest salary

select salary from employee E1
where 1=(
select count(distinct(E2.salary))from employee E2 where E2.salary>E1.salary);  --to get second highest salary

select salary from employee E1
where 2=(
select count(distinct(E2.salary))from employee E2 where E2.salary>E1.salary);  --to get third highest salary

--Q7(a): Write a query to find and remove duplicate records from a table.
--to fetch duplicate records
 select empid,empname,gender,salary,city,count(*) as duplicate_count
 from employee
 group by empid,empname,gender,salary,city
 having count(*)>1;
--to delete duplicate records
delete from employee
where empid in(select empid from employee group by empid
			  having count(*)>1);

--Q7(b): Query to retrieve the list of employees working in same project.
with cte as 
(select e.empid,e.empname,ed.project from employee as e
join employeedetail as ed
on e.empid=ed.empid)
select c1.empname,c2.empname,c1.project from cte c1,cte c2
where c1.project=c2.project and c1.empid!=c2.empid and c1.empid<c2.empid
   
--Q8: Show the employee with the highest salary for each project
select ed.project, max(e.salary) as MaxProjectSalary,sum(e.salary) as totalprojectsal,count(e.empid)
from employee as e
inner join employeedetail as ed
on e.empid=ed.empid
group by project
order by MaxProjectSalary desc;
--Alternative way to fetch nth highest salary for each project
with cte as(select project,empname,salary,
			row_number() over (partition by project order by salary desc) as row_rank
		   from employee as e
		   inner join employeedetail as ed
		   on e.empid=ed.empid)
		   select project,empname,salary
		   from cte
		   where row_rank=1; --for 1st highest salary

--Q9: Query to find the total count of employees joined each year
select extract('year' from doj) as joinyear,count(*) as empcount
from employee as e
inner join employeedetail as ed
on e.empid=ed.empid
group by joinyear
order by joinyear asc;

--Q10: Create 3 groups based on salary col, salary less than 1L is low, between 1 -2L is medium and above 2L is High
select empname,salary,
case
when salary>200000 then 'High'
when salary>= 100000 and salary<=200000 then 'Medium'
else 'Low'
end as SalaryStatus
from employee
order by salary desc;

--Q11: Query to pivot the data in the Employee table and retrieve the total salary for each city.
--The result should display the EmpID, EmpName, and separate columns for each city
--(Mathura, Pune, Delhi), containing the corresponding total salary.
select empid,empname,
sum(case when city='Mathura' then salary end) as "Mathura",
sum(case when city='Pune' then salary end) as "Pune",
sum(case when city='Banglore' then salary end) as "Banglore",
sum(case when city='Delhi' then salary end) as "Delhi"
from employee
group by empid,empname;