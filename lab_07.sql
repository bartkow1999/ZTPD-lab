-- 1.
-- A.
CREATE TABLE A6_LRS (
    GEOM SDO_GEOMETRY
);
    
-- B.
insert into A6_LRS
select s.geom
from streets_and_railroads s, major_cities m
where sdo_relate(s.geom, sdo_geom.sdo_buffer(m.geom, 10, 1, 'unit=km'), 'MASK=ANYINTERACT') = 'TRUE'
and m.city_name = 'Koszalin';

-- C.
SELECT ROUND(SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km'), 7) AS DISTANCE, ST_LINESTRING(GEOM).ST_NUMPOINTS() AS ST_NUMPOINTS
FROM A6_LRS;

-- D.
UPDATE A6_LRS
--SET GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km'));
SET GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.6815154);

-- E.       
insert into user_sdo_geom_metadata
values ('A6_LRS', 'GEOM',
mdsys.sdo_dim_array(
    mdsys.sdo_dim_element('X', 12.603676, 26.369824, 1),
    mdsys.sdo_dim_element('Y', 45.8464, 58.0213, 1),
    mdsys.sdo_dim_element('M', 0, 300, 1)),
    8307);
        
-- F.
create index lrs_routes_idx ON A6_LRS(geom) 
indextype is mdsys.spatial_index;


-- 2.
-- A.
select sdo_lrs.valid_measure(geom, 500) valid_500
from A6_LRS;

-- B.
select sdo_lrs.geom_segment_end_pt(geom) end_pt
from A6_LRS;

-- C.
select sdo_lrs.locate_pt(geom, 150, 0) km150
from A6_LRS;

-- D.
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPPED
from A6_LRS;

-- E.
select sdo_lrs.get_next_shape_pt(a6.geom, sdo_lrs.project_pt(a6.geom, c.geom)) wjazd_na_a6
from a6_lrs a6, major_cities c
where c.city_name = 'Slupsk';

-- F.
select 
sdo_geom.sdo_length(
SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50, 'unit=m arc_tolerance=0.05'), 1, 'unit=km') koszt
from A6_LRS A6, USER_SDO_GEOM_METADATA M
where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM'