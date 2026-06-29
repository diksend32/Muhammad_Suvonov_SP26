-- ============================================================
-- STAGING LAYER: Source 1 – Offline Sales
-- Schema: sa_offline_sales
-- External table: ext_offline_sales
-- Source table:   src_offline_sales
-- ============================================================

-- 0. Enable file_fdw extension (run once per database)
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- 1. Foreign server for flat-file access
CREATE SERVER IF NOT EXISTS fs_offline_sales
    FOREIGN DATA WRAPPER file_fdw;

-- 2. Schema
CREATE SCHEMA IF NOT EXISTS sa_offline_sales;

-- ============================================================
-- 3. EXTERNAL (FOREIGN) TABLE
--    Points at the raw CSV drop location.
--    Adjust filename / delimiter to match your actual file.
-- ============================================================
DROP FOREIGN TABLE IF EXISTS sa_offline_sales.ext_offline_sales;

CREATE FOREIGN TABLE sa_offline_sales.ext_offline_sales (
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
    PaymentType                 TEXT,   -- "Payment type" mapped to valid identifier
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
SERVER fs_offline_sales
OPTIONS (
    filename    '/data/source1_offline_sales.csv',  -- adjust path
    format      'csv',
    header      'true',
    delimiter   ',',
    null        ''
);

-- ============================================================
-- 4. SOURCE TABLE  (typed, deduplicated)
-- ============================================================
DROP TABLE IF EXISTS sa_offline_sales.src_offline_sales;

CREATE TABLE sa_offline_sales.src_offline_sales (
    OrderID                     TEXT            NOT NULL,
    OrderDate                   DATE,
    OrderStatus                 TEXT,
    OrderType                   TEXT,
    CustomerID                  TEXT,
    CustomerName                TEXT,
    DateOfBirth                 DATE,
    Gender                      TEXT,
    CustomerEmail               TEXT,
    ProductID                   TEXT,
    ProductName                 TEXT,
    Category                    TEXT,
    Brand                       TEXT,
    MadeIn                      TEXT,
    PaymentId                   TEXT,
    PaymentType                 TEXT,
    Quantity                    INTEGER,
    UnitPriceInUSD              NUMERIC(18,4),
    TotalAmountUSD              NUMERIC(18,4),
    Currency                    TEXT,
    USDRate                     NUMERIC(18,6),
    UnitPriceInLocalCurrency    NUMERIC(18,4),
    TotalPriceInLocalCurrency   NUMERIC(18,4),
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
    SellerBirthDate             DATE,

    -- Audit
    _src_load_ts    TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 5. LOAD: Deduplicate on INSERT
--    Deduplication key: OrderID (natural business key).
--    Within duplicates, keep the row with the latest OrderDate;
--    ties broken by row_number() to guarantee a single winner.
-- ============================================================
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
    OrderID,
    TO_DATE(NULLIF(OrderDate,''),         'MM/DD/YYYY'),
    OrderStatus,
    OrderType,
    CustomerID,
    CustomerName,
    TO_DATE(NULLIF(DateOfBirth,''),       'MM/DD/YYYY'),
    Gender,
    CustomerEmail,
    ProductID,
    ProductName,
    Category,
    Brand,
    MadeIn,
    PaymentId,
    PaymentType,
    NULLIF(Quantity,'')::INTEGER,
    NULLIF(UnitPriceInUSD,'')::NUMERIC(18,4),
    NULLIF(TotalAmountUSD,'')::NUMERIC(18,4),
    Currency,
    NULLIF(USDRate,'')::NUMERIC(18,6),
    NULLIF(UnitPriceInLocalCurrency,'')::NUMERIC(18,4),
    NULLIF(TotalPriceInLocalCurrency,'')::NUMERIC(18,4),
    BranchId,
    BranchName,
    BranchAddress,
    NULLIF(BranchOpenedYear,'')::INTEGER,
    NULLIF(BranchSizeSqm,'')::NUMERIC(12,2),
    BranchManagerId,
    BranchManagerName,
    BranchManagerEmail,
    BranchManagerGender,
    TO_DATE(NULLIF(BranchManagerBirthDate,''), 'MM/DD/YYYY'),
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
    SellerId,
    SellerName,
    SellerEmail,
    SellerGender,
    TO_DATE(NULLIF(SellerBirthDate,''), 'MM/DD/YYYY')
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY OrderID
               ORDER BY TO_DATE(NULLIF(OrderDate,''), 'MM/DD/YYYY') DESC NULLS LAST,
                        NULLIF(TotalAmountUSD,'')::NUMERIC DESC NULLS LAST
           ) AS rn
    FROM sa_offline_sales.ext_offline_sales
    WHERE NULLIF(TRIM(OrderID), '') IS NOT NULL   -- skip blank header rows / nulls
) deduped
WHERE rn = 1;

-- Quick row count sanity check
SELECT 'src_offline_sales row count' AS info, COUNT(*) AS cnt
FROM sa_offline_sales.src_offline_sales;
