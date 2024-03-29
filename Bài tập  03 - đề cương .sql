/*Liệt kê ra các hoá đơn trong tháng 9/2010 (Ngay_Ct, So_Ct, Dien_Giai0, Doanh thu, tiền thuế, Tổng tiền).*/

SELECT Ngay_Ct, So_Ct, Dien_Giai, Doanh_thu, Thue, Tien 
FROM dbo.BanHang 
WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2013
ORDER BY Ngay_Ct
-- Em đã lấy 1 số cột theo yêu cầu và format lại đúng quy tắc

----
/*Liệt kê ra các hoá đơn do NV kinh doanh Nguyễn Văn A bán vào tháng 9/2013. */

SELECT nv.Ten_NV, bh.Ngay_Ct, bh.Ma_Nv, bh.So_Ct
FROM dbo.BanHang bh JOIN dbo.DmNv nv ON bh.Ma_Nv = nv.Ma_Nv
WHERE nv.Ten_NV = N'Nguyễn Văn A' AND MONTH(bh.Ngay_Ct)= 9 AND YEAR(Ngay_Ct) = 2013
-- Em đã filter Nguyễn Văn A, thêm N'' cho chuỗi tiếng việt có dấu (NVARCHAR) và bỏ GROUP BY nhiều cấp ko cần thiết

---
/*Liệt kê ra 3 mặt hàng bán chạy nhất trong tháng 9/2013.*/
--Cách 1

SELECT TOP 3 vt.Ten_Vt, bh.Ma_Vt, Sum(bh.So_Luong) SL, bh.Tien, bh.Ngay_Ct
FROM dbo.BanHang bh JOIN dbo.DmVt vt ON bh.Ma_Vt = vt.Ma_Vt
WHERE MONTH(bh.Ngay_Ct) = 9 AND YEAR(bh.Ngay_Ct) = 2013
GROUP BY bh.Ma_Vt, bh.Tien, vt.Ten_Vt, bh.Ngay_Ct
ORDER BY SL DESC

--Cách 2
SELECT *
FROM (
	SELECT MAX(Ngay_Ct) as Ngay_Ct, Ma_Vt, SUM(So_Luong) AS So_Luong, 
	DENSE_RANK () OVER (ORDER BY SUM(So_Luong) DESC) AS Rank_ 
	FROM dbo.BanHang 
	WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2013
	GROUP BY Ma_Vt
	) AS bh
WHERE rank_ <= 3

-- Liệt kê các mặt hàng không có người mua trong tháng 9/2014.

--Cách 1
SELECT Ten_Vt, Ma_Vt 
FROM dbo.DmVt 
WHERE Ma_Vt NOT IN (SELECT Ma_Vt FROM dbo.BanHang WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2014)

--Cách 2
SELECT Ten_Vt, Ma_Vt 
FROM dbo.DmVt 
WHERE NOT EXISTS (SELECT 1 FROM dbo.BanHang WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2014 AND DmVt.Ma_Vt = BanHang.Ma_Vt)

--Liệt kê ra các nhân viên chờ nghỉ hưu ( nam >=55 và nữ >=50) .

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
SELECT Ma_Nv, Ten_Nv, DATEDIFF(YEAR, Ngay_sinh, GETDATE()) AS Tuoi, Gioi_Tinh
INTO #temp 
FROM dbo.DmNv

SELECT * FROM #temp 
WHERE (Tuoi >= 55 AND Gioi_Tinh = 'Nam') OR (Tuoi >= 50 AND Gioi_Tinh = 'Nu')
ORDER BY Ma_Nv
-- Em thêm ngoặc đoạn WHERE (AND) OR (AND)

--Tạo một TABLE tạm #tblCt bằng câu lệnh CREATE gồm các field : Ma_Ct, Ngay_ct, So_Ct, Ma_Vt, So_Luong, Don_Gia, Thanh_tien, Ma_Kho, Ma_Dt, Ma_Nx, Ma_Tte
--INSERT dữ liệu của các chứng từ hoá đơn, chứng từ nhập mua và chi phí vào bản tạm #tblCt.

SET NOCOUNT ON;
DROP TABLE IF EXISTS #tblCt

CREATE TABLE #tblCt 
(Id INT, Ma_Ct VARCHAR(16), Ma_Vt VARCHAR(16), Ngay_Ct DATE, So_Ct VARCHAR(16), So_Luong INT, Don_Gia INT,
Thanh_Tien INT, Ma_Kho VARCHAR(16), Ma_Dt VARCHAR(16), Ma_Nx VARCHAR(16), Ma_Tte VARCHAR(16));

DECLARE  @_Don_Gia NUMERIC(18), @_Ma_Ct VARCHAR(16)
	, @_Ma_Kho VARCHAR(16), @_Ma_Nx VARCHAR(16)
        , @_i INT = 1, @_Ma_Tte VARCHAR(16);

WHILE @_i < 100
BEGIN
	SELECT @_Ma_Ct = 'Ct' + FORMAT(@_i, '0####');
	SELECT @_Ma_Nx = 'Nx' + FORMAT(@_i, '0####');
	SELECT @_Ma_Kho = 'Kho' + FORMAT(@_i, '0####');
	SELECT @_Ma_Tte = 'Tte' + FORMAT(@_i, '0####');
	SET @_Don_Gia = ROUND(RAND()*10000, 0);

    INSERT #tblCt (Id, Ma_Ct, Ma_Kho, Don_Gia, Ma_Nx, Ma_Tte) 
    VALUES(@_i, @_Ma_Ct, @_Ma_Kho, @_Don_Gia, @_Ma_Nx, @_Ma_Tte );
    SET @_i +=1;
END

--Dùng câu truy vấn SQL thêm vào bảng #tblCt các filed Ten_Vt, Ten_Kho, Ten_Dt.
--Update dữ liệu cho các field Ten_Vt, Ten_Kho, Ten_Dt của bảng #tblCt.
--Lấy dữ liệu từ bảng bán hàng qua bảng #tblCt

ALTER TABLE #tblCt ADD Ten_Vt NVARCHAR(128), Ten_Kho NVARCHAR(128), Ten_Dt NVARCHAR(128)

UPDATE #tblCt 
SET #tblCt.Ngay_Ct = bh.Ngay_Ct
    , #tblCt.So_Ct = bh.So_Ct
    , #tblCt.So_Luong = bh.So_Luong
    , #tblCt.Ma_Dt = bh.Ma_Dt
    , #tblCt.Thanh_Tien = bh.Tien
    , #tblCt.Ma_Vt = bh.Ma_Vt
FROM (SELECT Id, Ngay_Ct, So_Ct, So_Luong, Ma_Dt, Ma_Vt, Tien FROM dbo.BanHang) bh
WHERE bh.Id = #tblCt.Id
---
UPDATE #tblCt
SET #tblCt.Ten_Kho = wh.Ten_Kho
FROM dbo.WareHouse wh
WHERE #tblCt.Ma_Kho = wh.Ma_Kho

-- Cách 2: Hoặc em delete đoạn SELECT @_Ma_Kho = 'Kho' + FORMAT(@_i, '0####'); và update luôn Ma_Kho, Ten_Kho theo Id

UPDATE #tblCt
SET #tblCt.Ma_Kho = wh.Ma_Kho
    ,#tblCt.Ten_Kho = wh.Ten_Kho
FROM dbo.WareHouse wh
WHERE #tblCt.Id = wh.Id
---
UPDATE #tblCt
SET #tblCt.Ten_Vt = vt.Ten_Vt
FROM (SELECT Ten_Vt, Ma_Vt FROM dbo.DmVt) vt
WHERE #tblCt.Ma_Vt = vt.Ma_Vt

UPDATE #tblCt
SET #tblCt.Ten_Dt = dt.Ten_Dt
FROM (SELECT Ten_Dt, Ma_Dt FROM dbo.DmDt) dt
WHERE #tblCt.Ma_Dt = dt.Ma_Dt
-- Em đã update Ten_Vt, Ten_Dt, Ten_Kho theo các danh mục tương ứng (DmVt, DmDt, WareHouse).

--Copy dữ liệu của #tblCt qua #CtHdCopy rồi xoá hết dữ liệu của #tblCt.

IF OBJECT_ID('tempdb..#CtHdCopy') IS NOT NULL DROP TABLE #CtHdCopy

SELECT *
INTO #CtHdCopy
FROM #tblCt
TRUNCATE TABLE #tblCt

SELECT * FROM #CtHdCopy 
IF OBJECT_ID('tempdb..#CtHdCopy') IS NOT NULL DROP TABLE #CtHdCopy
