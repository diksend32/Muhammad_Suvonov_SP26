-- STAGING LAYER: Source 2 – Online Sales



CREATE EXTENSION IF NOT EXISTS file_fdw;

-- 1. Foreign server for flat-file access
CREATE SERVER IF NOT EXISTS fs_online_sales
    FOREIGN DATA WRAPPER file_fdw;

-- 2. Schema
CREATE SCHEMA IF NOT EXISTS sa_online_sales;


DROP FOREIGN TABLE IF EXISTS sa_online_sales.ext_online_sales;

CREATE FOREIGN TABLE sa_online_sales.ext_online_sales (
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
SERVER fs_online_sales
OPTIONS (
    filename    '/data/source2_online_sales.csv',   -- adjust path
    format      'csv',
    header      'true',
    delimiter   ',',
    null        ''
);


DROP TABLE IF EXISTS sa_online_sales.src_online_sales;

CREATE TABLE sa_online_sales.src_online_sales (
    OrderID                     TEXT            NOT NULL,
    OrderDate                   DATE,
    OrderStatus                 TEXT,
    OrderType                   TEXT,
    CustomerID                  TEXT,
    CustomerName                TEXT,
    CustomerEmail               TEXT,
    CustomerBirthDate           DATE,
    CustomerAddress             TEXT,
    CustomerGender              TEXT,
    ProductID                   TEXT,
    ProductName                 TEXT,
    ProductCategory             TEXT,
    ProductBrand                TEXT,
    ProductMadeIn               TEXT,
    PaymentId                   TEXT,
    Quantity                    INTEGER,
    UnitPriceInUSD              NUMERIC(18,4),
    TotalAmountInUSD            NUMERIC(18,4),
    PaymentType                 TEXT,
    Currency                    TEXT,
    USDRate                     NUMERIC(18,6),
    UnitPriceInLocalCurrency    NUMERIC(18,4),
    TotalPriceInLocalCurrency   NUMERIC(18,4),
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
    CourierBirthDate            DATE,
    BranchId                    TEXT,
    BranchName                  TEXT,
    BranchAddress               TEXT,
    BranchOpenedYear            INTEGER,
    BranchSizeSqm               NUMERIC(12,2),
    BranchManagerId             TEXT,
    BranchManagerName           TEXT,
    BranchManagerEmail          TEXT,
    BranchManagerGender         TEXT,
    BranchManagerBirthDate      DATE,

    -- Audit
    _src_load_ts    TIMESTAMP DEFAULT NOW()
);


TRUNCATE sa_online_sales.src_online_sales;

INSERT INTO sa_online_sales.src_online_sales (
    OrderID, OrderDate, OrderStatus, OrderType,
    CustomerID, CustomerName, CustomerEmail, CustomerBirthDate,
    CustomerAddress, CustomerGender,
    ProductID, ProductName, ProductCategory, ProductBrand, ProductMadeIn,
    PaymentId, Quantity,
    UnitPriceInUSD, TotalAmountInUSD, PaymentType,
    Currency, USDRate,
    UnitPriceInLocalCurrency, TotalPriceInLocalCurrency,
    CityID, City, Country, Region, Continent, PostalCode,
    SupplierId, Supplier, SupplierEmail, SupplierStreetAddress,
    SupplierCity, SupplierCountry, SupplierPrimaryIndustry,
    CourierId, CourierName, CourierEmail, CourierGender, CourierBirthDate,
    BranchId, BranchName, BranchAddress, BranchOpenedYear, BranchSizeSqm,
    BranchManagerId, BranchManagerName, BranchManagerEmail,
    BranchManagerGender, BranchManagerBirthDate
)
SELECT
    OrderID,
    TO_DATE(NULLIF(OrderDate,''),              'MM/DD/YYYY'),
    OrderStatus,
    OrderType,
    CustomerID,
    CustomerName,
    CustomerEmail,
    TO_DATE(NULLIF(CustomerBirthDate,''),      'MM/DD/YYYY'),
    CustomerAddress,
    CustomerGender,
    ProductID,
    ProductName,
    ProductCategory,
    ProductBrand,
    ProductMadeIn,
    PaymentId,
    NULLIF(Quantity,'')::INTEGER,
    NULLIF(UnitPriceInUSD,'')::NUMERIC(18,4),
    NULLIF(TotalAmountInUSD,'')::NUMERIC(18,4),
    PaymentType,
    Currency,
    NULLIF(USDRate,'')::NUMERIC(18,6),
    NULLIF(UnitPriceInLocalCurrency,'')::NUMERIC(18,4),
    NULLIF(TotalPriceInLocalCurrency,'')::NUMERIC(18,4),
    CityID,
    City,
    Country,
    Region,
    Continent,
    PostalCode,
    SupplierId,
    Supplier,
    SupplierEmail,
    SupplierStreetAddress,
    SupplierCity,
    SupplierCountry,
    SupplierPrimaryIndustry,
    CourierId,
    CourierName,
    CourierEmail,
    CourierGender,
    TO_DATE(NULLIF(CourierBirthDate,''),       'MM/DD/YYYY'),
    BranchId,
    BranchName,
    BranchAddress,
    NULLIF(BranchOpenedYear,'')::INTEGER,
    NULLIF(BranchSizeSqm,'')::NUMERIC(12,2),
    BranchManagerId,
    BranchManagerName,
    BranchManagerEmail,
    BranchManagerGender,
    TO_DATE(NULLIF(BranchManagerBirthDate,''), 'MM/DD/YYYY')
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY OrderID
               ORDER BY TO_DATE(NULLIF(OrderDate,''), 'MM/DD/YYYY') DESC NULLS LAST,
                        NULLIF(TotalAmountInUSD,'')::NUMERIC DESC NULLS LAST
           ) AS rn
    FROM sa_online_sales.ext_online_sales
    WHERE NULLIF(TRIM(OrderID), '') IS NOT NULL
) deduped
WHERE rn = 1;

-- Quick row count sanity check
SELECT 'src_online_sales row count' AS info, COUNT(*) AS cnt
FROM sa_online_sales.src_online_sales;
