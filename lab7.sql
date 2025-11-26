#	==================================== 1 ====================================

DELIMITER $$
create function to_geometry(lon double, lat double)
returns geometry
deterministic
begin
    return POINT(lon, lat);
end$$
DELIMITER ;

#	==================================== 2 ====================================

select point_id
from rental_points
where st_within(
    ST_SRID(to_geometry(lon, lat), 4326),
    st_geomfromtext('polygon((-50 -50,-50 50,50 50,50 -50,-50 -50))', 4326)
);

#	==================================== 3 ====================================

SELECT COUNT(*) AS count
FROM rental_points r
WHERE r.point_title <> 'Парк Гагарина'
  AND ST_Within(
        to_geometry(r.lon, r.lat),
        ST_Buffer(
            to_geometry(
                (SELECT lon FROM rental_points WHERE point_title = 'Парк Гагарина' LIMIT 1),
                (SELECT lat FROM rental_points WHERE point_title = 'Парк Гагарина' LIMIT 1)
            ),
            15
        )
    );

#	==================================== 4 ====================================

SELECT ST_SRID(ST_Envelope(ST_Collect(to_geometry(r.lon, r.lat))), 4326) AS wkt
FROM rental_points r
JOIN rental_points p
    ON p.point_title = 'Парк Гагарина'
WHERE r.point_title <> 'Парк Гагарина'
  AND ST_Distance(
        to_geometry(r.lon, r.lat),
        to_geometry(p.lon, p.lat)
      ) <= 15;

#	==================================== 5 ====================================

DELIMITER $$

CREATE PROCEDURE sp_relation()
BEGIN
    DECLARE g1 GEOMETRY;
    DECLARE g2 GEOMETRY;

    SET g1 = ST_GeomFromText('polygon((-50 -50,-50 50,50 50,50 -50,-50 -50))', 4326);

    SET g2 = (
        SELECT ST_SRID(ST_Envelope(ST_Collect(to_geometry(r.lon, r.lat))), 4326)
        FROM rental_points r
        JOIN rental_points p
            ON p.point_title = 'Парк Гагарина'
        WHERE r.point_title <> 'Парк Гагарина'
          AND ST_Distance(to_geometry(r.lon, r.lat), to_geometry(p.lon, p.lat)) <= 15
    );

    SELECT
        ST_Intersects(g1, g2) AS intersects,
        ST_Contains(g1, g2) AS contains,
        ST_Within(g1, g2) AS within;
END$$

DELIMITER ;

CALL sp_relation();

#	==================================== 6 ====================================

SELECT 
    point_id,
    point_title,
    JSON_EXTRACT(notes, '$.description') AS info
FROM rental_points
WHERE JSON_EXTRACT(notes, '$.description') LIKE '%район%';

#	==================================== 7 ====================================

SELECT
    point_id,
    point_title,
    JSON_EXTRACT(notes, '$.features') AS info
FROM rental_points
WHERE JSON_CONTAINS(JSON_EXTRACT(notes, '$.features'), '"Прокат электровелосипедов"');

#	==================================== 8 ====================================

UPDATE rental_points
SET notes = JSON_SET(
                JSON_ARRAY_APPEND(notes, '$.features', 'Парковка'),
                '$."Директор"', 'Н.Н. Иванов'
            )
WHERE point_title = 'Парк Гагарина';

select * from rental_points;
