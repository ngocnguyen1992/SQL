-- Cách 1 dùng While và trả về ngày đầu tháng 

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
SELECT (ROW_NUMBER () OVER ( ORDER BY Ma_DT, Ngay_Ct ASC)) AS Stt, Ngay_Ct, Ma_DT 
INTO #temp 
FROM dbo.BanHang 
GROUP BY Ngay_Ct, Ma_DT

ALTER TABLE #temp ADD Ngay_DauThang DATE
ALTER TABLE #temp ADD check_ varchar(8)
UPDATE #temp SET Ngay_DauThang = DATEADD(DAY,-DAY(Ngay_Ct)+1,Ngay_Ct)

DECLARE @Date TABLE (Ngay_Ct DATE)
INSERT INTO @Date(Ngay_Ct)
SELECT DISTINCT Ngay_DauThang FROM #temp

DECLARE @run_date DATE
SELECT @run_date = MIN(Ngay_Ct) FROM @Date

WHILE EXISTS(SELECT 1 FROM @Date)
BEGIN
	UPDATE #temp SET Check_ = 1
	FROM #temp a 
	WHERE a.Ngay_DauThang = @run_date
	AND EXISTS (SELECT * FROM #temp b WHERE a.Ma_Dt=b.Ma_Dt AND b.Ngay_DauThang = DATEADD(MONTH, 1, @run_date))

	DELETE @Date WHERE Ngay_Ct = @run_date
	SET @run_date = DATEADD(MONTH, 1, @run_date)
END
SELECT * FROM #temp WHERE check_ = 1
SELECT * FROM #temp ORDER BY Ma_DT, Ngay_Ct
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp

-- Cách 2 dùng LAG

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp

SELECT (ROW_NUMBER () OVER ( ORDER BY Ma_DT, Ngay_Ct ASC)) AS Stt, Ngay_Ct, Ma_DT 
INTO #temp 
FROM dbo.BanHang 
GROUP BY Ngay_Ct, Ma_DT

ALTER TABLE #temp ADD Ngay_DauThang DATE
ALTER TABLE #temp ADD check_ varchar(8)
UPDATE #temp SET Ngay_DauThang = DATEADD(DAY,-DAY(Ngay_Ct)+1,Ngay_Ct)

IF OBJECT_ID('tempdb..#t2') IS NOT NULL DROP TABLE #t2

SELECT Ngay_DauThang, LAG(Ngay_DauThang,1) OVER(PARTITION BY Ma_DT ORDER BY Ngay_DauThang) AS _LAG, Ma_DT,
DATEDIFF(M, LAG(Ngay_DauThang,1) OVER(PARTITION BY Ma_DT ORDER BY Ngay_DauThang), Ngay_DauThang ) AS _MONTH
INTO #t2
FROM #temp
ORDER BY Ma_DT

IF OBJECT_ID('tempdb..#t3') IS NOT NULL DROP TABLE #t3
SELECT Ma_Dt, Ngay_DauThang, _LAG, _MONTH, ROW_NUMBER() OVER(PARTITION BY Ma_DT, _MONTH ORDER BY Ngay_DauThang) AS sale
INTO #t3
FROM #t2
ORDER BY Ma_DT

SELECT * FROM #t3
SELECT * FROM #t3 WHERE _MONTH = 1

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
IF OBJECT_ID('tempdb..#t2') IS NOT NULL DROP TABLE #t2
IF OBJECT_ID('tempdb..#t3') IS NOT NULL DROP TABLE #t3
