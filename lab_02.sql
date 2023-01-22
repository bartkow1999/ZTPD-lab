-- 1.
create table movies (
id NUMBER(12) PRIMARY KEY,
title VARCHAR2(400) NOT NULL,
category VARCHAR2(50),
year CHAR(4),
cast VARCHAR2(4000),
director VARCHAR2(4000),
story VARCHAR2(4000),
price NUMBER(5,2),
cover BLOB,
mime_type VARCHAR2(50)
);

--2.
SELECT * FROM descriptions;
SELECT * FROM covers;

INSERT INTO movies
SELECT d.id, d.title, d.category, substr(d.year,0 , 4), d.cast, d.director, d.story, d.price, c.image, c.mime_type 
from descriptions d LEFT OUTER JOIN covers c ON d.id=c.movie_id;

select * from movies;

--3.
SELECT id, title
FROM movies
WHERE cover is null;

--4.
SELECT id, title, DBMS_LOB.getlength(cover) as filesize
FROM movies
WHERE cover is not null;

--5.
SELECT id, title, DBMS_LOB.getlength(cover) as filesize
FROM movies
WHERE cover is null;

--6.
select * from all_directories;

--7.
UPDATE movies
SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg'
WHERE id = 66;

SELECT * FROM movies;

--8.
SELECT id, title, DBMS_LOB.getlength(cover) as filesize FROM movies
WHERE id IN (65, 66);

--9.
DECLARE
 lobd blob;
 fils BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
 SELECT cover INTO lobd
 FROM movies
 where id=66
 FOR UPDATE;
 
 DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
 DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
 DBMS_LOB.FILECLOSE(fils);
 
 COMMIT;
END;

--10.
CREATE TABLE temp_covers(
movie_id NUMBER(12),
image BFILE,
mime_type VARCHAR2(50)
)

--11.
INSERT INTO temp_covers(movie_id, image, mime_type)
VALUES(65, BFILENAME('ZSBD_DIR', 'eagles.jpg'),'image/jpeg');

--12.
SELECT movie_id, DBMS_LOB.getlength(image) 
FROM temp_covers;

--13.
DECLARE
 a blob;
 fils BFILE;
 mime varchar2(50);
BEGIN
 SELECT image, mime_type into fils, mime
 FROM temp_covers
 WHERE movie_id=65;
  
 dbms_lob.createtemporary(a, TRUE);
 -- operacje na LOB
 DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
 DBMS_LOB.LOADFROMFILE(a,fils,DBMS_LOB.GETLENGTH(fils));
 DBMS_LOB.FILECLOSE(fils);
 
 UPDATE movies 
 SET cover = a, mime_type = mime
 WHERE id=65;
 dbms_lob.freetemporary(a);
 
 COMMIT;
END;


--14.
SELECT id, dbms_lob.getlength(cover) as filesize
FROM movies
WHERE ID in (65, 66);

--15.
DROP table movies;
DROP table temp_covers;
