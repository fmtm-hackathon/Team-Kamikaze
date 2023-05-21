-- SELECT COUNT(*) from islington_polygons p1, islington_aoi a1 where p1.tags->>'building' is not null and ST_Contains(a1.geom, p1.geom)
-- SELECT ST_Distance(l1.geom, l2.geom) from islington_polygons l1, islington_polygons l2 where l1.osm_id = 913250467 and l2.osm_id = 913718920
-- SELECT ST_AsText(ST_ClusterDBSCAN(p1.geom, eps := 1, minpoints := 150)) FROM islington_polygons p1, islington_aoi a1 where p1.tags->>'building' is not null and ST_Contains(a1.geom, p1.geom)
-- SELECT ST_LENGTH(geom), * from islington_lines where tags->>'highway' is not null and ST_LENGTH(geom) >= (SELECT AVG(ST_LENGTH(geom)) from islington_lines)
-- SELECT AVG(ST_DISTANCE(p1.geom, l1.geom)) from islington_lines l1, islington_polygons p1

-- SELECT geom from islington_lines where ST_Length(geom) > (SELECT AVG(ST_Length(geom)) from islington_lines)

-- SELECT tags from islington_lines where tags->'road' is not null

-- avg distance = 0.01113761097214975



-- drop table temp;

-- create table polygons_far_from_road as
-- with points as (
-- with min_distance as (
-- with distance as (
-- Select ST_distance(l1.geom, p1.geom) as dist, l1.osm_id as id1, p1.geom as geom, p1.osm_id as id2
-- from islington_lines l1, islington_polygons p1
-- )
-- select id2, min(dist) as min_dist from distance
-- group by id2
-- )
-- select id2 from min_distance where min_dist >= (select avg(min_dist) from min_distance)
-- )
-- select p1.* from islington_polygons p1, points p2 where p1.osm_id = p2.id2 and p1.tags->>'building' is not null



-- with test as (
-- with clusters as (
-- 	with points as (
-- select st_centroid(geom) as centroid_geom, * from islington_polygons
-- )
-- select st_clusterkmeans(centroid_geom, 100) over() as cid, * from points
-- )


-- select cid, count(cid) as tmp from clusters
-- group by cid)
-- select avg(tmp) from test




-- with cluster_distances AS (
-- 	WITH cluster_centroids AS (
-- 		WITH clusters_bounds AS (
-- 			WITH clusters AS (
-- 				WITH points AS (
-- 					WITH buildings AS (
-- 						SELECT * 
-- 						FROM temp
-- 						WHERE tags->>'building' IS not null)
-- 					SELECT *, st_centroid(geom) AS centroid_geom
-- 					FROM buildings) 
-- 				SELECT st_clusterkmeans(geom, 100) --creates 100 clusters
-- 				over() AS cid, geom FROM points)
-- 			SELECT cid, st_convexhull(st_collect(geom)) as geom from clusters
-- 			group by cid)
-- 		select cid, ST_centroid(geom) as cluster_center from clusters_bounds)

-- 	select st_distance(c1.cluster_center, p1.geom) as dist, cid, p1.osm_id from cluster_centroids c1, polygons_far_from_road p1)
-- select p1.*, cid from islington_polygons p1 join 
-- (select c1.osm_id, cid from cluster_distances c1 join (select min(dist) as dist, osm_id from cluster_distances group by osm_id) as c2
-- on c1.dist = c2.dist and c1.osm_id = c2.osm_id) as tbl on p1.osm_id = tbl.osm_id




-- create table polygon_into_clusters as
-- WITH clusters AS (
-- WITH points AS (
-- WITH buildings AS (
--     SELECT * 
-- 	FROM temp
-- 	WHERE tags->>'building' IS not null
--     )
-- SELECT *, st_centroid(geom) AS centroid_geom
-- FROM buildings
-- ) 

-- SELECT st_clusterkmeans(geom, 100) --creates 100 clusters
-- over () 
-- AS cid, geom FROM points)
-- SELECT p1.*, cid from clusters c1 join islington_polygons p1 on c1.geom = p1.geom

-- insert into polygon_into_clusters
-- with cluster_distances AS (
-- 	WITH cluster_centroids AS (
-- 		WITH clusters_bounds AS (
-- 			WITH clusters AS (
-- 				WITH points AS (
-- 					WITH buildings AS (
-- 						SELECT * 
-- 						FROM temp
-- 						WHERE tags->>'building' IS not null)
-- 					SELECT *, st_centroid(geom) AS centroid_geom
-- 					FROM buildings) 
-- 				SELECT st_clusterkmeans(geom, 100) --creates 100 clusters
-- 				over() AS cid, geom FROM points)
-- 			SELECT cid, st_convexhull(st_collect(geom)) as geom from clusters
-- 			group by cid)
-- 		select cid, ST_centroid(geom) as cluster_center from clusters_bounds)

-- 	select st_distance(c1.cluster_center, p1.geom) as dist, cid, p1.osm_id from cluster_centroids c1, polygons_far_from_road p1)
-- select p1.*, cid from islington_polygons p1 join 
-- (select c1.osm_id, cid from cluster_distances c1 join (select min(dist) as dist, osm_id from cluster_distances group by osm_id) as c2
-- on c1.dist = c2.dist and c1.osm_id = c2.osm_id) as tbl on p1.osm_id = tbl.osm_id

-- select * from islington_lines where tags->>'name:en' = 'Dhobi Khola'

with centroids_temp as(
with cid_temp as(
with centroids_cid as
(select ST_Centroid(geom) as geom, cid
from polygon_into_clusters)
select cid, ST_ConcaveHull(st_collect(geom), 0.5) as concave_geom
from centroids_cid group by cid)
select p1.cid, st_union(c1.concave_geom, p1.geom) as geom from cid_temp c1, polygon_into_clusters p1 where p1.cid = c1.cid )
select st_union(geom) from centroids_temp group by cid








