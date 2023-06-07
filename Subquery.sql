USE ebbu;

SELECT * FROM movies 
WHERE (gross - budget) =( SELECT MAX(gross- budget)  
							FROM movies);
						
SELECT * FROM movies
ORDER BY (gross - budget) DESC LIMIT 1;                        


SELECT COUNT(*) FROM movies 
WHERE  score > (SELECT AVG(score) 
                   FROM movies);
SELECT * FROM movies
WHERE YEAR =2000 AND score = (SELECT MAX(score) FROM movies
                               WHERE year =2000);
SELECT * from movies 
WHERE score = (SELECT MAX(score) FROM movies 
               WHERE votes > (SELECT AVG(votes)
                               FROM movies));
SELECT * FROM movies 
WHERE (year, gross-budget) IN (SELECT year , MAX(gross-budget) 
                                  FROM movies
								GROUP BY year );
SELECT * FROM movies WHERE (genre,score) IN (SELECT genre, MAX(score)
                                             FROM movies 
                                             WHERE  votes > 25000
                                             GROUP BY genre)
AND votes >25000;

WITH top_duos AS (
				SELECT star, director ,MAX(gross)
				FROM movies
				GROUP BY star,director
				ORDER BY SUM(gross) DESC LIMIT 5)
 SELECT * FROM movies 
 WHERE (star,director ,gross ) IN (SELECT * FROM top_duos);
 
 SELECT * FROM movies m1
 WHERE score > ( SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre);
 
 SELECT name, (votes/(SELECT SUM(votes) FROM movies))*100 FROM movies ;
 
 SELECT name,genre,score,(SELECT AVG(score) FROM movies m2 
 WHERE m2.genre = m1.genre)
 FROM movies m1;
 
 SELECT genre, AVG(score)
 FROM movies
 GROUP BY genre
 HAVING AVG(score) > ( SELECT AVG(score) FROM movies);
 
 
                




 
