
create table SRC_REGION (
   REGION_ID            NUMERIC(10)                      not null,
   REGION               VARCHAR(50),
   COUNTRY_ID           NUMERIC(10),
   COUNTRY              VARCHAR(50),
   constraint PK_SRC_REGION primary key (REGION_ID)
)
;



create table SRC_CITY (
   CITY_ID              NUMERIC(10)                      not null,
   CITY                 VARCHAR(50),
   REGION_ID            NUMERIC(10),
   POPULATION           NUMERIC(10),
   constraint PK_SRC_CITY primary key (CITY_ID)
)
;



create table SRC_SALES_PERSON (
   SALES_PERS_ID        NUMERIC(10)                      not null,
   FIRST_NAME           VARCHAR(50),
   LAST_NAME            VARCHAR(50),
   HIRE_DATETIME            DATETIME,
   constraint PK_SRC_SALES_PERSON primary key (SALES_PERS_ID)
)
;



create table SRC_CUSTOMER (
   CUSTID               NUMERIC(10)                      not null,
   DEAR                 NUMERIC(1),
   LAST_NAME            VARCHAR(50),
   FIRST_NAME           VARCHAR(50),
   ADDRESS              VARCHAR(100),
   CITY_ID              NUMERIC(10),
   PHONE                VARCHAR(50),
   AGE                  NUMERIC(3),
   SALES_PERS_ID        NUMERIC(10),
   constraint PK_SRC_CUSTOMER primary key (CUSTID)
)
;



create table SRC_PRODUCT (
   PRODUCT_ID           NUMERIC(10)                      not null,
   PRODUCT              VARCHAR(50),
   PRICE                NUMERIC(10,2),
   FAMILY_NAME          VARCHAR(50),
   constraint PK_SRC_PRODUCT primary key (PRODUCT_ID)
)
;



create table SRC_ORDERS (
   ORDER_ID             NUMERIC(10)                      not null,
   STATUS               VARCHAR(3),
   CUST_ID              NUMERIC(10),
   ORDER_DATETIME           DATETIME,
   CUSTOMER             VARCHAR(35),
   constraint PK_SRC_ORDERS primary key (ORDER_ID)
)
;



create table SRC_ORDER_LINES (
   ORDER_ID             NUMERIC(10)                      not null,
   LORDER_ID            NUMERIC(10)                      not null,
   PRODUCT_ID           NUMERIC(10),
   QTY                  NUMERIC(10),
   AMOUNT               NUMERIC(10,2),
   constraint PK_SRC_ORDER_LINES primary key (LORDER_ID, ORDER_ID)
)
;


