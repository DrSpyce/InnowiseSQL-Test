-- Task 0
CREATE DATABASE Innowise_Task

GO

USE Innowise_Task

CREATE TABLE Banks (
    bank_id INT PRIMARY KEY IDENTITY(1,1),
    bank_name NVARCHAR(255) NOT NULL
);

CREATE TABLE Cities (
    city_id INT PRIMARY KEY IDENTITY(1,1),
    city_name NVARCHAR(255) NOT NULL
);

CREATE TABLE Branches (
    branch_id INT PRIMARY KEY IDENTITY(1,1),
    bank_id INT,
    city_id INT,
    branch_name NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_Branches_Bank FOREIGN KEY (bank_id) REFERENCES Banks(bank_id),
    CONSTRAINT FK_Branches_City FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Social_statutes (
    status_id INT PRIMARY KEY IDENTITY(1,1),
    status_name NVARCHAR(255) NOT NULL,
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    customer_name NVARCHAR(255) NOT NULL,
    status_id INT NOT NULL,
    CONSTRAINT FK_Customers_Social_statutes FOREIGN KEY (status_id) REFERENCES Social_statutes(status_id),
);

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY IDENTITY(1,1),
    bank_id INT,
    customer_id INT,
    account_balance DECIMAL(10, 2) NOT NULL,
    account_number NVARCHAR(20) UNIQUE NOT NULL,
    CONSTRAINT FK_Accounts_Bank FOREIGN KEY (bank_id) REFERENCES Banks(bank_id),
    CONSTRAINT FK_Accounts_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Cards (
    card_id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT,
    card_balance DECIMAL(10, 2),
    card_number NVARCHAR(16) UNIQUE,
    CONSTRAINT FK_Cards_Accounts FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

GO

INSERT INTO Banks (bank_name) VALUES
    ('Milleniun'),
    ('Citibank'),
    ('Alior Bank'),
    ('PKO BP'),
    ('Idea Bank');

INSERT INTO Cities (city_name) VALUES
    ('Warsaw'),
    ('Krakow'),
    ('Katowice'),
    ('Gdansk'),
    ('Lodz');

INSERT INTO Branches (city_id, bank_id, branch_name) VALUES
    (1, 1, 'Warsaw Milleniun Central'),
    (1, 1, 'Warsaw Milleniun East'),
    (1, 2, 'Warsaw Citibank'),
    (1, 3, 'Warsaw Alior Bank'),
    (2, 1, 'Krakow Milleniun'),
    (2, 4, 'Krakow PKO BP'),
    (2, 5, 'Krakow Idea Bank'),
    (3, 5, 'Katowice Idea Bank'),
    (3, 2, 'Katowice Citibank'),
    (4, 1, 'Gdansk Milleniun'),
    (4, 5, 'Gdansk Idea Bank'),
    (5, 5, 'Lodz Alior Bank');

INSERT INTO Social_statutes (status_name) VALUES
    ('Student'),
    ('Retired'),
    ('Employee'),
    ('Homeless'),
    ('Unemployed');

INSERT INTO Customers (customer_name, status_id) VALUES
    ('David Jones', 1),
    ('Ilon Mask', 3),
    ('Steve Jobs', 2),
    ('Andrzej Duda', 5),
    ('Robert Lewandowski', 4);

INSERT INTO Accounts (bank_id, customer_id, account_number, account_balance) VALUES
    (1, 1, '12345678', 500.0),
    (1, 2, '53554423', 3000),
    (2, 2, '98765432', 112.2),
    (3, 3, '56789012', 243.2),
    (4, 4, '34567890', 999.0),
    (5, 5, '87654321', 12344.0);

INSERT INTO Cards (account_id, card_number, card_balance) VALUES
    (1, '1111222233334444', 250.0),
    (1, '1111222233330000', 250.0),
    (2, '2222333344445555', 200.2),
    (2, '2222333344441212', 234.2),
    (3, '3333444455556666', 112.2),
    (4, '4444555566667777', 243.2),
    (5, '5555666677778887', 1000.0),
    (5, '5555666677778888', 1000.0),
    (5, '5555666677778889', 1000.0),
    (6, '2222333344444445', 12344.0);

--Task 1
SELECT DISTINCT Banks.bank_name AS "Название банка"
FROM Banks
    INNER JOIN Branches ON Banks.bank_id = Branches.bank_id
    INNER JOIN Cities ON Branches.city_id = Cities.city_id
WHERE Cities.city_name = 'Warsaw'

--Task 2
SELECT 
    Cards.card_number AS "Номер карточки",
    Customers.customer_name AS "Имя владельца",
    Cards.card_balance AS "Баланс",
    Banks.bank_name AS "Название банка"
FROM Cards
    INNER JOIN Accounts ON Cards.account_id = Accounts.account_id
    INNER JOIN Customers ON Accounts.customer_id = Customers.customer_id
    INNER JOIN Banks ON Accounts.bank_id = Banks.bank_id

--Task 3
SELECT
    Accounts.account_number AS "Номер аккаунта",
    Accounts.account_balance AS "Баланс аккаунта",
    SUM(Cards.card_balance) AS "Сумма балансов по карточкам",
    Accounts.account_balance - SUM(Cards.card_balance) AS "Разница"
FROM Accounts
    LEFT JOIN Cards ON Accounts.account_id = Cards.account_id
GROUP BY Accounts.account_number, Accounts.account_balance
HAVING Accounts.account_balance <> SUM(Cards.card_balance)

--Task 4.1 Group By
SELECT
    Social_statutes.status_name AS "Соц. статус",
    COUNT(Cards.card_id) AS "Количество карт"
FROM Social_statutes
INNER JOIN Customers ON Customers.status_id = Social_statutes.status_id
LEFT JOIN Accounts ON Customers.customer_id = Accounts.customer_id
LEFT JOIN Cards ON Accounts.account_id = Cards.account_id
GROUP BY Social_statutes.status_name

--Task 4.2 Subquery
SELECT
    Social_statutes.status_name AS "Соц. статус",
    (
        SELECT COUNT(Cards.card_id)
        FROM Customers
        LEFT JOIN Accounts ON Accounts.customer_id = Customers.customer_id
        LEFT JOIN Cards ON Cards.account_id = Accounts.account_id
        WHERE Customers.status_id = Social_statutes.status_id
    ) AS "Количество карт" 
FROM Social_statutes

--Task 5
GO

CREATE PROCEDURE AddFundsToAccounts
    @SocialStatusId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Social_statutes WHERE status_id = @SocialStatusId)
    BEGIN
        RAISERROR('Социальный статус с указанным Id не существует.', 1 , 1)
        RETURN
    END

    UPDATE Accounts
    SET account_balance = account_balance + 10.00
    FROM Accounts
        INNER JOIN Customers ON Accounts.customer_id = Customers.customer_id
    WHERE Customers.status_id = @SocialStatusId;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Для указанного социального статуса нет привязанных аккаунтов.', 1 , 1)
        RETURN
    END

    PRINT 'Добавлены $10 на баланс каждого аккаунта для социального статуса с Id ' + CAST(@SocialStatusId AS NVARCHAR(10))
END

GO

SELECT
    Customers.customer_name as "Имя клиента",
    Social_statutes.status_name as "Соц. статус",
    Accounts.account_balance as "Баланс",
    Banks.bank_name as "Название банка"
FROM Customers
    INNER JOIN Social_statutes ON Customers.status_id = Social_statutes.status_id
    INNER JOIN Accounts ON Customers.customer_id = Accounts.customer_id
    INNER JOIN Banks ON Banks.bank_id = Accounts.bank_id

EXEC AddFundsToAccounts @SocialStatusId = 1

SELECT
    Customers.customer_name as "Имя клиента",
    Social_statutes.status_name as "Соц. статус",
    Accounts.account_balance as "Баланс",
    Banks.bank_name as "Название банка"
FROM Customers
    INNER JOIN Social_statutes ON Customers.status_id = Social_statutes.status_id
    INNER JOIN Accounts ON Customers.customer_id = Accounts.customer_id
    INNER JOIN Banks ON Banks.bank_id = Accounts.bank_id

--Task 6
SELECT
    Customers.customer_name AS "Имя клиента",
    Accounts.account_number AS "Номер аккаунта",
    Accounts.account_balance AS "Баланс аккаунта",
    Accounts.account_balance - SUM(Cards.card_balance) AS "Доступные средства"
FROM Customers
    INNER JOIN Accounts ON Customers.customer_id = Accounts.customer_id
    INNER JOIN Cards ON Accounts.account_id = Cards.account_id
GROUP BY Customers.customer_name, Accounts.account_number, Accounts.account_balance;

--Task 7
GO

CREATE PROCEDURE TransferFundsToCard
    @AccountNumber NVARCHAR(20),
    @card_number NVARCHAR(16),
    @Amount DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_number = @AccountNumber)
        BEGIN
            RAISERROR('Неправильный номер счета.', 1, 1)
            ROLLBACK
            RETURN
        END

        DECLARE @Account_Id INT
        SELECT @Account_Id = account_id FROM Accounts WHERE account_number = @AccountNumber
        
        IF NOT EXISTS (SELECT 1 FROM Cards WHERE account_id = @Account_Id AND card_number = @card_number)
        BEGIN
            RAISERROR('Такая карта не привязана к данному счету.', 1, 1)
            ROLLBACK
            RETURN
        END

        DECLARE @AvailableFunds DECIMAL(10, 2);
        SELECT @AvailableFunds =  Accounts.account_balance - SUM(Cards.card_balance) 
        FROM Accounts
            INNER JOIN Cards ON Accounts.account_id = Cards.account_id
        WHERE account_number = @AccountNumber
        GROUP BY Accounts.account_balance

        IF @AvailableFunds < @Amount    
        BEGIN
            RAISERROR('Недостаточно средств на аккаунте для перевода.', 1, 1)
            ROLLBACK
            RETURN
        END

        UPDATE Cards
        SET Cards.card_balance = Cards.card_balance + @Amount
        WHERE card_number = @card_number;

        COMMIT
    END TRY
    BEGIN CATCH
        RAISERROR('Произошла ошибка при выполнении перевода.', 1, 1)
        ROLLBACK
    END CATCH
END

GO

SELECT
    Customers.customer_name AS "Имя клиента",
    Accounts.account_number AS "Номер аккаунта",
    Accounts.account_balance AS "Баланс аккаунта",
    Cards.card_number AS "Номер карты", 
    Cards.card_balance AS "Баланс карты"
FROM Customers
    LEFT JOIN Accounts ON Customers.customer_id = Accounts.customer_id
    LEFT JOIN Cards ON Accounts.account_id = Cards.account_id


EXEC TransferFundsToCard @AccountNumber = '53554423', @card_number = '2222333344445555', @Amount = 1500.00

SELECT
    Customers.customer_name AS "Имя клиента",
    Accounts.account_number AS "Номер аккаунта",
    Accounts.account_balance AS "Баланс аккаунта",
    Cards.card_number AS "Номер карты", 
    Cards.card_balance AS "Баланс карты"
FROM Customers
    LEFT JOIN Accounts ON Customers.customer_id = Accounts.customer_id
    LEFT JOIN Cards ON Accounts.account_id = Cards.account_id

--Task 8
GO

CREATE TRIGGER PreventAccountBalanceUpdate
ON Accounts
AFTER UPDATE
AS
BEGIN
    DECLARE @AccountId INT
    DECLARE @NewBalance DECIMAL(10, 2)
    DECLARE @TotalCardBalance DECIMAL(10, 2)

    SELECT @AccountId = i.account_id, @NewBalance = i.account_balance, @TotalCardBalance = SUM(Cards.card_balance)
    FROM INSERTED i
    LEFT JOIN Cards ON i.account_id = Cards.account_id
    GROUP BY i.account_id, i.account_balance

    IF @NewBalance < @TotalCardBalance
    BEGIN
        RAISERROR('Нельзя установить баланс аккаунта меньше, чем сумма балансов карт.', 1, 1)
        ROLLBACK TRANSACTION
    END
END

GO

SELECT
    account_number as "Номер аккаунта",
    account_balance as "Баланс аккаунта",
    SUM(Cards.card_balance) AS "Сумма по картам"
FROM Accounts
    LEFT JOIN Cards ON Accounts.account_id = Cards.account_id
GROUP BY account_number, account_balance;

UPDATE Accounts SET account_balance = 0 WHERE account_number = 12345678

GO

CREATE TRIGGER PreventCardBalanceUpdate
ON Cards
AFTER UPDATE
AS
BEGIN
    DECLARE @CardId INT;
    DECLARE @NewBalance DECIMAL(10, 2);
    DECLARE @AccountBalance DECIMAL(10, 2);
    DECLARE @AccountNumber NVARCHAR(20)

    SELECT 
        @CardId = i.card_id, 
        @AccountBalance = Accounts.account_balance, 
        @AccountNumber = Accounts.account_number
    FROM INSERTED i
    INNER JOIN Accounts ON i.account_id = Accounts.account_id;

    SELECT @NewBalance = SUM(Cards.card_balance)
    FROM Accounts
        INNER JOIN Cards ON Cards.account_id = Accounts.account_id
    WHERE Accounts.account_number = @AccountNumber

    IF @NewBalance > @AccountBalance
    BEGIN
        RAISERROR('Нельзя установить баланс карты больше, чем баланс аккаунта.', 0, 0);
        ROLLBACK TRANSACTION;
    END;
END;

GO

SELECT
    account_number as "Номер аккаунта",
    account_balance as "Баланс аккаунта",
    Cards.card_number AS "Номер карты",
    Cards.card_balance AS "Баланс карты"
FROM Accounts
    LEFT JOIN Cards ON Accounts.account_id = Cards.account_id

UPDATE Cards SET card_balance = 1000 WHERE card_number = 1111222233330000
