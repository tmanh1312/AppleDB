-- following is the code for creating a synthetic trx for populating CART
-- the first bit of code INSERTS an additional 164,010 people into the tblCUSTOMER table
-- 164010
INSERT INTO tblCUSTOMER (CustomerFname, CustomerLname, CustomerAddress, CustomerCity, CustomerCounty, CustomerState, CustomerZip, AreaCode, Email, BusinessName, DateOfBirth, PhoneNum)
SELECT Top 164010 CustomerFname, CustomerLname, CustomerAddress, CustomerCity, CustomerCounty, CustomerState, CustomerZip, AreaCode, Email, BusinessName, DateOfBirth, PhoneNum
FROM Peeps.dbo.tblCUSTOMER
-- here is the code to create the wrapper
CREATE OR ALTER PROCEDURE wrapper_uspPopCart
@Run INT
AS

DECLARE @RandDate INT
DECLARE @P_Name varchar(50), @CustID_OUT INT, @GetDate Date, @Q INT
DECLARE @ProdCOUNT INT = (SELECT COUNT(*) FROM tblPRODUCT)
DECLARE @CustCOUNT INT = (SELECT COUNT(*) FROM tblCUSTOMER)
DECLARE @ProdPK INT, @CustPK INT
DECLARE @F varchar(30), @L varchar(30), @Birthy Date, @Zippy varchar(12)  

WHILE @Run > 0
BEGIN
    SET @CUSTPK = (SELECT RAND() * @CustCOUNT +1)
    SET @F = (SELECT CustomerFname FROM tblCUSTOMER WHERE CustID = @CUSTPK)
    SET @L = (SELECT CustomerLname FROM tblCUSTOMER WHERE CustID = @CUSTPK)
    SET @Birthy = (SELECT DateOfBirth FROM tblCUSTOMER WHERE CustID = @CUSTPK)
    SET @Zippy = (SELECT CustomerZip FROM tblCUSTOMER WHERE CustID = @CUSTPK)
    SET @ProdPK = (SELECT RAND() * @ProdCOUNT +1)
    IF @ProdPK < 1 OR @ProdPK > 13
        BEGIN
            SET @ProdPK = 6
        END
    SET @P_Name = (SELECT ProdName FROM tblPRODUCT WHERE ProdID = @ProdPK)
    SET @Q = (SELECT RAND() * 30)
    SET @RandDate = (SELECT RAND() * 10000)
    SET @GetDate = (SELECT DateAdd(Day, -@RandDate, GetDate()))

    EXEC uspGetCustID 
    @Fname = @F,
    @Lname = @L,
    @DOB = @Birthy,
    @Zip = @Zippy,
    @CustID = @CustID_OUT OUT

    EXEC uspPopCart
    @ProdName = @P_Name,
    @CustID = @CustID_OUT,
    @Date = @GetDate,
    @Qty = @Q

    SET @Run = @Run -1
END
PRINT 'ALL DONE!!'
--- test run
EXEC wrapper_uspPopCart 3000