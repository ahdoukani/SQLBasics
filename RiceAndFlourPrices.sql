
-- Selecting all groceries that contain the string "rice" and "flour" where the price is not left blank
-- This is to help clean the data before it is fed to a Machine learning model


SELECT date, AVG(cast(price as int)) AS AverageFlourPrice

FROM PortfolioProject..FoodPrices
WHERE product like '%Flour%' AND price <> ''
GROUP BY date
ORDER BY date

SELECT
    date, AVG(cast(price AS INT)) AS AverageFlourPrice
FROM
   PortfolioProject..FoodPrices
WHERE
   product like '%Flour%' AND price <> ''
GROUP BY date
UNION ALL
SELECT
    date,  AVG(cast(price AS INT))  AS AverageWhiteRicePrice
FROM
   PortfolioProject..FoodPrices  
WHERE
   product like '%Rice%' AND price <> ''
GROUP BY date

SELECT
   date
   , AVG(CASE WHEN product like '%Flour%'
         THEN cast(price AS INT)
    END ) AS AverageFlourPrice 
	, AVG(CASE WHEN product like '%White Rice%' 
         THEN cast(price AS INT)
    END ) AS AverageWhiteRicePrice 
   
FROM
   PortfolioProject..FoodPrices  

WHERE 
	product <> ''
GROUP BY
	date