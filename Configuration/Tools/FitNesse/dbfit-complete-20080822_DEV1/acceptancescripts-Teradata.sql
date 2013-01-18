create user dbfitacctest identified by dbfitacctest;
grant create procedure on dbfitacctest to dbfitacctest;
grant create function on dbfitacctest to dbfitacctest;

.login stamoi5/dftest,dftest

replace procedure nulls_back(out out1 varchar, out out2 numeric, out out3 date)
begin
   set :out1 = null;
   set :out2 = null;
   set :out3 = null;
end;

replace procedure ConcatenateStrings(firstString varchar, secondString varchar, concatenated out varchar)
begin
	set concatenated=firstString || ' ' || secondString;
end;

replace function ConcatenateF(in firstString varchar, in secondString varchar) return varchar as
begin
	return firstString || ' ' || secondString;
end;
/

replace procedure CalcLength(in name varchar, out strlength numeric)
begin
	set strlength=characters(name);
end;
/

create sequence s1 start with 1;

create table users(name varchar(50), username varchar(50), userid numeric primary key);
 
CREATE OR REPLACE TRIGGER USERS_BIE
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
	  SELECT s1.NEXTVAL INTO :new.userid FROM dual;
END; 
/

create or replace package RCTest as
type URefCursor IS REF CURSOR RETURN USERS%ROWTYPE;
procedure TestRefCursor (howmuch number,lvlcursor out URefCursor);
end; 
/

create or replace package body RCTest as 
procedure TestRefCursor (
howmuch number,
lvlcursor out URefCursor
)
as 
begin
 for i in 1..howmuch loop
 	insert into users(name, username) values ('User '||i, 'Username'||i);	
 end loop;
 OPEN lvlcursor FOR
	  SELECT * FROM users;
 end;
end;	 
/

create or replace function Multiply(n1 number, n2 number) return number as
begin
	return n1*n2;
end;
/


set define on

connect sys/&&syspw@&&dbhost as sysdba

set define off


create user dfsyntest identified by dfsyntest;

create or replace procedure dfsyntest.standaloneproc(num1 number, num2 out number) as
begin
num2:=2*num1;
end;
/

create or replace public synonym synstandaloneproc for dfsyntest.standaloneproc;

create or replace package dfsyntest.pkg as
	procedure pkgproc(num1 number, num2 out number);
end;
/

create or replace package body dfsyntest.pkg as
	procedure pkgproc(num1 number, num2 out number) as
	begin
		num2:=2*num1;
	end;
end;
/
	 
create or replace public synonym synpkg for dfsyntest.pkg;

grant execute on synstandaloneproc to dftest;

grant execute on dfsyntest.pkg to dftest;

exit