/*Liệt kê ra các hoá đơn trong tháng 9/2010 (Ngay_Ct, So_Ct, Dien_Giai0, Doanh thu, tiền thuế, Tổng tiền).*/

SELECT * FROM dbo.BanHang 
WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2013
ORDER BY Ngay_Ct
----
/*Liệt kê ra các hoá đơn do NV kinh doanh Nguyễn Văn A bán vào tháng 9/2010. */

SELECT nv.Ten_NV, bh.Ngay_Ct, bh.Ma_Nv, bh.So_Ct
FROM dbo.BanHang bh JOIN dbo.DmNv nv ON bh.Ma_Nv = nv.Ma_Nv
WHERE nv.Ten_NV = 'Tên Nhân Viên 882' AND MONTH(bh.Ngay_Ct)=9
GROUP BY nv.Ten_Nv, bh.Ngay_Ct, bh.Ma_Nv, bh.So_Ct

---
/*Liệt kê ra 3 mặt hàng bán chạy nhất trong tháng 9/2010.*/
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

-- 6.	Liệt kê các mặt hàng không có người mua trong tháng 9/2010.

SELECT Ten_Vt, Ma_Vt 
FROM dbo.DmVt 
WHERE Ma_Vt NOT IN (SELECT Ma_Vt FROM dbo.BanHang WHERE MONTH(Ngay_Ct) = 9 AND YEAR(Ngay_Ct) = 2014)

--7.	Liệt kê ra các nhân viên chờ nghỉ hưu ( nam >=55 và nữ >=50) .

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
SELECT Ma_Nv, Ten_Nv, DATEDIFF(YEAR, Ngay_sinh, GETDATE()) AS Tuoi, Gioi_Tinh
INTO #temp 
FROM dbo.DmNv

SELECT * FROM #temp 
WHERE Tuoi >= 55 AND Gioi_Tinh = 'Nam' OR Tuoi >= 50 AND Gioi_Tinh = 'Nu' 
ORDER BY Ma_Nv

--8.	Tạo một TABLE tạm #tblCt bằng câu lệnh CREATE gồm các field : Ma_Ct, Ngay_ct, So_Ct, Ma_Vt, So_Luong, Don_Gia, Thanh_tien, Ma_Kho, Ma_Dt, Ma_Nx, Ma_Tte
--9.INSERT dữ liệu của các chứng từ hoá đơn, chứng từ nhập mua và chi phí vào bản tạm #tblCt.

SET NOCOUNT ON;
DROP TABLE IF EXISTS #tblCt
CREATE TABLE #tblCt 
(Ma_Ct VARCHAR(16), Ngay_Ct DATE, So_Ct VARCHAR(16), So_Luong INT, 
Don_Gia INT, Thanh_Tien INT, Ma_Kho VARCHAR(16), Ma_Dt VARCHAR(16), Ma_Nx VARCHAR(16), Ma_Tte VARCHAR(16));


DECLARE @_Ma_Ct VARCHAR(16), @_Ngay_Ct DATE, @_So_Ct VARCHAR(20), @_j INT = 1    
    , @_So_Luong NUMERIC(18,2), @_Don_Gia NUMERIC(18), @_Thanh_Tien NUMERIC(18)
    , @_Ma_Kho VARCHAR(16), @_Ma_Nx VARCHAR(16), @_Ma_Tte VARCHAR(16)
    , @_Rand INT, @_i INT = 1, @_Ma VARCHAR(16), @_Ma_Dt VARCHAR(16);

WHILE @_i < 1000
BEGIN
	SELECT @_Ma_Ct = 'Ct' + FORMAT(@_i, '0####');
	SET @_Ngay_Ct = DATEADD(day, ROUND(RAND()*1000, 0), '20130101');
	SET @_So_Ct = 'BH' + FORMAT(@_i, '0###');
	SELECT @_Ma_Kho = 'KHO' + FORMAT(@_i, '0####');
	SELECT @_Ma_Dt = 'KH' + FORMAT(@_i, '0####');
	SELECT @_Ma_Nx = 'Nx' + FORMAT(@_i, '0####');
	SELECT @_Ma_Tte = 'Tte' + FORMAT(@_i, '0####');
	SET @_So_Luong = ROUND(RAND()*100, 2);
	SET @_Don_Gia = ROUND(RAND()*10000, 0);
	SET @_Thanh_Tien = @_Don_Gia * @_So_Luong;

    INSERT #tblCt(Ma_Ct, Ngay_Ct, So_Ct, So_Luong, Don_Gia, Thanh_Tien, Ma_Kho, Ma_Dt, Ma_Nx, Ma_Tte) 
    VALUES(@_Ma_Ct, @_Ngay_Ct, @_So_Ct,@_So_Luong, @_Don_Gia, @_Thanh_Tien, @_Ma_Kho, @_Ma_Dt, @_Ma_Nx, @_Ma_Tte );
    SET @_i +=1;
END

--10.	Dùng câu truy vấn SQL thêm vào bảng #tblCt các filed Ten_Vt, Ten_Kho, Ten_Dt.
--11.	Update dữ liệu cho các field Ten_Vt, Ten_Kho, Ten_Dt của bảng #tblCt.

ALTER TABLE #tblCt ADD Ten_Vt NVARCHAR(64), Ten_Kho NVARCHAR(64), Ten_Dt NVARCHAR(64)

;WITH tbl AS(
    SELECT ROW_NUMBER() OVER(ORDER BY Ngay_Ct) AS _RowNo
        , Ten_Vt, Ten_Kho, Ten_Dt
    FROM #tblCt
)
    UPDATE tbl
	SET Ten_Vt = N'Tên Vật Tư ' + FORMAT(_RowNo, '0####')
	    ,Ten_Kho = N'Tên Kho ' + FORMAT(_RowNo, '1##1#')
	    , Ten_Dt = N'Tên Khách Hàng ' + FORMAT(_RowNo, '2##2#');


--12.	Copy dữ liệu của #tblCt qua #CtHdCopy rồi xoá hết dữ liệu của #tblCt.

IF OBJECT_ID('tempdb..#CtHdCopy') IS NOT NULL DROP TABLE #CtHdCopy

SELECT Ma_Ct, Ngay_Ct, So_Ct, So_Luong, Don_Gia, Thanh_Tien, Ma_Kho, Ma_Dt, Ma_Nx, Ma_Tte, Ten_Vt, Ten_Kho, Ten_Dt
INTO #CtHdCopy
FROM #tblCt

SELECT * FROM #CtHdCopy

IF OBJECT_ID('tempdb..#tblCt') IS NOT NULL DROP TABLE #tblCt
IF OBJECT_ID('tempdb..#CtHdCopy') IS NOT NULL DROP TABLE #CtHdCopy

