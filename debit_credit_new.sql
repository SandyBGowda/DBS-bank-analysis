CREATE DATABASE IF NOT EXISTS bank_analysis;
USE bank_analysis;
CREATE TABLE banking_transactions (
    customer_id        VARCHAR(50),
    customer_name      VARCHAR(100),
    account_number     BIGINT,
    transaction_date   DATE,
    transaction_type   ENUM('Credit','Debit'),
    amount             DECIMAL(15,2),
    balance            DECIMAL(15,2),
    description        VARCHAR(255),
    branch             VARCHAR(100),
    transaction_method VARCHAR(50),
    currency           VARCHAR(10),
    bank_name          VARCHAR(100)
);
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;



LOAD DATA LOCAL INFILE 'C:/Users/dhrup/Downloads/debit_credit.csv'
INTO TABLE banking_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@CustomerID, @CustomerName, @AccountNumber, @TransactionDate,
 @TransactionType, @Amount, @Balance, @Description,
 @Branch, @TransactionMethod, @Currency, @BankName)
SET
 customer_id        = @CustomerID,
 customer_name      = @CustomerName,
 account_number     = @AccountNumber,
 transaction_date   = STR_TO_DATE(@TransactionDate, '%Y-%m-%d'),
 transaction_type   = @TransactionType,
 amount             = @Amount,
 balance            = @Balance,
 description        = @Description,
 branch             = @Branch,
 transaction_method = @TransactionMethod,
 currency           = @Currency,
 bank_name          = @BankName;


SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/dhrup/Downloads/debit_credit.csv'
INTO TABLE banking_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'local_infile';

USE bank_analysis;

LOAD DATA LOCAL INFILE 'C:/Users/dhrup/Downloads/Debit_and_Credit_banking_data.csv'
INTO TABLE banking_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@CustomerID, @CustomerName, @AccountNumber, @TransactionDate,
 @TransactionType, @Amount, @Balance, @Description, @Branch,
 @TransactionMethod, @Currency, @BankName)
SET  
 customer_id        = @CustomerID,
 customer_name      = @CustomerName,
 account_number     = @AccountNumber,
 transaction_date   = STR_TO_DATE(@TransactionDate, '%Y-%m-%d'),
 transaction_type   = @TransactionType,
 amount             = @Amount,
 balance            = @Balance,
 description        = @Description,
 branch             = @Branch,
 transaction_method = @TransactionMethod,
 currency           = @Currency,
 bank_name          = @BankName;

select * from banking_transactions;




-- KPI 1, total credit amount

SELECT round(SUM(amount)/1000000,2) As total_credit_in_millions
FROM banking_transactions
WHERE transaction_type = "Credit";


-- KPI 2, Total Debit Amount

SELECT round(SUM(amount)/1000000,2) AS total_debit_in_millions
FROM banking_transactions
WHERE transaction_type = "Debit";

-- KPI 3, Credit to Debit Ratio

SELECT
    round(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) /
    SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END),2)
    AS 'Credit to Debit Ratio'
FROM banking_transactions;

-- KPI 4, Net Transaction Amount

SELECT round(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) /1000 -
    SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)/1000,2)
    AS Net_Transaction_in_thousands
FROM banking_transactions;

-- KPI 5, Account Activity Ratio

SELECT ROUND(count('Transaction Type') / sum(Balance),4)*100 AS 'Account Activity Ratio' 
from banking_transactions;


-- KPI 6, Transaction per day/week/month

SELECT DATE_FORMAT(STR_TO_DATE(Transaction_Date, '%d/%m/%Y'), '%M') AS month,
   round(sum(Amount) /1000000,2) as 'Transaction Amount(in Millions)'
FROM banking_transactions
GROUP BY DATE_FORMAT(STR_TO_DATE(Transaction_Date, '%d/%m/%Y'), '%M')
ORDER BY min(Transaction_Date);


-- KPI 7, Total Transaction Amount By Branch

SELECT branch,round(SUM(amount)/1000000,2) AS total_transaction_amount
FROM banking_transactions
GROUP BY branch
ORDER BY total_transaction_amount DESC;

-- KPI 8, Transaction Volume By Bank

SELECT bank_name,round(SUM(amount)/1000000,2) AS total_transaction_amount
FROM banking_transactions
GROUP BY bank_name
ORDER BY total_transaction_amount DESC;

-- KPI 9, Transaction Method Distribution

SELECT transaction_method,COUNT(*) AS transaction_count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM banking_transactions),2) AS percentage_of_total
FROM banking_transactions
GROUP BY transaction_method
ORDER BY transaction_count DESC;

-- KPI 10, Branch Transaction Growth 

SELECT
    Branch,ROUND(SUM(Amount) / 1000000, 2) AS "Transaction Amount (in Millions)",
    ROUND(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER (), 2) AS "Percentage (%)"
FROM banking_transactions
GROUP BY Branch
ORDER BY 2 DESC;

-- KPI 11, High-Risk Transaction Flag            

ALTER TABLE banking_transactions
ADD COLUMN risk_flag VARCHAR(20);

SELECT customer_id,customer_name,account_number,
transaction_date,transaction_type,amount,
    CASE 
        WHEN amount > 4000 THEN 'High-Risk'
        ELSE 'Normal'
    END AS risk_flag
FROM banking_transactions;

SELECT COUNT(*) AS high_risk_transactions
FROM banking_transactions
WHERE amount > 4000;


-- KPI 12, Suspicious Transaction Frequency

SELECT customer_id,customer_name,
    COUNT(*) AS suspicious_transaction_count
FROM banking_transactions
WHERE amount > 4000
GROUP BY customer_id, customer_name
ORDER BY suspicious_transaction_count DESC;

SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS suspicious_transactions
FROM banking_transactions
WHERE amount > 4000
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

