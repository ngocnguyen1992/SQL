-- Câu 1 :Tìm các khách hàng có số lượng mua hàng nhiều nhất 
         trong khoảng thời gian từ ‘01/01/2013’ đến ‘31/01/2013’

DECLARE @_Ngay_BD DATE ='2013-01-01', 
	@_Ngay_KT DATE ='2013-01-31'
      
SELECT Ma_DT, SUM (So_Luong) AS So_Luong
FROM dbo.BanHang
WHERE Ngay_Ct >= @_Ngay_BD
      AND Ngay_Ct <= @_Ngay_KT
GROUP BY Ma_DT
ORDER BY So_Luong DESC

---- Thêm cột Ten_DT, từ bảng DmDt

DECLARE @_Ngay_BD DATE ='2013-01-01', 
	@_Ngay_KT DATE ='2013-01-31'

SELECT bh.Ma_DT, MAX(dt.Ten_DT) AS Ten_DT, 
       SUM (bh.So_Luong) AS So_Luong	
FROM dbo.BanHang bh 
INNER JOIN dbo.DmDt dt ON bh.Ma_DT = dt.Ma_DT
WHERE Ngay_Ct >= @_Ngay_BD
      AND Ngay_Ct <= @_Ngay_KT
GROUP BY bh.Ma_DT
ORDER BY So_Luong DESC

---------------------------------------------------------------------------------------------------------------
-- Câu 2 : Tìm 10 khách hàng có doanh số bán nhiều nhất 
	trong khoảng thời gian từ ‘01/01/2013’ đến ‘31/01/2013’

DECLARE @_Ngay_BD DATE ='2013-01-01', 
	@_Ngay_KT DATE ='2013-01-31'
      
SELECT TOP 10 Ten_DT, Tien
FROM dbo.BanHang bh, dbo.DmDt dt
WHERE bh.Ma_DT = dt.Ma_DT 
      AND Ngay_Ct >= @_Ngay_BD
      AND Ngay_Ct <= @_Ngay_KT
ORDER BY Tien DESC

-- Câu 2 : sửa hoàn chỉnh thêm Declare Date, GROUP BY.

DECLARE @_Ngay_BD DATE ='2013-01-01', 
	@_Ngay_KT DATE ='2013-01-31'

SELECT TOP 10 bh.Ma_DT, 
MAX (dt.Ten_DT) AS Ten_DT, 
SUM (bh.Tien) AS Tien
FROM dbo.BanHang bh, dbo.DmDt dt
WHERE bh.Ma_DT = dt.Ma_DT 
      AND Ngay_Ct >= @_Ngay_BD
      AND Ngay_Ct <= @_Ngay_KT
GROUP BY bh.Ma_DT
ORDER BY Tien DESC

---------------------------------------------------------------------------------------------------------------
-- Câu 3 :Tìm mặt hàng nào bán chạy nhất 
	trong khoảng thời gian từ ‘01/01/2013’ đến ‘31/01/2013’

DECLARE @_Ngay_BD DATE ='2013-01-01', 
	@_Ngay_KT DATE ='2013-01-31'

SELECT TOP 1 bh.Ma_Vt, 
MAX(vt.Ten_Vt) AS Ten_Vt, 
SUM (bh.So_Luong) AS So_Luong
FROM dbo.DmVt vt, dbo.BanHang bh
WHERE vt.Ma_Vt = bh.Ma_Vt
GROUP BY bh.Ma_Vt 
ORDER BY So_Luong DESC
