create table ay_temp_referrer as
select 	params['rg_domain_id'] as domain_id,
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_page_host_url']), 'HOST')) as hosting_page,
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_referrer']), 'HOST')) as referrer,
	count(*) as count
from cocoon.data_primitives
where y = '2014' and m = '07' and d between '16' and '22'
group by params['rg_domain_id'],
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_page_host_url']), 'HOST')),
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_referrer']), 'HOST'))
having lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_page_host_url']), 'HOST')) is not null
	or lower(parse_url(reflect('java.net.URLDecoder','decode',params['rg_referrer']), 'HOST')) is not null
;

create table ay_temp_referrer_butterfly as
select p.domain_id,
	hosting_page,
	referrer,
	sum(count) as count
from (
select 	params['client.player_id'] as player_id,
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['client.page_url']), 'HOST')) as hosting_page,
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['client.referrer_url']), 'HOST')) as referrer,
	count(*) as count
from butterfly.data_primitive
where y = '2014' and m = '07' and d between '16' and '22'
group by params['client.player_id'],
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['client.page_url']), 'HOST')),
	lower(parse_url(reflect('java.net.URLDecoder','decode',params['client.referrer_url']), 'HOST'))
	) dp 
	join client_portal.players p
	on (dp.player_id = p.uuid)
group by p.domain_id,
	hosting_page,
	referrer
having 	hosting_page is not null or referrer is not null
;

select domain, 
	hosting_page,
	referrer,
	sum(count) as count
from (
select lower(regexp_replace(domain, '\s', '')) domain,
	hosting_page,
	referrer,
	sum(count) as count
from ay_temp_referrer r join domainlist_tableau_clean d
	on (r.domain_id = d.domain_uuid)
group by lower(regexp_replace(domain, '\s', '')),
	hosting_page,
	referrer
union all 
select lower(regexp_replace(domain, '\s', '')) domain,
	hosting_page,
	referrer,
	sum(count) as count
from ay_temp_referrer_butterfly r join domainlist_tableau_clean d
	on (r.domain_id = d.domain_uuid)
group by lower(regexp_replace(domain, '\s', '')),
	hosting_page,
	referrer
) tt
group by domain, 
	hosting_page,
	referrer
having 
;