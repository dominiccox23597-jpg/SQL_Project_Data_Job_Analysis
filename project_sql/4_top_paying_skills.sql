/*
Question: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focuses on roles with specified salaries
- Why? It reveals how different skills impact salary levels for Data Analysts and
    helps identify the most financially rewarding skills to acquire or improve
*/

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

