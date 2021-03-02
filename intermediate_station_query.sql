create or replace function intermediate_station_query(de_city varchar, arr_city varchar)
returns table(intermediate_ticket varchar)
as
$$
begin
    return query
select cast(intermediate_info as varchar)
from (
         select cast(search_two_city_g_d_c_seat(de_city,
                                                (select city from station where station_name = g_g.station_name)) as varchar)
                    || cast(search_two_city_g_d_c_seat((select city from station where station_name = g_g.station_name),
                                                       arr_city) as varchar)
                    intermediate_info
         from (
                  select g2.sno, g2.station_name
                  from g_d_c_train_info g1
                           join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                           join g_d_c_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                  intersect
                  select g4.sno, g4.station_name
                  from g_d_c_train_info g3
                           join station s2 on g3.station_name = s2.station_name and s2.city = arr_city
                           join g_d_c_train_info g4 on g3.tid = g4.tid and g3.sno > g4.sno
                  where g3.tid not in
                        (select g2.tid
                         from g_d_c_train_info g1
                                  join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                                  join g_d_c_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                        )
              ) g_g
     ) tmp_g
where intermediate_info is not null
    and split_part(split_part(intermediate_info,',',5),'_',1) <= split_part(split_part(intermediate_info,',',11),'_',1)
    and cast(case length(cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar) end as varchar)
            < cast(case length(cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar) end as varchar)
union all

select cast(intermediate_info as varchar)
from (
         select cast(search_two_city_t_k_z_seat_sleeper(de_city,
                                                (select city from station where station_name = g_g.station_name)) as varchar)
                    || cast(search_two_city_t_k_z_seat_sleeper((select city from station where station_name = g_g.station_name),
                                                       arr_city) as varchar)
                    intermediate_info
         from (
                  select g2.sno, g2.station_name
                  from t_k_z_train_info g1
                           join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                           join t_k_z_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                  intersect
                  select g4.sno, g4.station_name
                  from t_k_z_train_info g3
                           join station s2 on g3.station_name = s2.station_name and s2.city = arr_city
                           join t_k_z_train_info g4 on g3.tid = g4.tid and g3.sno > g4.sno
                  where g3.tid not in
                        (select g2.tid
                         from T_K_Z_train_info g1
                                  join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                                  join t_k_z_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                        )
              ) g_g
     ) tmp_g
where intermediate_info is not null
    and split_part(split_part(intermediate_info,',',5),'_',1) <= split_part(split_part(intermediate_info,',',11),'_',1)
    and cast(case length(cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar) end as varchar)
            < cast(case length(cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar) end as varchar)

union all

select cast(intermediate_info as varchar)
from (
         select cast(search_two_city_g_d_c_seat(de_city,
                                                (select city from station where station_name = g_g.station_name)) as varchar)
                    || cast(search_two_city_t_k_z_seat_sleeper((select city from station where station_name = g_g.station_name),
                                                       arr_city) as varchar)
                    intermediate_info
         from (
                  select g2.sno, g2.station_name
                  from g_d_c_train_info g1
                           join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                           join g_d_c_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                  intersect
                  select g4.sno, g4.station_name
                  from t_k_z_train_info g3
                           join station s2 on g3.station_name = s2.station_name and s2.city = arr_city
                           join t_k_z_train_info g4 on g3.tid = g4.tid and g3.sno > g4.sno
                  where g3.tid not in
                        (select g2.tid
                         from g_d_c_train_info g1
                                  join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                                  join g_d_c_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                        )
              ) g_g
     ) tmp_g
where intermediate_info is not null
    and split_part(split_part(intermediate_info,',',5),'_',1) <= split_part(split_part(intermediate_info,',',11),'_',1)
    and cast(case length(cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar) end as varchar)
            < cast(case length(cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar) end as varchar)
union all
select cast(intermediate_info as varchar)
from (
         select cast(search_two_city_t_k_z_seat_sleeper(de_city,
                                                (select city from station where station_name = g_g.station_name)) as varchar)
                    || cast(search_two_city_g_d_c_seat((select city from station where station_name = g_g.station_name),
                                                       arr_city) as varchar)
                    intermediate_info
         from (
                  select g2.sno, g2.station_name
                  from t_k_z_train_info g1
                           join station s1 on g1.station_name = s1.station_name and s1.city =de_city
                           join t_k_z_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                  intersect
                  select g4.sno, g4.station_name
                  from g_d_c_train_info g3
                           join station s2 on g3.station_name = s2.station_name and s2.city = arr_city
                           join g_d_c_train_info g4 on g3.tid = g4.tid and g3.sno > g4.sno
                  where g3.tid not in
                        (select g2.tid
                         from t_k_z_train_info g1
                                  join station s1 on g1.station_name = s1.station_name and s1.city = de_city
                                  join t_k_z_train_info g2 on g2.tid = g1.tid and g1.sno < g2.sno
                        )
              ) g_g
     ) tmp_g
where intermediate_info is not null
    and split_part(split_part(intermediate_info,',',5),'_',1) <= split_part(split_part(intermediate_info,',',11),'_',1)
    and cast(case length(cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',5),'_',2) as varchar) end as varchar)
            < cast(case length(cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar ))
             when 4 then '0'||cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar)
             else cast(split_part(split_part(intermediate_info,',',11),'_',2) as varchar) end as varchar);
end
$$
language plpgsql;