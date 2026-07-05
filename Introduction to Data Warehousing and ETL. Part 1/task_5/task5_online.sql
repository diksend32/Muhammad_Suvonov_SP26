-- I did not created  Extension (file_fdw) and Server since they are created before 


CREATE FOREIGN TABLE IF NOT EXISTS sa_online_sales.ext_online_sales(
    OrderID                     TEXT,
    OrderDate                   TEXT,
    OrderStatus                 TEXT,
    OrderType                   TEXT,
    CustomerID                  TEXT,
    CustomerName                TEXT,
    CustomerEmail               TEXT,
    CustomerBirthDate           TEXT,
    CustomerAddress             TEXT,
    CustomerGender              TEXT,
    ProductID                   TEXT,
    ProductName                 TEXT,
    ProductCategory             TEXT,
    ProductBrand                TEXT,
    ProductMadeIn               TEXT,
    PaymentId                   TEXT,
    Quantity                    TEXT,
    UnitPriceInUSD              TEXT,
    TotalAmountInUSD            TEXT,
    PaymentType                 TEXT,
    Currency                    TEXT,
    USDRate                     TEXT,
    UnitPriceInLocalCurrency    TEXT,
    TotalPriceInLocalCurrency   TEXT,
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
    CourierId                   TEXT,
    CourierName                 TEXT,
    CourierEmail                TEXT,
    CourierGender               TEXT,
    CourierBirthDate            TEXT,
    BranchId                    TEXT,
    BranchName                  TEXT,
    BranchAddress               TEXT,
    BranchOpenedYear            TEXT,
    BranchSizeSqm               TEXT,
    BranchManagerId             TEXT,
    BranchManagerName           TEXT,
    BranchManagerEmail          TEXT,
    BranchManagerGender         TEXT,
    BranchManagerBirthDate      TEXT
)
SERVER f_server
OPTIONS(
filename 'C:\epam\dwh\source2.csv',
format 'csv',
header 'true',
delimiter ',',
null        ''
);


CREATE TABLE IF NOT EXISTS sa_online_sales.src_online_sales (
    OrderID                     VARCHAR(50),
    OrderDate                   VARCHAR(50),
    OrderStatus                 VARCHAR(50),
    OrderType                   VARCHAR(50),
    CustomerID                  VARCHAR(50),
    CustomerName                VARCHAR(200),
    CustomerEmail               VARCHAR(200),
    CustomerBirthDate           VARCHAR(50),
    CustomerAddress             VARCHAR(300),
    CustomerGender              VARCHAR(50),
    ProductID                   VARCHAR(50),
    ProductName                 VARCHAR(200),
    ProductCategory             VARCHAR(100),
    ProductBrand                VARCHAR(100),
    ProductMadeIn               VARCHAR(100),
    PaymentId                   VARCHAR(50),
    Quantity                    VARCHAR(50),
    UnitPriceInUSD              VARCHAR(50),
    TotalAmountInUSD            VARCHAR(50),
    PaymentType                 VARCHAR(50),
    Currency                    VARCHAR(50),
    USDRate                     VARCHAR(50),
    UnitPriceInLocalCurrency    VARCHAR(50),
    TotalPriceInLocalCurrency   VARCHAR(50),
    CityID                      VARCHAR(50),
    City                        VARCHAR(100),
    Country                     VARCHAR(100),
    Region                      VARCHAR(100),
    Continent                   VARCHAR(100),
    PostalCode                  VARCHAR(50),
    SupplierId                  VARCHAR(50),
    Supplier                    VARCHAR(200),
    SupplierEmail               VARCHAR(200),
    SupplierStreetAddress       VARCHAR(300),
    SupplierCity                VARCHAR(100),
    SupplierCountry             VARCHAR(100),
    SupplierPrimaryIndustry     VARCHAR(100),
    CourierId                   VARCHAR(50),
    CourierName                 VARCHAR(200),
    CourierEmail                VARCHAR(200),
    CourierGender               VARCHAR(50),
    CourierBirthDate            VARCHAR(50),
    BranchId                    VARCHAR(50),
    BranchName                  VARCHAR(200),
    BranchAddress               VARCHAR(300),
    BranchOpenedYear            VARCHAR(50),
    BranchSizeSqm               VARCHAR(50),
    BranchManagerId             VARCHAR(50),
    BranchManagerName           VARCHAR(200),
    BranchManagerEmail          VARCHAR(200),
    BranchManagerGender         VARCHAR(50),
    BranchManagerBirthDate      VARCHAR(50),
    _src_load_ts                TIMESTAMP DEFAULT NOW()
);

TRUNCATE sa_online_sales.src_online_sales;

INSERT INTO sa_online_sales.src_online_sales (
    OrderID, OrderDate, OrderStatus, OrderType,
    CustomerID, CustomerName, CustomerEmail, CustomerBirthDate, CustomerAddress, CustomerGender,
    ProductID, ProductName, ProductCategory, ProductBrand, ProductMadeIn,
    PaymentId, Quantity, UnitPriceInUSD, TotalAmountInUSD, PaymentType,
    Currency, USDRate, UnitPriceInLocalCurrency, TotalPriceInLocalCurrency,
    CityID, City, Country, Region, Continent, PostalCode,
    SupplierId, Supplier, SupplierEmail, SupplierStreetAddress,
    SupplierCity, SupplierCountry, SupplierPrimaryIndustry,
    CourierId, CourierName, CourierEmail, CourierGender, CourierBirthDate,
    BranchId, BranchName, BranchAddress, BranchOpenedYear, BranchSizeSqm,
    BranchManagerId, BranchManagerName, BranchManagerEmail,
    BranchManagerGender, BranchManagerBirthDate
)
SELECT
    OrderID, OrderDate, OrderStatus, OrderType,
    CustomerID, CustomerName, CustomerEmail, CustomerBirthDate, CustomerAddress, CustomerGender,
    ProductID, ProductName, ProductCategory, ProductBrand, ProductMadeIn,
    PaymentId, Quantity, UnitPriceInUSD, TotalAmountInUSD, PaymentType,
    Currency, USDRate, UnitPriceInLocalCurrency, TotalPriceInLocalCurrency,
    CityID, City, Country, Region, Continent, PostalCode,
    SupplierId, Supplier, SupplierEmail, SupplierStreetAddress,
    SupplierCity, SupplierCountry, SupplierPrimaryIndustry,
    CourierId, CourierName, CourierEmail, CourierGender, CourierBirthDate,
    BranchId, BranchName, BranchAddress, BranchOpenedYear, BranchSizeSqm,
    BranchManagerId, BranchManagerName, BranchManagerEmail,
    BranchManagerGender, BranchManagerBirthDate
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY OrderID
               ORDER BY TO_DATE(NULLIF(OrderDate,''), 'MM/DD/YYYY') DESC NULLS LAST
           ) AS rn
    FROM sa_online_sales.ext_online_sales
    WHERE NULLIF(TRIM(OrderID), '') IS NOT NULL
) deduped
WHERE rn = 1;


SELECT	*
FROM	sa_online_sales.src_online_sales
LIMIT 20