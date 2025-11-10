USE discogs;

DESCRIBE artist;

# 1

EXPLAIN
SELECT * FROM artist WHERE name = 'The Beatles';

CREATE INDEX idx_artist_name ON artist(name);

DROP  INDEX idx_artist_name ON artist;

# 2

EXPLAIN
SELECT 
    a.NAME AS artist_name,
    grp.NAME AS group_name
FROM artist AS a
JOIN `group` AS g ON a.ARTIST_ID = g.GROUP_ARTIST_ID
JOIN artist AS grp ON grp.ARTIST_ID = g.MAIN_ARTIST_ID
WHERE grp.NAME = 'The Beatles';

CREATE INDEX idx_artist_name ON artist(NAME);
CREATE INDEX idx_group_artist ON `group`(GROUP_ARTIST_ID);
CREATE INDEX idx_group_main ON `group`(MAIN_ARTIST_ID);

DROP INDEX idx_artist_name ON artist;
DROP INDEX idx_group_artist ON `group`;
DROP INDEX idx_group_main ON `group`;

# 3

EXPLAIN
SELECT 
    ar.NAME AS artist_name,
    r.TITLE AS release_title,
    r.RELEASED AS release_date
FROM artist AS ar
JOIN release_artist AS ra ON ar.ARTIST_ID = ra.ARTIST_ID
JOIN `release` AS r ON ra.RELEASE_ID = r.RELEASE_ID
WHERE ar.NAME = 'The Beatles'
ORDER BY r.RELEASED;

CREATE INDEX idx_artist_name ON artist(NAME);
CREATE INDEX idx_ra_artist ON release_artist(ARTIST_ID);
CREATE INDEX idx_ra_release ON release_artist(RELEASE_ID);
CREATE INDEX idx_release_released ON `release`(RELEASED);

DROP INDEX idx_artist_name ON artist;
DROP INDEX idx_ra_artist ON release_artist;
DROP INDEX idx_ra_release ON release_artist;
DROP INDEX idx_release_released ON `release`;

# 4

EXPLAIN
SELECT 
    r.TITLE AS release_title,
    r.RELEASED AS release_date,
    s.STYLE_NAME AS release_style
FROM `release` AS r
JOIN style AS s ON r.RELEASE_ID = s.RELEASE_ID
WHERE r.IS_MAIN_RELEASE = 1
  AND YEAR(r.RELEASED) = 1969
ORDER BY r.RELEASED;

CREATE INDEX idx_release_main ON `release`(IS_MAIN_RELEASE);
CREATE INDEX idx_release_released ON `release`(RELEASED);
CREATE INDEX idx_style_release ON style(RELEASE_ID);

DROP INDEX idx_release_main ON `release`;
DROP INDEX idx_release_released ON `release`;
DROP INDEX idx_style_release ON style;

# 5

SELECT ARTIST_ID, NAME, PROFILE
FROM artist
WHERE MATCH(PROFILE) AGAINST('"progressive rock"' IN BOOLEAN MODE);

CREATE FULLTEXT INDEX idx_artist_profile ON artist(PROFILE);

DROP INDEX idx_artist_profile ON artist;