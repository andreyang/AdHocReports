--This report is to provide the client team with insight that helps the migration to Butterfly.

drop table if exists ay_temp_rg_migration;
create table ay_temp_rg_migration as
select lower(reflect('java.net.URLDecoder', 'decode', params['rg_publisher'], 'utf-8')) publisher,
	regexp_replace(reflect('java.net.URLDecoder', 'decode', params['rg_page_host_url'], 'utf-8'), '[#?].*$', '') page_host_url,
	params['rg_player_uuid'] player_id,
	params['rg_guid'] video_id,
	params['rg_playlist_uuid'] playlist_id,
	count(*) video_content_begin
from cocoon.data_primitives
where y = '2014'
and m = '07'
and d between '01' and '25'
and params['rg_event'] IN ('playerMediaTime', 'jwplayerMediaTime') 
and params['rg_category'] like 'Stream%Progress' 
and (params['rg_counter'] like '%+0' or params['rg_counter'] like '%\%200')
group by lower(reflect('java.net.URLDecoder', 'decode', params['rg_publisher'], 'utf-8')),
	regexp_replace(reflect('java.net.URLDecoder', 'decode', params['rg_page_host_url'], 'utf-8'), '[#?].*$', ''),
	params['rg_playlist_uuid'],
	params['rg_guid'],
	params['rg_playlist_uuid']
having count(*) >= 100
;

select 	distinct b.company,
	a.publisher,
	a.page_host_url,
	a.player_id,
	a.playlist_id,
	a.video_id,
	c.title video_title,
	video_content_begin
from ay_temp_rg_migration a left outer join company_site_map b
	on (a.publisher = b.rg_publisher)
	left outer join client_portal.contents c
	on (a.video_id = c.uuid)
;