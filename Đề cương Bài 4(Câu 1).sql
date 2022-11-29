---Câu 1 : Thêm bảng tạm #B20Warehouse (Danh mục kho), thêm dữ liệu. 
--Viết T-SQL kiểm tra mã lồng nhau như AB lồng trong ABC, Mã BC không phải là mà lồng trong ABC.

SET NOCOUNT ON;
DROP TABLE IF EXISTS #B20Warehouse 

CREATE TABLE #B20Warehouse (Stt INT, WareHouseCode VARCHAR(16), Description NVARCHAR(256)) 

INSERT #B20Warehouse (Stt, WareHouseCode) 
VALUES (0001, 'A')
    	,(0002, 'B')
		  ,(0003, 'C')
		  ,(0004, 'ABC');

DECLARE @_Str_A VARCHAR (8), @_Stt_A INT
		, @_Stt_ABC INT, @_CHARINDEX VARCHAR(16)
		, @_Str_ABC VARCHAR(8);

SELECT @_Str_A = WareHouseCode
	  ,@_Stt_A = Stt
FROM #B20WareHouse
WHERE WareHouseCode = 'A'

SELECT @_Str_ABC = WareHouseCode
	  ,@_Stt_ABC = Stt
FROM #B20WareHouse
WHERE WareHouseCode = 'ABC'

SELECT @_CHARINDEX = CHARINDEX(@_Str_A, @_Str_ABC);

IF @_CHARINDEX != 0
BEGIN
	UPDATE #B20WareHouse 
	SET Description = CASE WHEN WareHouseCode = @_Str_ABC THEN N'Có Mã Lồng tại dòng ' + CAST(@_Stt_A AS VARCHAR)
							           WHEN WareHouseCode = @_Str_A THEN N'Mã "A" Lồng trong ' + @_Str_ABC 
                    END
	FROM #B20WareHouse
END

SELECT * FROM #B20WareHouse
