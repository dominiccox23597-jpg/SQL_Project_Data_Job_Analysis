# Introduction
What are the top paying data analyst jobs in the UK?

In this project I set out to discover this using real job advertisement data.

You can find all of my SQL queries here: [project sql](/project_sql/)

# Background
This project was a great way for me to begin my SQL learning journey. 

Through the course I developed my understanding in how SQL queries are structured in an effective way for data analysis/exploration.

This began through the simple basics of SELECT, FROM, & WHERE clauses.

Following on from this I learned a variety of commonly used aggregations like SUM, COUNT, AVG, MIN, & MAX, and understood the importance of using GROUP BY clauses for these aggregations to work correctly. Also the added power to filter these aggregated results using the HAVING clause, and/or ordering these results using the ORDER BY clause.

It's rare for all of our required data to be in the same table so I learned how to join tables together using JOIN clauses (most commmonly INNER, & LEFT OUTER)

Finally for more complex analysis I learned how to use CTE's for multi-step analysis
# Tools I Used
- **SQL**: The language to query the database
- **PostgreSQL**: The chosen databse management system
- **Visual Studio Code**: My go-to for database management and executing SQL queries
- **Git & GitHub**: Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking
# The Analysis
This project outlines the most in demand skills, and the top paying skills for data analysts in the UK. 

### 1. What are the top paying data analyst jobs?
To find this out I uitilised the WHERE statement to filter for data analyst roles that are based in the UK followed by an ORDER BY to order the results from highest paying to lowest paying.

``` sql
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM 
    job_postings_fact
LEFT JOIN 
    company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst' AND
    job_country = 'United Kingdom' AND
    salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10;
```

The highest paying role was for a market data analyst lead paying £180,000. There were a diverse range of employers from different sectors that were posting these jobs from banks and investment platforms like Deutsche Bank & AJ Bell to software companies like DeepMind & Darktrace.

### 2. What are the top paying skills for data analysts?
For this I used the 1st query above in a CTE and used 2 INNER JOINs with 2 separate tables containing all of the skills listed across these adverts to return the skills that these top 10 paying jobs required.

``` sql
With top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM 
        job_postings_fact
    LEFT JOIN 
        company_dim
    ON job_postings_fact.company_id = company_dim.company_id
    WHERE 
        job_title_short = 'Data Analyst' AND
        job_country = 'United Kingdom' AND
        salary_year_avg IS NOT NULL
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
    salary_year_avg DESC
```

This query showed how many different skills these jobs required. All apart from 1 job listed at least 3 separate skills as requirements. This emphasised how many different skills the top analysts are required to have a working knowledge with.

### 3. What are the most demanded skills?
Here I wanted to find out which skills appear most frequetly in job positings as this would show the most common skills used in the field.

For this I again used 2 INNER JOINs with our skills tables and also used the COUNT aggregation function and GROUP BY followed by LIMIT to return the top 5 most demanded skills and the qty of job postings where these skills were requested

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND
    job_country = 'United Kingdom'
GROUP BY
     skills
ORDER BY
    demand_count DESC
LIMIT 5
```

The results from this query show that SQL & Excel are comfortably the most demanded tools, followed by PowerBI & Tableau for visualisation, and python for automation.

| Skills            | Demand Count      |
|-------------------|-------------------|
| SQL               | 4480              |
| Excel             | 4281              |
| power bi          | 2865              |
| python            | 2129              |
| tableau           | 1644              |

### 4. Top paying high demand skills

Here I looked at what the average salaries were by skill

```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg),0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_country = 'United Kingdom'
GROUP BY 
    skills
ORDER BY
    avg_salary DESC
LIMIT 10;
```
 The query above gives us the top 10 paying skills in the UK for data analyst roles.
But this could be skewed towards niche skills that only appear in a small number of positions.
So using the results of the previous query where we found out the top 5 demanded skills we could find out the average
salary for jobs requiring these skills


```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg),0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_country = 'United Kingdom'
    AND skills IN('power bi', 'tableau', 'python', 'sql', 'excel')
GROUP BY 
    skills
ORDER BY
    avg_salary DESC;
```

*This gives us the avg salary for the top 5 demanded skills that we discovered in the top demanded skills query.
But in the query above these skills are hardcoded, what if when more job adverts are added to the database the most demanded
skills shift over time. We could use a CTE to futureproof our query, discovering the top 5 demanded skills, and then calculating
the avg salary among them.

```sql
WITH most_demanded_skills AS (
SELECT 
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND
    job_country = 'United Kingdom'
GROUP BY
     skills
ORDER BY
    demand_count DESC
LIMIT 5)

SELECT 
    most_demanded_skills.skills,
ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary
FROM most_demanded_skills
INNER JOIN skills_dim ON most_demanded_skills.skills = skills_dim.skills
INNER JOIN skills_job_dim ON skills_job_dim.skill_id = skills_dim.skill_id
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE salary_year_avg IS NOT NULL 
AND job_country = 'United Kingdom'
AND job_title_short = 'Data Analyst'
GROUP BY most_demanded_skills.skills
ORDER BY avg_salary DESC;
```


