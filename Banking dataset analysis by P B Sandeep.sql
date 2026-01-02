CREATE DATABASE IF NOT EXISTS microfinance;
USE microfinance;
CREATE TABLE DimClient (
    ClientID            INT PRIMARY KEY,
    ClientName          VARCHAR(100),
    GenderID            VARCHAR(10),
    AgeBand             VARCHAR(20),     -- "Age"
    AgeYears            DECIMAL(5,2),    -- "Age _T"
    DateOfBirth         DATE,
    Caste               VARCHAR(50),
    Religion            VARCHAR(50),
    HomeOwnership       VARCHAR(20),
    ClientIncomeRange   VARCHAR(50),
    EmploymentType      VARCHAR(50),
    CreditScore         INT
);

LOAD DATA LOCAL INFILE 'C:\\Users\\anith\\Downloads\\copy file\\csv format\\Dim_Client.csv'
INTO TABLE DimClient
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@ClientID, @ClientName, @GenderID, @AgeBand, @AgeYears,
 @DateOfBirth, @Caste, @Religion, @HomeOwnership,
 @ClientIncomeRange, @EmploymentType, @CreditScore)
SET
 ClientID          = @ClientID,
 ClientName        = @ClientName,
 GenderID          = @GenderID,
 AgeBand           = @AgeBand,
 AgeYears          = @AgeYears,
 DateOfBirth       = STR_TO_DATE(@DateOfBirth, '%c/%e/%Y'),
 Caste             = @Caste,
 Religion          = @Religion,
 HomeOwnership     = @HomeOwnership,
 ClientIncomeRange = @ClientIncomeRange,
 EmploymentType    = @EmploymentType,
 CreditScore       = @CreditScore;

ALTER TABLE DimClient
MODIFY AgeYears DECIMAL(5,2) NULL;
TRUNCATE TABLE DimClient;
LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Dim_Client.csv'
INTO TABLE DimClient
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@ClientID, @ClientName, @GenderID, @AgeBand, @AgeYears,
 @DateOfBirth, @Caste, @Religion, @HomeOwnership,
 @ClientIncomeRange, @EmploymentType, @CreditScore)
SET
 ClientID          = @ClientID,
 ClientName        = @ClientName,
 GenderID          = @GenderID,
 AgeBand           = @AgeBand,
 AgeYears          = NULLIF(@AgeYears, ''),
 DateOfBirth       = STR_TO_DATE(@DateOfBirth, '%d-%m-%Y'),
 Caste             = @Caste,
 Religion          = @Religion,
 HomeOwnership     = @HomeOwnership,
 ClientIncomeRange = @ClientIncomeRange,
 EmploymentType    = @EmploymentType,
 CreditScore       = @CreditScore;
select * from DimClient;

TRUNCATE TABLE DimClient;

LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Dim_Client.csv'
INTO TABLE DimClient
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@ClientID, @ClientName, @GenderID, @AgeBand, @AgeYears,
 @DateOfBirth, @Caste, @Religion, @HomeOwnership,
 @ClientIncomeRange, @EmploymentType, @CreditScore)
SET
 ClientID   = @ClientID,
 ClientName = @ClientName,
 GenderID   = @GenderID,
 AgeBand    = @AgeBand,
 AgeYears   = NULLIF(@AgeYears, ''),

 DateOfBirth = CASE
     WHEN @DateOfBirth = '' THEN NULL
     WHEN @DateOfBirth LIKE '%/%'
          THEN STR_TO_DATE(@DateOfBirth, '%c/%e/%Y')   -- e.g. 1/1/1981
     WHEN @DateOfBirth LIKE '%-%'
          THEN STR_TO_DATE(@DateOfBirth, '%d-%m-%Y')   -- e.g. 18-05-1978
     ELSE NULL
 END,

 Caste             = @Caste,
 Religion          = @Religion,
 HomeOwnership     = @HomeOwnership,
 ClientIncomeRange = @ClientIncomeRange,
 EmploymentType    = @EmploymentType,
 CreditScore       = @CreditScore;

select * from DimClient;

CREATE TABLE DimBranch (
    BranchID                   VARCHAR(50) PRIMARY KEY,   -- e.g. 'PATIALA-100186'
    BranchName                 VARCHAR(100),
    BankName                   VARCHAR(50),
    RegionName                 VARCHAR(100),
    StateAbbr                  VARCHAR(10),
    StateName                  VARCHAR(50),
    City                       VARCHAR(50),
    CenterId                   INT,
    BHName                     VARCHAR(100),
    BranchPerformanceCategory  VARCHAR(20)
);
LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Dim_Branch.csv'
INTO TABLE DimBranch
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@BranchName, @BankName, @RegionName, @StateAbbr, @StateName,
 @City, @CenterId, @BHName, @BranchPerfCat, @BranchID)
SET
 BranchName                = @BranchName,
 BankName                  = @BankName,
 RegionName                = @RegionName,
 StateAbbr                 = @StateAbbr,
 StateName                 = @StateName,
 City                      = @City,
 CenterId                  = @CenterId,
 BHName                    = @BHName,
 BranchPerformanceCategory = @BranchPerfCat,
 BranchID                  = @BranchID;
 select * from DimBranch;
 
 CREATE TABLE DimProduct (
    ProductID        VARCHAR(20) PRIMARY KEY, 
    ProductCode      VARCHAR(20),
    PurposeCategory  VARCHAR(50),
    Term             VARCHAR(30),
    IntRate          DECIMAL(10,4),
    Grade            VARCHAR(5),
    SubGrade         VARCHAR(5)
);
LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Dim_Product.csv'
INTO TABLE DimProduct
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@ProductID, @ProductCode, @PurposeCategory, @Term, @IntRate,
 @Grade, @SubGrade)
SET
 ProductID       = @ProductID,
 ProductCode     = @ProductCode,
 PurposeCategory = @PurposeCategory,
 Term            = @Term,
 IntRate         = @IntRate,
 Grade           = @Grade,
 SubGrade        = @SubGrade;
select * from DimProduct;

CREATE TABLE FactLoan (
    AccountID          VARCHAR(20) PRIMARY KEY,   -- "Account ID"
    ClientID           INT,
    BranchName         VARCHAR(100),
    ProductID          VARCHAR(20),
    LoanAmount         DECIMAL(18,2),
    FundedAmount       DECIMAL(18,2),
    FundedAmountInv    DECIMAL(18,2),
    DisbursementDate   DATE,
    LoanStatus         VARCHAR(20),              -- Fully Paid, Active, Default, etc.
    RepaymentType      VARCHAR(50),
    CenterId           INT,
    BranchID           VARCHAR(50),
    FOREIGN KEY (ClientID) REFERENCES DimClient(ClientID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (BranchID) REFERENCES DimBranch(BranchID)
);
LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Fact_Loan.csv'
INTO TABLE FactLoan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@AccountID, @ClientID, @BranchName, @ProductID, @LoanAmount,
 @FundedAmount, @FundedAmountInv, @DisbDate, @LoanStatus,
 @RepaymentType, @CenterId, @BranchID)
SET
 AccountID        = @AccountID,
 ClientID         = @ClientID,
 BranchName       = @BranchName,
 ProductID        = @ProductID,
 LoanAmount       = @LoanAmount,
 FundedAmount     = @FundedAmount,
 FundedAmountInv  = @FundedAmountInv,
 DisbursementDate = STR_TO_DATE(@DisbDate, '%Y-%m-%d'),
 LoanStatus       = @LoanStatus,
 RepaymentType    = @RepaymentType,
 CenterId         = @CenterId,
 BranchID         = @BranchID;
select * from Factloan;

CREATE TABLE FactRepayment (
    RepaymentID        INT AUTO_INCREMENT PRIMARY KEY,
    AccountID          VARCHAR(20),
    TotalPymnt         DECIMAL(18,2),
    TotalPymntInv      DECIMAL(18,2),
    TotalRecPrncp      DECIMAL(18,2),
    TotalFees          DECIMAL(18,2),
    TotalRrecInt       DECIMAL(18,2),
    IsDelinquentLoan   CHAR(1),        -- 'Y' / 'N'
    IsDefaultLoan      CHAR(1),        -- 'Y' / 'N'
    Delinq2Yrs         INT,
    RepaymentBehavior  VARCHAR(20),    -- On-Time / Late / Very Late
    FOREIGN KEY (AccountID) REFERENCES FactLoan(AccountID)
);
LOAD DATA LOCAL INFILE 'C:/Users/anith/Downloads/copy file/csv format/Fact_Repayment.csv'
INTO TABLE FactRepayment
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@AccountID, @TotalPymnt, @TotalPymntInv, @TotalRecPrncp,
 @TotalFees, @TotalRrecInt, @IsDelinqLoan, @IsDefaultLoan,
 @Delinq2Yrs, @RepaymentBehavior)
SET
 AccountID        = @AccountID,
 TotalPymnt       = @TotalPymnt,
 TotalPymntInv    = @TotalPymntInv,
 TotalRecPrncp    = @TotalRecPrncp,
 TotalFees        = @TotalFees,
 TotalRrecInt     = @TotalRrecInt,
 IsDelinquentLoan = @IsDelinqLoan,
 IsDefaultLoan    = @IsDefaultLoan,
 Delinq2Yrs       = @Delinq2Yrs,
 RepaymentBehavior= @RepaymentBehavior;
select * from FactRepayment;

-- KPI 1, total clients 
SELECT COUNT(*) AS TotalClients
FROM DimClient;

-- KPI 2, Active Clients
select * from factloan;

Select count(*) as ActiveClients from Factloan where LoanStatus = 'Active';

SELECT COUNT(DISTINCT ClientID) AS ActiveClients
FROM FactLoan
WHERE LoanStatus = 'Active';

-- KPI 3, New clients

-- This period: 2021
SET @FromDate = '2021-01-01';
SET @ToDate   = '2021-12-31';

-- Previous period: 2020
SET @PrevFromDate = '2020-01-01';
SET @PrevToDate   = '2020-12-31';

WITH FirstLoan AS (
    SELECT
        ClientID,
        MIN(DisbursementDate) AS FirstDisbursementDate
    FROM FactLoan
    GROUP BY ClientID
)
SELECT COUNT(*) AS NewClients
FROM FirstLoan
WHERE FirstDisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 4, Client retention rate

WITH PrevPeriodClients AS (
    SELECT DISTINCT ClientID
    FROM FactLoan
    WHERE DisbursementDate BETWEEN @PrevFromDate AND @PrevToDate
),
ThisPeriodClients AS (
    SELECT DISTINCT ClientID
    FROM FactLoan
    WHERE DisbursementDate BETWEEN @FromDate AND @ToDate
),
ReturningClients AS (
    SELECT p.ClientID
    FROM PrevPeriodClients p
    JOIN ThisPeriodClients t USING (ClientID)
)
SELECT
    (SELECT COUNT(*) FROM ReturningClients)       AS ReturningClients,
    (SELECT COUNT(*) FROM PrevPeriodClients)      AS PreviousPeriodClients,
    (SELECT COUNT(*) FROM ReturningClients) /
    NULLIF((SELECT COUNT(*) FROM PrevPeriodClients),0) AS RetentionRate;
 
 
-- KPI 5, Total loan amount disbursed

SELECT
    SUM(LoanAmount) AS TotalLoanAmountDisbursed
FROM FactLoan
WHERE DisbursementDate BETWEEN @FromDate AND @ToDate;
    
-- KPI 6, Total funded amount

SELECT
    SUM(FundedAmount) AS TotalFundedAmount
FROM FactLoan;

SELECT
    SUM(FundedAmount) AS TotalFundedAmount
FROM FactLoan
WHERE DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 7, Average Laon size
SELECT
    AVG(LoanAmount) AS AverageLoanSize
FROM FactLoan;

SELECT
    AVG(LoanAmount) AS AverageLoanSize
FROM FactLoan
WHERE DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 8, Loan growth %
WITH LoanTotals AS (
    SELECT
        'ThisPeriod' AS PeriodLabel,
        SUM(LoanAmount) AS TotalAmount
    FROM FactLoan
    WHERE DisbursementDate BETWEEN @FromDate AND @ToDate

    UNION ALL

    SELECT
        'LastPeriod' AS PeriodLabel,
        SUM(LoanAmount) AS TotalAmount
    FROM FactLoan
    WHERE DisbursementDate BETWEEN @PrevFromDate AND @PrevToDate
)
SELECT
    MAX(CASE WHEN PeriodLabel = 'ThisPeriod' THEN TotalAmount END) AS ThisPeriodLoanAmount,
    MAX(CASE WHEN PeriodLabel = 'LastPeriod' THEN TotalAmount END) AS LastPeriodLoanAmount,
    (
      MAX(CASE WHEN PeriodLabel = 'ThisPeriod' THEN TotalAmount END) -
      MAX(CASE WHEN PeriodLabel = 'LastPeriod' THEN TotalAmount END)
    ) / NULLIF(
      MAX(CASE WHEN PeriodLabel = 'LastPeriod' THEN TotalAmount END), 0
    ) AS LoanGrowthPercent
FROM LoanTotals;

-- KPI 9, Total repayments collected
SELECT
    SUM(r.TotalPymnt) AS TotalRepaymentsCollected
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(r.TotalPymnt) AS TotalRepaymentsCollected
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 10, Principal recovery rate
SELECT
    SUM(r.TotalRecPrncp) / NULLIF(SUM(l.LoanAmount),0) AS PrincipalRecoveryRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(r.TotalRecPrncp) / NULLIF(SUM(l.LoanAmount),0) AS PrincipalRecoveryRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 11, Interest income
SELECT
    SUM(r.TotalRrecInt) AS InterestIncome
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(r.TotalRrecInt) AS InterestIncome
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 12, Default rate
SELECT
    SUM(CASE WHEN r.IsDefaultLoan = 'Y' THEN 1 ELSE 0 END) AS DefaultedLoans,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN r.IsDefaultLoan = 'Y' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS DefaultRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(CASE WHEN r.IsDefaultLoan = 'Y' THEN 1 ELSE 0 END) AS DefaultedLoans,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN r.IsDefaultLoan = 'Y' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS DefaultRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 13, Deliquency Rate
SELECT
    SUM(CASE WHEN r.IsDelinquentLoan = 'Y' THEN 1 ELSE 0 END) AS DelinquentLoans,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN r.IsDelinquentLoan = 'Y' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS DelinquencyRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(CASE WHEN r.IsDelinquentLoan = 'Y' THEN 1 ELSE 0 END) AS DelinquentLoans,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN r.IsDelinquentLoan = 'Y' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS DelinquencyRate
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 14, ON-time repayment %
SELECT
    SUM(CASE WHEN r.RepaymentBehavior = 'On-Time' THEN 1 ELSE 0 END) AS OnTimeRepayments,
    COUNT(*) AS TotalRepayments,
    SUM(CASE WHEN r.RepaymentBehavior = 'On-Time' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS OnTimeRepaymentPercent
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID;

SELECT
    SUM(CASE WHEN r.RepaymentBehavior = 'On-Time' THEN 1 ELSE 0 END) AS OnTimeRepayments,
    COUNT(*) AS TotalRepayments,
    SUM(CASE WHEN r.RepaymentBehavior = 'On-Time' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(*),0) AS OnTimeRepaymentPercent
FROM FactRepayment r
JOIN FactLoan l ON r.AccountID = l.AccountID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate;

-- KPI 15, loan distribution by branch
SELECT
    b.BranchName,
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM FactLoan l
JOIN DimBranch b ON l.BranchID = b.BranchID
GROUP BY b.BranchName
ORDER BY TotalLoanAmount DESC;

SELECT
    b.BranchName,
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM FactLoan l
JOIN DimBranch b ON l.BranchID = b.BranchID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate
GROUP BY b.BranchName
ORDER BY TotalLoanAmount DESC;

-- KPI 16, Branch performance category split
SELECT
    b.BranchPerformanceCategory,
    COUNT(DISTINCT b.BranchID) AS BranchCount,
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM DimBranch b
LEFT JOIN FactLoan l
  ON l.BranchID = b.BranchID
GROUP BY b.BranchPerformanceCategory;

SELECT
    b.BranchPerformanceCategory,
    COUNT(DISTINCT b.BranchID) AS BranchCount,
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM DimBranch b
LEFT JOIN FactLoan l
  ON l.BranchID = b.BranchID
 AND l.DisbursementDate BETWEEN @FromDate AND @ToDate
GROUP BY b.BranchPerformanceCategory;

-- KPI 17, Product-wise loan Volume
SELECT
    p.ProductId,   
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM FactLoan l
JOIN DimProduct p ON l.ProductID = p.ProductID
GROUP BY p.ProductId
ORDER BY TotalLoanAmount DESC;

SELECT
    p.ProductId,   
    SUM(l.LoanAmount) AS TotalLoanAmount
FROM FactLoan l
JOIN DimProduct p ON l.ProductID = p.ProductID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate
GROUP BY p.ProductId
ORDER BY TotalLoanAmount DESC;

-- KPI 18, Product profitability
SELECT
    p.ProductCode,
    SUM(r.TotalRrecInt) AS InterestIncome
FROM FactRepayment r
JOIN FactLoan l   ON r.AccountID = l.AccountID
JOIN DimProduct p ON l.ProductID = p.ProductID
GROUP BY p.ProductCode
ORDER BY InterestIncome DESC;

SELECT
    p.ProductCode,
    SUM(r.TotalRrecInt) AS InterestIncome
FROM FactRepayment r
JOIN FactLoan l   ON r.AccountID = l.AccountID
JOIN DimProduct p ON l.ProductID = p.ProductID
WHERE l.DisbursementDate BETWEEN @FromDate AND @ToDate
GROUP BY p.ProductCode
ORDER BY InterestIncome DESC;

