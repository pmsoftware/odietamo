
create table TRG_COUNTRY (
   COUNTRY_ID           NUMERIC(10)                      not null,
   COUNTRY              VARCHAR(50),
   constraint PK_TRG_COUNTRY primary key (COUNTRY_ID)
)
;



create table TRG_REGION (
   REGION_ID            NUMERIC(10)                      not null,
   COUNTRY_ID           NUMERIC(10)                      not null,
   REGION               VARCHAR(50),
   constraint PK_TRG_REGION primary key (REGION_ID),
   constraint FK_REGION_COUNTRY foreign key (COUNTRY_ID)
         references TRG_COUNTRY (COUNTRY_ID)
         
)
;



create table TRG_CITY (
   CITY_ID              NUMERIC(10)                      not null,
   REGION_ID            NUMERIC(10)                      not null,
   CITY                 VARCHAR(50),
   POPULATION           NUMERIC(10),
   constraint PK_TRG_CITY primary key (CITY_ID),
   constraint FK_CITY_REGION foreign key (REGION_ID)
         references TRG_REGION (REGION_ID)
         
)
;



create table TRG_CUSTOMER (
   CUST_ID              NUMERIC(10)                      not null,
   DEAR                 VARCHAR(4),
   CUST_NAME            VARCHAR(50),
   ADDRESS              VARCHAR(100),
   CITY_ID              NUMERIC(10)                      not null,
   PHONE                VARCHAR(50),
   AGE                  NUMERIC(3),
   AGE_RANGE            VARCHAR(50),
   SALES_PERS           VARCHAR(50),
   CRE_DATE             DATE,
   UPD_DATE             DATE,
   constraint PK_TRG_CUSTOMER primary key (CUST_ID),
   constraint FK_CUST_CITY foreign key (CITY_ID)
         references TRG_CITY (CITY_ID)
         
)
;



create table TRG_PROD_FAMILY (
   FAMILY_ID            VARCHAR(3)                     not null,
   FAMILY_NAME          VARCHAR(50),
   constraint PK_TRG_PROD_FAMILY primary key (FAMILY_ID)
)
;



create table TRG_PRODUCT (
   PRODUCT_ID           NUMERIC(10)                      not null,
   FAMILY_ID            VARCHAR(3)                     not null,
   PRICE                NUMERIC(10,2),
   PRODUCT              VARCHAR(50),
   constraint PK_TRG_PRODUCT primary key (PRODUCT_ID),
   constraint FK_PROD_PROD_FAM foreign key (FAMILY_ID)
         references TRG_PROD_FAMILY (FAMILY_ID)
         
)
;



create table TRG_SALES (
   CUST_ID              NUMERIC(10)                      not null,
   PRODUCT_ID           NUMERIC(10)                      not null,
   FIRST_ORD_ID         NUMERIC(10)                      not null,
   FIRST_ORD_DATE       DATE                            not null,
   LAST_ORD_ID          NUMERIC(10)                      not null,
   LAST_ORD_DATE        DATE                            not null,
   QTY                  NUMERIC(10)                      not null,
   AMOUNT               NUMERIC(10, 2)                      not null,
   PROD_AVG_PRICE       NUMERIC(10, 2)                      not null,
   constraint PK_TRG_SALES primary key (PRODUCT_ID, CUST_ID),
   constraint FK_SALES_CUST foreign key (CUST_ID)
         references TRG_CUSTOMER (CUST_ID)
         ,
   constraint FK_SALES_PROD foreign key (PRODUCT_ID)
         references TRG_PRODUCT (PRODUCT_ID)
         
)
;


