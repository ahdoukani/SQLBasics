

-- Sales performance table for bullet chart - Tableau


DROP TABLE IF EXISTS #ActualPreditedSales
CREATE TABLE #ActualPreditedSales (

highSales NUMERIC,
medSales NUMERIC,
lowSales NUMERIC,
actualSales NUMERIC,
targetSales NUMERIC,
)

INSERT INTO #ActualPreditedSales(highSales,medSales,lowSales,actualSales,targetSales)
VALUES(350000,250000,100000,0,400000)

UPDATE  #ActualPreditedSales SET actualSales = 

	(SELECT SUM(CAST(QUANTITYORDERED*PRICEEACH AS INT)) AS motorCycleSales
	FROM PortfolioProject..SalesDataSample
	WHERE PRODUCTLINE = 'Motorcycles' AND YEAR_ID = '2003' 	
	)

SELECT *
FROM #ActualPreditedSales

-- Sales breakdown for pareto chart- Bar/line - Tableau


SELECT PRODUCTLINE, SUM(CAST(QUANTITYORDERED*PRICEEACH AS INT)) AS salesValue
FROM PortfolioProject..SalesDataSample
GROUP BY PRODUCTLINE
ORDER BY PRODUCTLINE

--Variation - Tableau

SELECT YEAR_ID, PRODUCTLINE, SUM(CAST(QUANTITYORDERED*PRICEEACH AS INT)) AS salesValue
FROM PortfolioProject..SalesDataSample
GROUP BY PRODUCTLINE, YEAR_ID
ORDER BY PRODUCTLINE, YEAR_ID

-- Sales breakdown for Dual Axis Chart- Bar/line  - Tableau

SELECT YEAR_ID,SUM(CAST(QUANTITYORDERED AS INT)) AS QuantityOrdered, PRODUCTLINE, SUM(CAST(QUANTITYORDERED*PRICEEACH AS INT)) AS salesValue
FROM PortfolioProject..SalesDataSample
GROUP BY PRODUCTLINE, YEAR_ID
ORDER BY PRODUCTLINE, YEAR_ID