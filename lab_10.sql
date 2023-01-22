-- Operator CONTAINS - Podstawy

-- 1.
CREATE TABLE cytaty AS
SELECT * FROM zsbd_tools.cytaty;

-- 2.
SELECT *
FROM cytaty
WHERE LOWER(tekst) LIKE '%optymista%' AND LOWER(tekst) LIKE '%pesymista%';

-- 3.
CREATE INDEX cytaty_idx on cytaty(tekst)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('DATASTORE CTXSYS.DEFAULT_DATASTORE');

-- 4.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, 'optymista') > 0 AND CONTAINS(tekst, 'pesymista') > 0;

-- 5.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, 'optymista') = 0 AND CONTAINS(tekst, 'pesymista') > 0;

-- 6.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, 'near((optymista, pesymista), 3)') > 0;

-- 7.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, 'near((optymista, pesymista), 10)') > 0;

-- 8.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, '¿yci%', 1) > 0;

-- 9.
SELECT autor, tekst, score(1) AS dopasowanie
FROM cytaty
WHERE CONTAINS(tekst, '¿yci%', 1) > 0;

-- 10.
SELECT autor, tekst, score(1) AS dopasowanie
FROM cytaty
WHERE CONTAINS(tekst, '¿yci%', 1) > 1
ORDER BY dopasowanie DESC
FETCH FIRST ROW ONLY;

-- 11.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, '?probelm') > 0;

-- 12.
INSERT INTO cytaty
VALUES ((SELECT max(id)+1 from cytaty), 'Bertrand Russell', 'To smutne, ¿e g³upcy s¹ tacy pewni
siebie, a ludzie rozs¹dni tacy pe³ni w¹tpliwoœci.');
commit;

-- 13.
SELECT *
FROM cytaty
WHERE CONTAINS(tekst, 'g³upcy') > 0;

-- 14.
select * 
from dr$cytaty_idx$i
where token_text='G£UPCY';

-- 15.
DROP INDEX cytaty_idx;

CREATE INDEX cytaty_idx on cytaty(tekst)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('DATASTORE CTXSYS.DEFAULT_DATASTORE');

-- 16.
select * 
from dr$cytaty_idx$i
where token_text='G£UPCY';

-- 17.
DROP INDEX cytaty_idx;

DROP TABLE cytaty;


-- Zaawansowane indeksowanie i wyszukiwanie

-- 1.
CREATE TABLE quotes AS
SELECT * FROM zsbd_tools.quotes;

-- 2.
CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('DATASTORE CTXSYS.DEFAULT_DATASTORE');

-- 3.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'work') > 0;

SELECT *
FROM quotes
WHERE CONTAINS(text, '$work') > 0;

SELECT *
FROM quotes
WHERE CONTAINS(text, 'working') > 0;

SELECT *
FROM quotes
WHERE CONTAINS(text, '$working') > 0;

-- 4.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'it') > 0;

-- 5.
SELECT *
FROM ctx_stoplists;

-- 6.
SELECT *
FROM ctx_stopwords;

-- 7.
DROP INDEX quotes_idx;

CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS('DATASTORE CTXSYS.DEFAULT_DATASTORE STOPLIST CTXSYS.EMPTY_STOPLIST');

-- 8.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'it') > 0;

-- 9.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'fool') >0 AND CONTAINS(text, 'humans') > 0;

-- 10.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'fool') >0 AND CONTAINS(text, 'computer') > 0;

-- 11.
SELECT *
FROM quotes
WHERE CONTAINS(text, '(fool and humans) within SENTENCE', 1) > 0;

-- 12.
DROP INDEX quotes_idx;

-- 13.
BEGIN
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

-- 14.
CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('section group nullgroup');

-- 15.
SELECT *
FROM quotes
WHERE CONTAINS(text, '(fool and humans) within SENTENCE', 1) > 0;

SELECT *
FROM quotes
WHERE CONTAINS(text, '(fool and computer) within SENTENCE', 1) > 0;

-- 16.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'humans') > 0;

-- 17.
DROP INDEX quotes_idx;

BEGIN
    CTX_DDL.CREATE_PREFERENCE('lex_z_m', 'BASIC_LEXER');
    CTX_DDL.SET_ATTRIBUTE('lex_z_m', 'printjoins', '_-');
    CTX_DDL.SET_ATTRIBUTE('lex_z_m', 'index_text', 'YES');
end;

CREATE INDEX quotes_idx
ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('LEXER lex_z_m');

-- 18.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'humans') > 0;

-- 19.
SELECT *
FROM quotes
WHERE CONTAINS(text, 'non\-humans') > 0;

-- 20.
DROP INDEX quotes_idx;

DROP TABLE quotes;