--Que 1) How many olympics games have been held?
--Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset.
--ANS)

SELECT COUNT(DISTINCT games) total_games 
FROM olympic_athlete;



--Que 2) List down all Olympics games held so far.
--Problem Statement: Write a SQL query to list down all the Olympic Games held so far.
--ANS)

SELECT DISTINCT(year), season, city 
FROM olympic_athlete 
ORDER BY year;



--Que 3)Mention the total no of nations who participated in each olympics game?
--Problem Statement: SQL query to fetch total no of countries participated in each olympic games.
--ANS)

SELECT oa.games,COUNT(DISTINCT nr.region) total_no_of_nations
FROM  olympic_athlete oa 
JOIN olympic_region nr 
ON oa.noc=nr.noc 
GROUP BY games; 



--Que 4) Which year saw the highest and lowest no of countries participating in olympics
--Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.	  
--ANS)

WITH cte AS (
	         SELECT games, COUNT(DISTINCT region) total_countries
             FROM olympic_athlete  oh
             JOIN olympic_region nr
	         ON nr.noc=oh.noc
             GROUP BY games
                            )
							
SELECT DISTINCT 
      CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries)
      , ' - '
      , FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS Lowest_Countries,
	  
      CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC)
      , ' - '
      , FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) AS Highest_Countries
      FROM cte ;
	  
	  
	  
--Que 5) Which nation has participated in all of the olympic games
--Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.
--ANS)

SELECT nr.region, COUNT(DISTINCT oa.games) AS total_region
FROM olympic_athlete oa
JOIN olympic_region nr
ON nr.noc = oa.noc
GROUP BY nr.region
HAVING COUNT(DISTINCT oa.games) = (SELECT COUNT(DISTINCT games) 
								   FROM olympic_athlete ) ;



--Que 6) Identify the sport which was played in all summer olympics.
--Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.
--ANS)

SELECT sport, COUNT(DISTINCT games) AS no_of_games
FROM olympic_athlete
GROUP BY sport
HAVING COUNT(DISTINCT games) = 
                               (SELECT COUNT(DISTINCT games) summer_olympic 
								FROM olympic_athlete 
								WHERE season = 'Summer') ;



--Que 7) Which Sports were just played only once in the olympics.
--Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.
--ANS)

WITH s1 AS 
           (SELECT  sport, COUNT(DISTINCT games) AS no_of_games
            FROM olympic_athlete oa
             GROUP BY sport),
s2 AS 
       (SELECT DISTINCT games AS game, sport 
		FROM olympic_athlete)

SELECT s1.sport, s1.no_of_games, s2.game
FROM s1 
JOIN s2 
ON s1.sport = s2.sport 
WHERE s1.no_of_games = 1 ;



--Que 8)Fetch the total no of sports played in each olympic games.
--Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.
--ANS)

SELECT games,COUNT(DISTINCT sport) AS sports
FROM olympic_athlete 
GROUP BY games 
ORDER BY sports DESC ;



--Que 9)  Fetch oldest athletes to win a gold medal
--Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
--ANS)

--APPROACH ONE
				SELECT name, sex,
	           CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS int) AS age,
               team, games, city, 
	           sport, event, medal
               FROM olympic_athlete
			   WHERE medal = 'Gold'
	           ORDER BY age DESC
	            LIMIT 2 ;
		
--APPROACH SECOND 

WITH casting AS 
                  ( 
				SELECT name, sex,
	           CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS int) AS age,
               team, games, city, 
	           sport, event, medal
               FROM olympic_athlete),
				 
ranking AS 
            (SELECT *, RANK() OVER(ORDER BY age DESC) AS rank_age
			 FROM casting 
			 WHERE medal = 'Gold')
	
SELECT * 
FROM ranking 
WHERE rank_age=1 ;
	
	
	
--Que 10) Find the Ratio of male and female athletes participated in all olympic games.
--Problem Statement: Write a SQL query to get the ratio of male and female participants
--ANS)	  

SELECT
       CONCAT('1',':',COUNT(sex) FILTER(WHERE sex = 'M')/COUNT(sex) FILTER( WHERE sex = 'F') :: FLOAT)
       FROM olympic_athlete ;



--Que 11)  Fetch the top 5 athletes who have won the most gold medals.
--Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.
--ANS)

SELECT name,team,total_gold_medal
FROM
     (
		 SELECT name, team, COUNT( medal) total_gold_medal,
         DENSE_RANK ()OVER(ORDER BY COUNT( medal) DESC ) rnk
         FROM olympic_athlete
         WHERE medal = 'Gold' 
         GROUP BY team, name
	                         ) x
							 
WHERE rnk<=5;



--Que 12) Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).
--ANS)

SELECT name,team,total_medals
FROM
    (
		SELECT name, team, COUNT( medal) total_medals,
        DENSE_RANK ()OVER(ORDER BY COUNT( medal) DESC) rnk
        FROM olympic_athlete
        WHERE medal = 'Gold' or medal = 'Silver' OR medal = 'Bronze'  
        GROUP BY team, name 
	                         ) x 
							 
WHERE rnk<=5;



--Que 13) Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
--Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).
--ANS)

SELECT *
FROM
    (
	SELECT  nr.region,  COUNT( medal) total_medals,
    DENSE_RANK ()OVER(ORDER BY COUNT( medal) DESC ) rnk
    FROM olympic_athlete oa
	JOIN olympic_region nr 
	ON oa.noc=nr.noc
	WHERE medal = 'Gold' or medal = 'Silver' or medal = 'Bronze'  
    GROUP BY nr.region
                      ) x
					  
WHERE rnk<=5;



--Que 14) List down total gold, silver and bronze medals won by each country.
--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
--ANS)

SELECT  nr.region AS country, COUNT( medal) FILTER( WHERE medal = 'Gold' ) total_gold_medal,
                              COUNT( medal) FILTER( WHERE medal = 'Silver' ) total_silver_medal,
                              COUNT( medal) FILTER( WHERE medal = 'Bronze' ) total_bronze_medal
FROM olympic_athlete oa 
JOIN olympic_region nr 
ON oa.noc=nr.noc  
GROUP BY nr.region
ORDER BY total_gold_medal DESC;



--Que 15) List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.
--ANS)

SELECT games, nr.region AS country,  COUNT( medal) FILTER( WHERE medal = 'Gold' ) total_gold_medal,
                                     COUNT( medal) FILTER( WHERE medal = 'Silver' ) total_silver_medal,
                                     COUNT( medal) FILTER( WHERE medal = 'Bronze' ) total_bronze_medal
FROM olympic_athlete oa 
JOIN olympic_region nr 
ON oa.noc=nr.noc  
GROUP BY nr.region,games 
ORDER BY games,region



						



--Que 16) Identify which country won the most gold, most silver and most bronze medals in each olympic games.
--Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.
--ANS)

WITH cte AS 
           (
			   SELECT  games, nr.region AS country ,  COUNT( medal) FILTER( WHERE medal = 'Gold' ) total_gold_medal,
                                                      COUNT( medal) FILTER( WHERE medal = 'Silver' ) total_silver_medal,
                                                      COUNT( medal) FILTER( WHERE medal = 'Bronze' ) total_bronze_medal
               FROM olympic_athlete oa 
			   JOIN olympic_region nr 
			   ON oa.noc=nr.noc  
               GROUP BY nr.region,games 
			   ORDER BY games)

SELECT DISTINCT games, 
                    CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_gold_medal DESC),
                    ' - ', FIRST_VALUE(total_gold_medal) OVER(PARTITION BY games ORDER BY total_gold_medal DESC)) AS max_gold,
	  
	                CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_silver_medal DESC),
                    ' - ', FIRST_VALUE(total_silver_medal) OVER(PARTITION BY games ORDER BY total_silver_medal DESC)) AS max_silver,
	  
	                 CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_bronze_medal DESC),
                    ' - ', FIRST_VALUE(total_bronze_medal) OVER(PARTITION BY games ORDER BY total_bronze_medal DESC)) AS max_bronze
	  
FROM cte
ORDER BY games;



--Que 17) Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
--Problem Statement: Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals.
--Along with this, identify also the country with the most medals in each olympic games.
--ANS)

WITH cte AS 
           (
			   SELECT  games, nr.region AS country ,  COUNT( medal) FILTER( WHERE medal = 'Gold' ) total_gold_medal,
                                                   COUNT( medal) FILTER( WHERE medal = 'Silver' ) total_silver_medal,
                                                   COUNT( medal) FILTER( WHERE medal = 'Bronze' ) total_bronze_medal,
			                                       COUNT(medal) FILTER ( WHERE medal = 'Gold' OR medal ='Silver' OR medal = 'Bronze') total_medal
            FROM olympic_athlete oa  
			JOIN olympic_region nr 
			ON oa.noc=nr.noc  
            GROUP BY nr.region,games
			ORDER BY games  )

SELECT DISTINCT games, 
                        CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_gold_medal DESC),
                        ' - ', FIRST_VALUE(total_gold_medal) OVER(PARTITION BY games ORDER BY total_gold_medal DESC)) AS max_gold,
	  
	                    CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_silver_medal DESC),
                        ' - ', FIRST_VALUE(total_silver_medal) OVER(PARTITION BY games ORDER BY total_silver_medal DESC)) AS max_silver ,
	  
	                    CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_bronze_medal DESC),
                        ' - ', FIRST_VALUE(total_bronze_medal) OVER(PARTITION BY games ORDER BY total_bronze_medal DESC)) AS max_bronze,
	  
	                    CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY total_medal DESC),
                        ' - ', FIRST_VALUE(total_medal) OVER(PARTITION BY games ORDER BY total_medal DESC)) AS max_medals
	  
FROM cte
ORDER BY games;



--Que 18) Which countries have never won gold medal but have won silver/bronze medals?
--Problem Statement: Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.
--ANS)

SELECT nr.region AS country ,  COUNT( medal) FILTER( WHERE medal = 'Gold' ) total_gold_medal,
                               COUNT( medal) FILTER( WHERE medal = 'Silver' ) total_silver_medal,
                               COUNT( medal) FILTER( WHERE medal = 'Bronze' ) total_bronze_medal
FROM olympic_athlete oa
JOIN olympic_region nr 
ON oa.noc=nr.noc 
GROUP BY nr.region 
HAVING COUNT( medal) FILTER( WHERE medal = 'Gold' ) = 0 AND
     ( COUNT( medal) FILTER( WHERE medal = 'Silver' )>0 OR 
       COUNT( medal) FILTER( WHERE medal = 'Bronze' )>0 )
 
ORDER BY total_gold_medal DESC NULLS LAST,
         total_silver_medal DESC NULLS LAST, 
		 total_bronze_medal DESC NULLS LAST;




--Que 19) In which Sport/event, India has won highest medals.
--Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals. 
--ANS)

SELECT sport,medals 
FROM
     (
		SELECT sport, COUNT(medal) AS medals,
        RANK () OVER(ORDER BY COUNT(medal) DESC)rnk 
        FROM olympic_athlete
        WHERE team = 'India' and medal <> 'NA'
        GROUP BY sport ) X

WHERE rnk=1;



--Que 20) Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
--Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 
--ANS)

SELECT team, sport, games, COUNT(medal) total_medals
FROM olympic_athlete 
WHERE medal !='NA' AND team='India' AND sport='Hockey' 
GROUP BY team, sport, games
ORDER BY total_medals DESC;



