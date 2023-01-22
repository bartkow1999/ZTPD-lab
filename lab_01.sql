-- Tworzenie typów obiektowych

-- 1. 
CREATE TYPE samochod AS OBJECT (
    marka varchar2(20),
    model varchar2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);

CREATE TABLE samochody OF samochod;

desc samochod;

INSERT INTO samochody VALUES (
NEW samochod('Fiat', 'Brava', 60000, DATE '1999-11-30', 25000)
);
INSERT INTO samochody VALUES (
NEW samochod('Ford', 'Mondeo', 80000, DATE '1997-05-10', 45000)
);
INSERT INTO samochody VALUES (
NEW samochod('Mazda', '323', 12000, DATE '2000-09-22', 52000)
);

SELECT * FROM samochody;


-- 2.
CREATE TABLE wlasciciele (
imie VARCHAR2(100),
nazwisko VARCHAR2(100),
auto samochod
);

desc wlasciciele;

INSERT INTO wlasciciele VALUES (
'Jan', 'Kowalski', NEW samochod('Fiat', 'Seicento', 30000, DATE '0010-12-02', 19500)
);
INSERT INTO wlasciciele VALUES (
'Adam', 'Nowak', NEW samochod('Opel', 'Astra', 34000, DATE '0009-06-01', 33700)
);

select * from wlasciciele;


-- 3.
ALTER TYPE samochod REPLACE AS OBJECT (
    marka varchar2(20),
    model varchar2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2),
    --MEMBER FUNCTION wiek RETURN NUMBER,
    MEMBER FUNCTION wartosc RETURN NUMBER
);

DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje
CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * POWER (0.9, (EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM data_produkcji)));
    END wartosc;
    
    MEMBER FUNCTION wiek RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM data_produkcji);
    END wiek;
END;
    
SELECT s.marka, s.cena, s.wartosc()--, s.wiek()
FROM samochody s;


-- 4.
ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * POWER (0.9, (EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM data_produkcji)));
    END wartosc;
    
    MEMBER FUNCTION wiek RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM data_produkcji);
    END wiek;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN 10000*EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM data_produkcji) + kilometry;
    END odwzoruj;
END;

SELECT * FROM samochody s ORDER BY VALUE(s);


-- 5.
CREATE TYPE wlasciciel AS OBJECT(
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);

ALTER TYPE samochod ADD ATTRIBUTE posiadacz REF wlasciciel CASCADE;

SELECT * FROM samochody;

CREATE TABLE wlascicieleTab of wlasciciel;
INSERT INTO wlascicieleTab VALUES (
'Jan', 'Kowalski'
);

UPDATE samochody s
SET s.posiadacz = (
    SELECT REF(w) FROM wlascicieleTab w
    WHERE w.imie = 'Jan' );

SELECT * FROM samochody;


-- Kolekcje

-- 6.
DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;


-- 7.
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(100);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'Harry Potter';
    
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
    
    moje_ksiazki.EXTEND(9);
    
    FOR i IN 2..10 LOOP
        moje_ksiazki(i) := 'Ksiazka_' || i;
    END LOOP;
    
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
    
    moje_ksiazki(7) := 'Harry Potter';
    
    moje_ksiazki.TRIM(1);    
    
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
END;


-- 8.
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    
    moi_wykladowcy.EXTEND(8);
    
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    
    moi_wykladowcy.TRIM(2);
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    
    moi_wykladowcy.DELETE(5,7);
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;


-- 9.
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.EXTEND(2);
    
    moje_miesiace(1) := 'STYCZEÑ';
    moje_miesiace(2) := 'LUTY';
    
    moje_miesiace.EXTEND(8);
    
    FOR i IN 3..10 LOOP
        moje_miesiace(i) := 'MIESIAC_' || i;
    END LOOP;
    
    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
    END LOOP;
    
    moje_miesiace.TRIM(2);
    
    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
    END LOOP;
    
    moje_miesiace.DELETE(5,7);
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());
    
    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END IF;
    END LOOP;
    
    moje_miesiace(5) := 'MAJ';
    moje_miesiace(6) := 'CZERWIEC';
    moje_miesiace(7) := 'LIPIEC';
    
    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());
END;


-- 10.
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);

CREATE TYPE stypendium AS OBJECT (
 nazwa VARCHAR2(50),
 kraj VARCHAR2(30),
 jezyki jezyki_obce );

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));

SELECT * FROM stypendia;

SELECT s.jezyki FROM stypendia s;

UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);

CREATE TYPE semestr AS OBJECT (
 numer NUMBER,
 egzaminy lista_egzaminow 
);

CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));

SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;

SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;

SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';


-- 11.
CREATE TYPE lista_koszykow_produktow AS TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
    numer NUMBER,
    koszyk_produktow lista_koszykow_produktow
);

CREATE TABLE zakupy OF zakup
NESTED TABLE koszyk_produktow STORE AS tab_koszyki_produktow;


INSERT INTO zakupy VALUES
(zakup(1, lista_koszykow_produktow('mleko', 'maslo', 'chleb')));
INSERT INTO zakupy VALUES
(zakup(2, lista_koszykow_produktow('pieprz', 'sól')));

SELECT z.numer, k.*
FROM zakupy z, TABLE(z.koszyk_produktow) k;

DELETE FROM TABLE(SELECT z.koszyk_produktow FROM zakupy z WHERE numer = 1) k
WHERE k.column_value = 'maslo';

SELECT z.numer, k.*
FROM zakupy z, TABLE(z.koszyk_produktow) k;


-- Polimorfizm, dziedziczenie, perspektywy obiektowe

-- 12.
CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
 
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
    RETURN dzwiek;
 END;
END;

CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
    RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
    RETURN glosnosc||':'||dzwiek;
 END;
END;

CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
    RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;

DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;


-- 13.
CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
 
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
 
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
  RETURN 'upolowana ofiara: '||ofiara;
 END;
END;

DECLARE
 KrolLew lew := lew('LEW',4);
 --InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;


-- 14.
DECLARE
 tamburyn instrument;
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
 -- saksofon := instrument('saksofon','tra-taaaa');
 -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;


-- 15.
CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa') );
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );

SELECT i.nazwa, i.graj() FROM instrumenty i;


-- 16.
CREATE TABLE PRZEDMIOTY2 (
 NAZWA VARCHAR2(50),
 NAUCZYCIEL NUMBER REFERENCES PRACOWNICY(ID_PRAC)
);

INSERT INTO PRZEDMIOTY2 VALUES ('BAZY DANYCH',100);
INSERT INTO PRZEDMIOTY2 VALUES ('SYSTEMY OPERACYJNE',100);
INSERT INTO PRZEDMIOTY2 VALUES ('PROGRAMOWANIE',110);
INSERT INTO PRZEDMIOTY2 VALUES ('SIECI KOMPUTEROWE',110);
INSERT INTO PRZEDMIOTY2 VALUES ('BADANIA OPERACYJNE',120);
INSERT INTO PRZEDMIOTY2 VALUES ('GRAFIKA KOMPUTEROWA',120);
INSERT INTO PRZEDMIOTY2 VALUES ('BAZY DANYCH',130);
INSERT INTO PRZEDMIOTY2 VALUES ('SYSTEMY OPERACYJNE',140);
INSERT INTO PRZEDMIOTY2 VALUES ('PROGRAMOWANIE',140);
INSERT INTO PRZEDMIOTY2 VALUES ('SIECI KOMPUTEROWE',140);
INSERT INTO PRZEDMIOTY2 VALUES ('BADANIA OPERACYJNE',150);
INSERT INTO PRZEDMIOTY2 VALUES ('GRAFIKA KOMPUTEROWA',150);
INSERT INTO PRZEDMIOTY2 VALUES ('BAZY DANYCH',160);
INSERT INTO PRZEDMIOTY2 VALUES ('SYSTEMY OPERACYJNE',160);
INSERT INTO PRZEDMIOTY2 VALUES ('PROGRAMOWANIE',170);
INSERT INTO PRZEDMIOTY2 VALUES ('SIECI KOMPUTEROWE',180);
INSERT INTO PRZEDMIOTY2 VALUES ('BADANIA OPERACYJNE',180);
INSERT INTO PRZEDMIOTY2 VALUES ('GRAFIKA KOMPUTEROWA',190);
INSERT INTO PRZEDMIOTY2 VALUES ('GRAFIKA KOMPUTEROWA',200);
INSERT INTO PRZEDMIOTY2 VALUES ('GRAFIKA KOMPUTEROWA',210);
INSERT INTO PRZEDMIOTY2 VALUES ('PROGRAMOWANIE',220);
INSERT INTO PRZEDMIOTY2 VALUES ('SIECI KOMPUTEROWE',220);
INSERT INTO PRZEDMIOTY2 VALUES ('BADANIA OPERACYJNE',230);


-- 17.
CREATE TYPE ZESPOL AS OBJECT (
 ID_ZESP NUMBER,
 NAZWA VARCHAR2(50),
 ADRES VARCHAR2(100)
);


-- 18.
CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
WITH OBJECT IDENTIFIER(ID_ZESP)
AS SELECT ID_ZESP, NAZWA, ADRES FROM ZESPOLY;


-- 19.
CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);

CREATE TYPE PRACOWNIK2 AS OBJECT (
 ID_PRAC NUMBER,
 NAZWISKO VARCHAR2(30),
 ETAT VARCHAR2(20),
 ZATRUDNIONY DATE,
 PLACA_POD NUMBER(10,2),
 MIEJSCE_PRACY REF ZESPOL,
 PRZEDMIOTY2 PRZEDMIOTY_TAB,
 MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PRACOWNIK2 AS
 MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
 BEGIN
 RETURN PRZEDMIOTY2.COUNT();
 END ILE_PRZEDMIOTOW;
END;


-- 20.
CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK2
WITH OBJECT IDENTIFIER (ID_PRAC)
AS SELECT ID_PRAC, NAZWISKO, ETAT, ZATRUDNIONY, PLACA_POD,
 MAKE_REF(ZESPOLY_V,ID_ZESP),
 CAST(MULTISET( SELECT NAZWA FROM PRZEDMIOTY2 WHERE NAUCZYCIEL=P.ID_PRAC ) AS
PRZEDMIOTY_TAB )
FROM PRACOWNICY P;


-- 21.
SELECT *
FROM PRACOWNICY_V;

SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;

SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;

SELECT *
FROM TABLE( SELECT PRZEDMIOTY2 FROM PRACOWNICY_V WHERE NAZWISKO='WEGLARZ' );

SELECT NAZWISKO, CURSOR( SELECT PRZEDMIOTY2
FROM PRACOWNICY_V
WHERE ID_PRAC=P.ID_PRAC)
FROM PRACOWNICY_V P;


-- 22.
CREATE TABLE PISARZE (
 ID_PISARZA NUMBER PRIMARY KEY,
 NAZWISKO VARCHAR2(20),
 DATA_UR DATE );
 
CREATE TABLE KSIAZKI (
 ID_KSIAZKI NUMBER PRIMARY KEY,
 ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
 TYTUL VARCHAR2(50),
 DATA_WYDANIE DATE );
 
INSERT INTO PISARZE VALUES(10,'SIENKIEWICZ',DATE '1880-01-01');
INSERT INTO PISARZE VALUES(20,'PRUS',DATE '1890-04-12');
INSERT INTO PISARZE VALUES(30,'ZEROMSKI',DATE '1899-09-11');

INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(10,10,'OGNIEM I MIECZEM',DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(20,10,'POTOP',DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(30,10,'PAN WOLODYJOWSKI',DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(40,20,'FARAON',DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(50,20,'LALKA',DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
VALUES(60,30,'PRZEDWIOSNIE',DATE '1938-02-02');

CREATE TYPE PISARZ AS OBJECT (
    ID_PISARZA NUMBER,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE,
    KSIAZKI NUMBER,
    MEMBER FUNCTION LICZ_KSIAZKI RETURN NUMBER );

CREATE OR REPLACE TYPE BODY PISARZ AS
    MEMBER FUNCTION LICZ_KSIAZKI RETURN NUMBER IS
    BEGIN
        RETURN KSIAZKI;
    END;
END;

CREATE OR REPLACE VIEW PISARZE_V OF PISARZ
WITH OBJECT IDENTIFIER (ID_PISARZA)
AS
SELECT ID_PISARZA, NAZWISKO, DATA_UR, (SELECT COUNT(*) FROM KSIAZKI WHERE ID_PISARZA = P.ID_PISARZA) AS KSIAZKI
FROM PISARZE P;

CREATE TYPE KSIAZKA AS OBJECT (
    ID_KSIAZKI NUMBER,
    AUTOR REF PISARZ,
    TYTUL VARCHAR2(50),
    DATA_WYDANIE DATE,
    MEMBER FUNCTION WIEK RETURN NUMBER );

CREATE OR REPLACE TYPE BODY KSIAZKA AS
    MEMBER FUNCTION WIEK RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIE);
    END;
END;

CREATE OR REPLACE VIEW KSIAZKI_V OF KSIAZKA
WITH OBJECT IDENTIFIER (ID_KSIAZKI)
AS
SELECT ID_KSIAZKI, MAKE_REF(PISARZE_V, ID_PISARZA), TYTUL, DATA_WYDANIE
FROM KSIAZKI K;

SELECT p.NAZWISKO, p.LICZ_KSIAZKI()
FROM PISARZE_V p;

SELECT TYTUL, k.AUTOR.NAZWISKO
FROM KSIAZKI_V k;


-- 23.
CREATE TYPE AUTO2 AS OBJECT (
 MARKA VARCHAR2(20),
 MODEL VARCHAR2(20),
 KILOMETRY NUMBER,
 DATA_PRODUKCJI DATE,
 CENA NUMBER(10,2),
 MEMBER FUNCTION WARTOSC RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY AUTO2 AS
 MEMBER FUNCTION WARTOSC RETURN NUMBER IS
     WIEK NUMBER;
     WARTOSC NUMBER;
 BEGIN
     WIEK := ROUND(MONTHS_BETWEEN(SYSDATE,DATA_PRODUKCJI)/12);
     WARTOSC := CENA - (WIEK * 0.1 * CENA);
     IF (WARTOSC < 0) THEN
        WARTOSC := 0;
     END IF;
     RETURN WARTOSC;
 END WARTOSC;
END;

CREATE TABLE AUTA2 OF AUTO2;

INSERT INTO AUTA2 VALUES (AUTO2('FIAT','BRAVA',60000,DATE '1999-11-30',25000));
INSERT INTO AUTA2 VALUES (AUTO2('FORD','MONDEO',80000,DATE '1997-05-10',45000));
INSERT INTO AUTA2 VALUES (AUTO2('MAZDA','323',12000,DATE '2000-09-22',52000));

CREATE OR REPLACE TYPE AUTO_OSOBOWE UNDER AUTO2 (
    liczba_miejsc NUMBER,
    klimatyzacja NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER );

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := (SELF AS AUTO2).WARTOSC();
        IF klimatyzacja = 1 THEN
            RETURN wartosc * 1.5;
        END IF;
        RETURN wartosc;
    END;
END;

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO2 (
    maksymalna_ladownosc NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER );

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := (SELF AS AUTO2).WARTOSC();
        IF maksymalna_ladownosc > 10 THEN
            RETURN wartosc * 2;
        END IF;
        RETURN wartosc;
    END;
END;

INSERT INTO AUTA2
VALUES (AUTO_OSOBOWE('Citroen', 'C5', 20000, DATE '2015-05-01', 35000, 5, 1));
INSERT INTO AUTA2
VALUES (AUTO_OSOBOWE('Peugeot', '407', 12000, DATE '2010-01-02', 15000, 5, 0));
INSERT INTO AUTA2
VALUES (AUTO_CIEZAROWE('Scania', 'v1', 10000, DATE '2011-03-31', 80000, 12));
INSERT INTO AUTA2
VALUES (AUTO_CIEZAROWE('Scania', 'v2', 50000, DATE '2012-04-22', 120000, 8));

SELECT marka, a2.wartosc()
FROM auta2 a2;