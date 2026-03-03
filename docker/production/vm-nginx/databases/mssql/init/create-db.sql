-- Run as sa on first start

IF DB_ID('mdriven_db') IS NULL
BEGIN
    CREATE DATABASE [mdriven_db];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'mdriven')
BEGIN
    CREATE LOGIN [mdriven] WITH PASSWORD = '#MDs123456';
END
GO

USE [mdriven_db];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'mdriven')
BEGIN
    CREATE USER [mdriven] FOR LOGIN [mdriven];
END
GO

ALTER ROLE [db_owner] ADD MEMBER [mdriven];
GO