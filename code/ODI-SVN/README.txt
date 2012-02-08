How to import ODI-SVN into any ODI repo
=======================================

1. Export it from TFS 
Path: C:\MOI\Development\ODI\Source\project.9007

1.a. Actually just use the code in C:\MOI\Development\ODI\ODI-SVN_install


2. Edit import_OSI-SVN.bat
   alter ODIBIN to be a suitable odi bin dir with odiparams set up for TARGET
   You may have to use snps_login_work.xml to get the encoded passwords

3. Run import_OSI-SVN.bat


4. (only if going to frig the date to flush from) 
   Create the beliow in the Oracle instance for the Master Repo

CREATE TABLE "$DBUSER"."ODISVN_MASTER_FLUSH_CONTROLS"
(
   ODI_USER_NAME VARCHAR2(35) PRIMARY KEY not null,
   FLUSH_FROM_DATETIME DATE,
   FLUSH_TO_DATETIME DATE
);

CREATE TABLE "$DBUSER"."ODISVN_WORK_FLUSH_CONTROLS"
(
   ODI_USER_NAME VARCHAR2(35) PRIMARY KEY not null,
   FLUSH_FROM_DATETIME DATE,
   FLUSH_TO_DATETIME DATE
);

DELETE FROM ODISVN_MASTER_FLUSH_CONTROLS;
INSERT INTO ODISVN_MASTER_FLUSH_CONTROLS (ODI_USER_NAME, FLUSH_FROM_DATETIME, FLUSH_TO_DATETIME )
VALUES ('BRIANP', TO_DATE('20110901','YYYYMMDD'),TO_DATE('20110901','YYYYMMDD'));
 
DELETE FROM ODISVN_WORK_FLUSH_CONTROLS;
INSERT INTO ODISVN_WORK_FLUSH_CONTROLS (ODI_USER_NAME, FLUSH_FROM_DATETIME, FLUSH_TO_DATETIME )
VALUES ('BRIANP', TO_DATE('20110901','YYYYMMDD'),TO_DATE('20110901','YYYYMMDD'));
COMMIT;

SELECT * FROM ODISVN_MASTER_FLUSH_CONTROLS;
SELECT * FROM ODISVN_WORK_FLUSH_CONTROLS;


5. Create link between MAster and Repository
   WHere the two databases are seperate, we need a link

CREATE DATABASE LINK odiworkrep_data
	CONNECT TO $DBUSER
	IDENTIFIED BY $DBPASS
	USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$HOSTNAME)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIDEV1)))'

We want a link from the Master Database *to* the working Database.
If in same repo not needed???


6. configuration

* change the file data server to point to local disk
  File / ODISVNWC_DATA / Physical Schema 
  -> Schema : WHere the source code will go
  -> WOrk Schema : temporary working space, necessary but no impact on source. Default: C:\ODISVNWC_WORK


  

* change the Oracle / ODIMASTERREP_DATA Data store and ODIMASTERREP_DATA.<linkname>

  -> User: master db user
  -> Pass: master db pass
 
  -> Schema : $DBUSERM_DEV4 : the Owner of the database pointed at


* change the Oracle / ODIWORKREP_DATA Data store and ODIWORKREP_DATA.<linkname>
  -> User: master db user
  -> Pass: master db pass
 
  -> Schema : $DBUSERM_DEV4 : the Owner of the database pointed at



Problems with Data Servers
==========================

INSERT-UPDATE does not delete associated MTXT strings (cos not really associated through ref integrity I guess)
SO attempts to update over top of existing will fail

I have used the below to clean out the txt and then successfuly run the import.

Also note AK_CONNECT is unique name constraint on connect_name for data servers

DELETE FROM SNP_MTXT_PART WHERE I_TXT IN(3110, 2110, 4110);
DELETE FROM SNP_MTXT WHERE I_TXT IN  (3110, 2110, 4110);

COMMIT;



Ensure all references and settings are correct for the repo

* Data server URls
* File links,
etc

Avoid backslashes - use forward slash or escape !!!

OSUTL_EXPORT_LOGICAL_SCHEMA
- 