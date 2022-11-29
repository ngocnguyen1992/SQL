SET NOCOUNT ON;
DROP TABLE IF EXISTS #temp 

CREATE TABLE #temp (Stt INT, Code VARCHAR(16), Value INT) 

INSERT #temp (Stt, Code, Value) 
VALUES (1, 'A', 1)
    	,(2, 'B', 3)
		  ,(3, 'C', 2)
  		,(4, 'D', 5)
	  	,(5, 'E', 7);
--Cách 1
SELECT Code, Value, (SELECT SUM(Value) AS total FROM #temp t2 WHERE t2.Stt <= t1.Stt) AS Acccum_Value
FROM #temp t1

--Cách 2
SELECT Code, Value, SUM(Value) OVER(ORDER BY Stt) AS Acccum_Value
FROM #temp
