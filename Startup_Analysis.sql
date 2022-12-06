/*Eye Balling Data*/

USE startup_db;
SELECT * FROM dbo.acquisitions;
SELECT * FROM dbo.degrees;
SELECT * FROM dbo.funding_rounds;
SELECT * FROM dbo.funds;
SELECT * FROM dbo.investments;
SELECT * FROM dbo.ipos;
SELECT * FROM dbo.milestones;
SELECT * FROM dbo.objects;
SELECT * FROM dbo.offices;
SELECT * FROM dbo.people;
SELECT * FROM dbo.relationships;
SELECT * FROM dbo.countries;

SELECT TOP 20
	acquisition_id, 
	price_amount
FROM 
	dbo.acquisitions
ORDER BY 
	price_amount DESC;

	SELECT TOP 20
	funding_round_id,
	raised_amount_usd
FROM
	dbo.funding_rounds;

SELECT TOP 20
	object_id,
	raised_amount_usd
FROM
	dbo.funding_rounds;

	/*Acquisition per year*/
SELECT 
FORMAT(acquired_at, 'yyyy') AS acquisition_year,
COUNT(acquiring_object_id) AS no_of_acquisition,
SUM(price_amount) AS total_acquisition_value 
FROM dbo.acquisitions
GROUP BY FORMAT(acquired_at, 'yyyy')
ORDER BY FORMAT(acquired_at, 'yyyy') ASC;

/* Solution to Questions from Database*/

/*1. largest investment in an African startup*/

/*The Largest Investment in an African Start up is the 'Edita Food Industries'*/

SELECT TOP 1 ob.name, co.name, co.region, ob.funding_total_usd
FROM objects ob
JOIN countries co
ON ob.country_code=co.country_code
WHERE co.region='Africa'
ORDER BY ob.funding_total_usd DESC;

/*2. Do you think the level of degree impacts the size of the funding round?*/

/*Founders who has Bachelors degree has the most founding rounds (17171).*/

SELECT
 (CASE
	WHEN 
	(de.degree_type LIKE ('B%') OR de.degree_type LIKE ('%BSc%') OR 
	de.degree_type LIKE ('%Bachelor%') OR de.degree_type LIKE ('JD%')  OR de.degree_type LIKE ('Juris%') OR de.degree_type LIKE ('Law%') OR de.degree_type LIKE ('%Degree%'))THEN 'Bachelors'
	WHEN 
	(de.degree_type LIKE ('%M.%')OR de.degree_type LIKE ('%Grad%') OR de.degree_type LIKE ('%MBA%') OR de.degree_type LIKE ('%MS%') OR de.degree_type LIKE ('%MB%') OR de.degree_type LIKE ('%Master%')) THEN 'Masters' 
    WHEN 
	(de.degree_type LIKE ('%Ph%')OR de.degree_type LIKE ('%Phil%') OR de.degree_type LIKE ('%Doctor%')OR de.degree_type LIKE ('D.%')) THEN 'Ph.D'
	WHEN 
	(de.degree_type LIKE ('%Dip%')) THEN 'Diploma'
	ELSE 'Others'
	END) AS degree_type,
COUNT((CASE
	WHEN 
	(de.degree_type LIKE ('B%') OR de.degree_type LIKE ('%BSc%') OR 
	de.degree_type LIKE ('%Bachelor%') OR de.degree_type LIKE ('JD%')  OR de.degree_type LIKE ('Juris%') OR de.degree_type LIKE ('Law%') OR de.degree_type LIKE ('%Degree%'))THEN 'Bachelors'
	WHEN 
	(de.degree_type LIKE ('%M.%')OR de.degree_type LIKE ('%Grad%') OR de.degree_type LIKE ('%MBA%') OR de.degree_type LIKE ('%MS%') OR de.degree_type LIKE ('%MB%') OR de.degree_type LIKE ('%Master%')) THEN 'Masters' 
    WHEN 
	(de.degree_type LIKE ('%Ph%')OR de.degree_type LIKE ('%Phil%') OR de.degree_type LIKE ('%Doctor%')OR de.degree_type LIKE ('D.%')) THEN 'Ph.D'
	WHEN 
	(de.degree_type LIKE ('%Dip%')) THEN 'Diploma'
	ELSE 'Others'
	END)) AS no_of_founders,
SUM(ob.funding_total_usd) total_funding_generated,
SUM(ob.funding_rounds) AS no_of_funding_rounds,
SUM(ob.funding_total_usd)/NULLIF(COUNT((CASE
	WHEN 
	(de.degree_type LIKE ('B%') OR de.degree_type LIKE ('%BSc%') OR 
	de.degree_type LIKE ('%Bachelor%') OR de.degree_type LIKE ('JD%')  OR de.degree_type LIKE ('Juris%') OR de.degree_type LIKE ('Law%') OR de.degree_type LIKE ('%Degree%'))THEN 'Bachelors'
	WHEN 
	(de.degree_type LIKE ('%M.%')OR de.degree_type LIKE ('%Grad%') OR de.degree_type LIKE ('%MBA%') OR de.degree_type LIKE ('%MS%') OR de.degree_type LIKE ('%MB%') OR de.degree_type LIKE ('%Master%')) THEN 'Masters' 
    WHEN 
	(de.degree_type LIKE ('%Ph%')OR de.degree_type LIKE ('%Phil%') OR de.degree_type LIKE ('%Doctor%')OR de.degree_type LIKE ('D.%')) THEN 'Ph.D'
	WHEN 
	(de.degree_type LIKE ('%Dip%')) THEN 'Diploma'
	ELSE 'Others'
	END)),0) AS funding_per_degree
from degrees de
JOIN relationships re
ON de.object_id = re.person_object_id
JOIN objects ob
ON re.relationship_object_id =ob.object_id
WHERE re.title LIKE '%Founder%'
GROUP BY( (CASE
	WHEN 
	(de.degree_type LIKE ('B%') OR de.degree_type LIKE ('%BSc%') OR 
	de.degree_type LIKE ('%Bachelor%') OR de.degree_type LIKE ('JD%')  OR de.degree_type LIKE ('Juris%') OR de.degree_type LIKE ('Law%') OR de.degree_type LIKE ('%Degree%'))THEN 'Bachelors'
	WHEN 
	(de.degree_type LIKE ('%M.%')OR de.degree_type LIKE ('%Grad%') OR de.degree_type LIKE ('%MBA%') OR de.degree_type LIKE ('%MS%') OR de.degree_type LIKE ('%MB%') OR de.degree_type LIKE ('%Master%')) THEN 'Masters' 
    WHEN 
	(de.degree_type LIKE ('%Ph%')OR de.degree_type LIKE ('%Phil%') OR de.degree_type LIKE ('%Doctor%')OR de.degree_type LIKE ('D.%')) THEN 'Ph.D'
	WHEN 
	(de.degree_type LIKE ('%Dip%')) THEN 'Diploma'
	ELSE 'Others'
	END))
ORDER BY degree_type;

/*2a. . What university did the founder that has the most funding rounds attend*/

SELECT TOP 4 CONCAT(pe.first_name,' ', pe.last_name) AS founder_name, re.title, de.institution, ob.name, ob.funding_rounds, ob.funding_total_usd
FROM objects ob
JOIN relationships re
ON ob.object_id=re.relationship_object_id
JOIN people pe
ON re.person_object_id=pe.object_id
JOIN degrees de
ON pe.object_id=de.object_id
ORDER BY ob.funding_rounds DESC;

/*2b.How many founders attended the school in [a] and how many of them have an
IPO*/

/*None*/

SELECT de.institution, COUNT(de.institution) AS no_of_alumni_founder
FROM degrees de
JOIN relationships re
ON de.object_id = re.person_object_id
JOIN ipos ip
ON re.relationship_object_id = ip.object_id
WHERE de.institution ='University of New South Wales' AND re.title LIKE '%Founder%'
GROUP BY de.institution;


/*3.Region with the most startups*/

/*The Top Region with the most startups is
Continent - Americas
Country- United State*/


SELECT TOP 1 co.region, COUNT (co.region) AS no_of_startups
FROM objects ob
JOIN countries co
ON ob.country_code=co.country_code
GROUP BY co.region 
ORDER BY no_of_startups DESC;

SELECT TOP 1  co.name, COUNT (co.name) AS no_of_startups
FROM objects ob
JOIN countries co
ON ob.country_code=co.country_code
GROUP BY co.name 
ORDER BY no_of_startups DESC;


 /*4a startup that has the most funding round*/
 /*Tyro Payments has 15 funding rounds which is the highest*/

SELECT TOP 1 ob.name, ob.funding_rounds
FROM objects ob
ORDER BY ob.funding_rounds DESC;


/*4b What is the founder’s name?*/

/* Tyro Payments has three(3) Co-Founders
1. Peter Haig
2. Andrew Rothwell
3 Paul wood
*/

SELECT CONCAT(pe.first_name,' ', pe.last_name) AS founder_name, re.title, ob.name, ob.funding_rounds, ob.funding_total_usd
FROM objects ob
JOIN relationships re
ON ob.object_id=re.relationship_object_id
JOIN people pe
ON re.person_object_id=pe.object_id
WHERE re.title LIKE '%Founder%'
ORDER BY ob.funding_rounds DESC

