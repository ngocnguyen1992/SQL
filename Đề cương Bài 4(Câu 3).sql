SET NOCOUNT ON;
DROP TABLE IF EXISTS #B30AccDoc;
DROP TABLE IF EXISTS #B30AccDocSales;
DROP TABLE IF EXISTS #B20Customer;
DROP TABLE IF EXISTS #B20Item;
DROP TABLE IF EXISTS #temp;

CREATE TABLE #B30AccDoc (Id INT IDENTITY, DocDate DATE, DocNo VARCHAR(32), Description NVARCHAR(MAX), CustomerCode VARCHAR(32));
CREATE TABLE #B30AccDocSales (Id INT IDENTITY, ItemCode VARCHAR(64), Quantity INT, Amount NUMERIC(18,2));
CREATE TABLE #B20Customer (Code VARCHAR(32), Name NVARCHAR(128));
CREATE TABLE #B20Item (Code VARCHAR(32), Name NVARCHAR(128));

INSERT INTO #B20Customer VALUES ('ABC', N'Cty ABC'), ('BCD', N'Cty BCD');

DECLARE @_i INT = 1, @_Code VARCHAR(32), @_Name NVARCHAR(128);

WHILE @_i <= 4
BEGIN
	SELECT  @_Code = 'HD', @_Name = N'HD ' + FORMAT(@_i, '0#');
	INSERT #B20Item (Code, Name) Values (@_Code, @_Name);
	SET @_i+=1;
END

INSERT #B30AccDoc (DocDate, DocNo, Description, CustomerCode) 
VALUES ('011110','001', N'Bán Hàng 01', 'ABC')
		,('021110','002', N'Bán Hàng 02', 'ABC')

INSERT #B30AccDoc (DocDate, DocNo, Description, CustomerCode) 
VALUES ('010310','003', N'Bán Hàng 03', 'BCD')
		,('020310','004', N'Bán Hàng 04', 'BCD')

INSERT #B30AccDocSales (ItemCode, Quantity, Amount)
VALUES ('HD', 10, 10000000)
	 , ('HD', 5, 5000000)
	 , ('HD', 8, 20000000)
	 , ('HD', 5, 15000000);

CREATE TABLE #temp (Id INT Identity, No INT, Code VARCHAR(32), DocDate DATE, DocNo VARCHAR(32), Description NVARCHAR(MAX)
					, Quantity INT, Amount NUMERIC(18,2), Discount NUMERIC(18,2));
						
	INSERT #temp (Code, Description, Quantity, Amount)
	SELECT ad.CustomerCode, MAX(c.Name), SUM(ads.Quantity), SUM(ads.Amount)
	FROM #B20Customer c JOIN #B30AccDoc ad
	ON c.Code = ad.CustomerCode  JOIN #B30AccDocSales ads 
	ON ad.Id = ads.Id
	WHERE ad.CustomerCode = 'ABC'
	GROUP BY ad.CustomerCode

	INSERT #temp(Code, DocDate, DocNo, Description, Quantity, Amount)
	SELECT ads.ItemCode, ad.DocDate, ad.DocNo, ad.Description, ads.Quantity, ads.Amount
	FROM #B30AccDoc ad JOIN #B30AccDocSales ads ON ad.Id = ads.Id
	WHERE ad.CustomerCode = 'ABC'

	INSERT #temp (Code, Description, Quantity, Amount)
	SELECT ad.CustomerCode, MAX(c.Name), SUM(ads.Quantity), SUM(ads.Amount)
	FROM #B20Customer c JOIN #B30AccDoc ad 
	ON c.Code = ad.CustomerCode JOIN #B30AccDocSales ads 
	ON ad.Id = ads.Id 
	WHERE ad.CustomerCode = 'BCD'
	GROUP BY ad.CustomerCode

	INSERT #temp(Code, DocDate, DocNo, Description, Quantity, Amount)
	SELECT ads.ItemCode, ad.DocDate, ad.DocNo, ad.Description, ads.Quantity, ads.Amount
	FROM #B30AccDoc ad JOIN #B30AccDocSales ads ON ad.Id = ads.Id
	WHERE ad.CustomerCode = 'BCD'

	DECLARE @_Discount_10tr Numeric(18,2), @_Discount Numeric(18,2)
		, @_Discount_20tr Numeric(18,2), @_j INT;

	SELECT @_Discount_10tr = 10000000, @_Discount_20tr = 20000000;
	UPDATE #temp
	SET Discount = CASE WHEN t.Amount < @_Discount_10tr THEN t.Amount * 3 / 100
						WHEN t.Amount < @_Discount_20tr THEN t.Amount * 5 / 100
						WHEN t.Amount >= @_Discount_20tr THEN t.Amount * 7 / 100
					END
	FROM #temp t JOIN #B30AccDocSales ads ON t.Code = ads.ItemCode

	UPDATE #temp 
	SET Discount = CASE WHEN Description = 'Cty ABC' 
							THEN (SELECT SUM(Discount) 
							FROM #temp t JOIN #B30AccDoc ad 
							ON t.DocNo = ad.DocNo 
							WHERE ad.CustomerCode = 'ABC')  
						WHEN Description = 'Cty BCD'
							THEN (SELECT SUM(Discount) 
							FROM #temp t JOIN #B30AccDoc ad 
							ON t.DocNo = ad.DocNo 
							WHERE ad.CustomerCode = 'BCD')
					END
	FROM #temp 
	WHERE (Code = 'ABC') OR (Code = 'BCD')

	;WITH tbl AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY ad.CustomerCode ORDER BY CustomerCode ASC ) AS No
	FROM #temp t JOIN #B30AccDoc ad ON t.DocNo = ad.DocNo
	)
	UPDATE #temp
	SET #temp.No = tbl.No
	FROM tbl
	WHERE Code = 'HD'

DECLARE @_SUM_Quantity INT, @_SUM_Amount NUMERIC(18,2), @_SUM_Discount NUMERIC(18,2);

SELECT @_SUM_Quantity = SUM(Quantity) FROM #temp WHERE Code IN (SELECT CustomerCode FROM #B30AccDoc)
SELECT	@_SUM_Amount = SUM(Amount) FROM #temp WHERE Code IN (SELECT CustomerCode FROM #B30AccDoc)
SELECT	@_SUM_Discount = SUM(Discount) FROM #temp WHERE Code IN (SELECT CustomerCode FROM #B30AccDoc)

INSERT #temp(Description, Quantity, Amount, Discount)
VALUES (N'Tổng Cộng : ', @_SUM_Quantity, @_SUM_Amount , @_SUM_Discount)

SELECT No, Code, DocDate, DocNo, Description, Quantity, Amount, Discount 
FROM #temp 
ORDER BY Id
