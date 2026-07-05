CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS f_server FOREIGN DATA WRAPPER file_fdw;
CREATE SCHEMA  IF NOT EXISTS sa_offline_sales;

CREATE FOREIGN TABLE IF NOT EXISTS sa_offline_sales.ext_offline_sales(
    OrderID                     TEXT,
    OrderDate                   TEXT,
    OrderStatus                 TEXT,
    OrderType                   TEXT,
    CustomerID                  TEXT,
    CustomerName                TEXT,
    DateOfBirth                 TEXT,
    Gender                      TEXT,
    CustomerEmail               TEXT,
    ProductID                   TEXT,
    ProductName                 TEXT,
    Category                    TEXT,
    Brand                       TEXT,
    MadeIn                      TEXT,
    PaymentId                   TEXT,
    PaymentType                 TEXT,  
    Quantity                    TEXT,
    UnitPriceInUSD              TEXT,
    TotalAmountUSD              TEXT,
    Currency                    TEXT,
    USDRate                     TEXT,
    UnitPriceInLocalCurrency    TEXT,
    TotalPriceInLocalCurrency   TEXT,
    BranchId                    TEXT,
    BranchName                  TEXT,
    BranchAddress               TEXT,
    BranchOpenedYear            TEXT,
    BranchSizeSqm               TEXT,
    BranchManagerId             TEXT,
    BranchManagerName           TEXT,
    BranchManagerEmail          TEXT,
    BranchManagerGender         TEXT,
    BranchManagerBirthDate      TEXT,
    CityID                      TEXT,
    City                        TEXT,
    Country                     TEXT,
    Region                      TEXT,
    Continent                   TEXT,
    PostalCode                  TEXT,
    SupplierId                  TEXT,
    Supplier                    TEXT,
    SupplierEmail               TEXT,
    SupplierStreetAddress       TEXT,
    SupplierCity                TEXT,
    SupplierCountry             TEXT,
    SupplierPrimaryIndustry     TEXT,
    SellerId                    TEXT,
    SellerName                  TEXT,
    SellerEmail                 TEXT,
    SellerGender                TEXT,
    SellerBirthDate             TEXT
)
SERVER f_server 
OPTIONS(
filename 'C:\epam\dwh\source1.csv',
format 'csv',
header 'true',
delimiter ',',
null        ''
);


SELECT * 
FROM  sa_offline_sales.ext_offline_sales
LIMIT 10;



CREATE TABLE sa_offline_sales.src_offline_sales (
    OrderID                     VARCHAR(50),
    OrderDate                   VARCHAR(50),
    OrderStatus                 VARCHAR(50),
    OrderType                   VARCHAR(50),
    CustomerID                  VARCHAR(50),
    CustomerName                VARCHAR(200),
    DateOfBirth                 VARCHAR(50),
    Gender                      VARCHAR(50),
    CustomerEmail               VARCHAR(200),
    ProductID                   VARCHAR(50),
    ProductName                 VARCHAR(200),
    Category                    VARCHAR(100),
    Brand                       VARCHAR(100),
    MadeIn                      VARCHAR(100),
    PaymentId                   VARCHAR(50),
    PaymentType                 VARCHAR(50),
    Quantity                    VARCHAR(50),
    UnitPriceInUSD              VARCHAR(50),
    TotalAmountUSD               VARCHAR(50),
    Currency                     VARCHAR(50),
    USDRate                      VARCHAR(50),
    UnitPriceInLocalCurrency     VARCHAR(50),
    TotalPriceInLocalCurrency    VARCHAR(50),
    BranchId                     VARCHAR(50),
    BranchName                   VARCHAR(200),
    BranchAddress                VARCHAR(300),
    BranchOpenedYear             VARCHAR(50),
    BranchSizeSqm                VARCHAR(50),
    BranchManagerId              VARCHAR(50),
    BranchManagerName            VARCHAR(200),
    BranchManagerEmail           VARCHAR(200),
    BranchManagerGender          VARCHAR(50),
    BranchManagerBirthDate       VARCHAR(50),
    CityID                       VARCHAR(50),
    City                        VARCHAR(100),
    Country                      VARCHAR(100),
    Region                       VARCHAR(100),
    Continent                    VARCHAR(100),
    PostalCode                   VARCHAR(50),
    SupplierId                   VARCHAR(50),
    Supplier                     VARCHAR(200),
    SupplierEmail                VARCHAR(200),
    SupplierStreetAddress        VARCHAR(300),
    SupplierCity                 VARCHAR(100),
    SupplierCountry              VARCHAR(100),
    SupplierPrimaryIndustry      VARCHAR(100),
    SellerId                     VARCHAR(50),
    SellerName                   VARCHAR(200),
    SellerEmail                  VARCHAR(200),
    SellerGender                 VARCHAR(50),
    SellerBirthDate              VARCHAR(50),
    _src_load_ts                 TIMESTAMP DEFAULT NOW()
);

TRUNCATE sa_offline_sales.src_offline_sales;

INSERT INTO sa_offline_sales.src_offline_sales (
    OrderID, OrderDate, OrderStatus, OrderType,
    CustomerID, CustomerName, DateOfBirth, Gender, CustomerEmail,
    ProductID, ProductName, Category, Brand, MadeIn,
    PaymentId, PaymentType, Quantity,
    UnitPriceInUSD, TotalAmountUSD, Currency, USDRate,
    UnitPriceInLocalCurrency, TotalPriceInLocalCurrency,
    BranchId, BranchName, BranchAddress, BranchOpenedYear, BranchSizeSqm,
    BranchManagerId, BranchManagerName, BranchManagerEmail,
    BranchManagerGender, BranchManagerBirthDate,
    CityID, City, Country, Region, Continent, PostalCode,
    SupplierId, Supplier, SupplierEmail, SupplierStreetAddress,
    SupplierCity, SupplierCountry, SupplierPrimaryIndustry,
    SellerId, SellerName, SellerEmail, SellerGender, SellerBirthDate
)
SELECT
    OrderID, OrderDate, OrderStatus, OrderType,
    CustomerID, CustomerName, DateOfBirth, Gender, CustomerEmail,
    ProductID, ProductName, Category, Brand, MadeIn,
    PaymentId, PaymentType, Quantity,
    UnitPriceInUSD, TotalAmountUSD, Currency, USDRate,
    UnitPriceInLocalCurrency, TotalPriceInLocalCurrency,
    BranchId, BranchName, BranchAddress, BranchOpenedYear, BranchSizeSqm,
    BranchManagerId, BranchManagerName, BranchManagerEmail,
    BranchManagerGender, BranchManagerBirthDate,
    CityID, City, Country, Region, Continent, PostalCode,
    SupplierId, Supplier, SupplierEmail, SupplierStreetAddress,
    SupplierCity, SupplierCountry, SupplierPrimaryIndustry,
    SellerId, SellerName, SellerEmail, SellerGender, SellerBirthDate
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY OrderID
               ORDER BY TO_DATE(NULLIF(OrderDate,''), 'MM/DD/YYYY') DESC NULLS LAST
           ) AS rn
    FROM sa_offline_sales.ext_offline_sales
    WHERE NULLIF(TRIM(OrderID), '') IS NOT NULL
) deduped
WHERE rn = 1;




