-- 1.
CREATE table dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);


-- 2.
DECLARE
    temp CLOB := '';
BEGIN
    for i in 1..10000
    LOOP
        temp := temp || 'Oto tekst. ';
    END LOOP;
    
    INSERT INTO dokumenty
    VALUES (1, temp);
END;


-- 3.
-- a)
SELECT * FROM dokumenty;

-- b)
SELECT id, UPPER(dokument)
FROM dokumenty;

-- c)
SELECT LENGTH(dokument)
FROM dokumenty;

-- d)
SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty;

-- e)
SELECT SUBSTR(dokument, 5, 100)
FROM dokumenty;

-- f)
SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5)
from dokumenty;


-- 4.
INSERT INTO dokumenty
VALUES (2, EMPTY_CLOB());


-- 5.
INSERT INTO dokumenty
VALUES (3, NULL);

commit;


-- 6.
-- a)
SELECT * FROM dokumenty;

-- b)
SELECT id, UPPER(dokument)
FROM dokumenty;

-- c)
SELECT LENGTH(dokument)
FROM dokumenty;

-- d)
SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty;

-- e)
SELECT SUBSTR(dokument, 5, 100)
FROM dokumenty;

-- f)
SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5)
from dokumenty;


-- 7.
SELECT * FROM all_directories;


-- 8.
DECLARE
    lobd CLOB;
    fils BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
    doffset INTEGER := 1;
    soffset INTEGER := 1;
    langctx INTEGER := 0;
    warn INTEGER := NULL;
BEGIN
    SELECT dokument INTO lobd
    FROM dokumenty
    WHERE id=2
    FOR UPDATE;
    
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(
        lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn
    );
    DBMS_LOB.fileclose(fils);
    
    commit;
    
    DBMS_OUTPUT.PUT_LINE('Status operacji kopiowania: ' || warn);
END;

SELECT * FROM dokumenty;


-- 9.
UPDATE dokumenty
SET dokument = TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt'))
WHERE id = 3;


-- 10.
SELECT * FROM dokumenty;


-- 11.
SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty;


-- 12.
DROP TABLE dokumenty;


-- 13.
CREATE OR REPLACE PROCEDURE CLOB_CENSOR (clob_ in out CLOB, text_ in VARCHAR2) as 
    temp INTEGER := 0;
    buffer_temp VARCHAR2(100) := '';
BEGIN
    temp := DBMS_LOB.INSTR(clob_, text_);
    
    buffer_temp := '';    
    FOR i IN 1..LENGTH(text_)
    LOOP
        buffer_temp := buffer_temp || '.'; 
    END LOOP;
    
    WHILE temp > 0
    LOOP
        DBMS_LOB.WRITE(clob_, temp, LENGTH(buffer_temp), buffer_temp);
        temp := DBMS_LOB.INSTR(clob_, buffer_temp);
    END LOOP;
END CLOB_CENSOR2;


-- 14.
CREATE TABLE biographies_copy AS
SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

DECLARE
    lobd CLOB;
BEGIN
    SELECT bio INTO lobd
    FROM biographies_copy
    WHERE id = 1
    FOR UPDATE;
    
    CLOB_CENSOR(lobd, 'Cimrman');
END;

SELECT * FROM biographies_copy;


-- 15.
DROP TABLE biographies_copy;
























