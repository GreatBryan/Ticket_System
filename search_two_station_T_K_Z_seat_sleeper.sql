create or replace function search_two_station_T_K_Z_seat_sleeper(de_station varchar, arr_station varchar)
returns table(re_tid varchar, re_depart_station1 varchar, re_arrive_station1 varchar,
                re_de_time varchar, re_rr_time varchar, re_seat_type1 varchar, re_remaining1 bigint,
                re_price float)
as
$$
begin
    return query
select tmp1.tid, depart_station, arrive_station, cast(tmp1.de_date||'_'||tmp1.depart_time as varchar),
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar),seat_type, re,
       g6.hard_seat_price - g5.hard_seat_price price from(
select tid, depart_station, arrive_station, in2.depart_time, in2.arrive_time,
       in2.de_date, in2.arr_date,in2.seat_type,
       sum(seat_A) + sum(seat_B) + sum(seat_C) + sum(seat_D) + sum(seat_E) re from(
select g_in_1.tid tid, g_in.station_name depart_station, g_in_1.station_name arrive_station,g.car_number,g.seat_row,
       g_in.depart_time, g_in_1.arrive_time,g_in.date de_date, g_in_1.date arr_date, g.seat_type,
       case sum(g.seat_A) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_A,
       case sum(g.seat_C) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_B,
       case sum(g.seat_C) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_C,
       case sum(g.seat_D) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_D,
       case sum(g.seat_E) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_E
    from T_K_Z_train_info g_in
    join T_K_Z_train_info g_in_1
        on g_in.tid = g_in_1.tid and g_in.station_name = de_station and g_in_1.station_name = arr_station
    join T_K_Z_seat g
        on g.tid = g_in.tid and g.sno >= g_in.sno and g.sno < g_in_1.sno
group by (g_in_1.tid, g_in.station_name, g_in_1.station_name, g_in.depart_time, g_in_1.arrive_time,
          g_in.date, g_in_1.date,g.seat_type,
         g.car_number, g.seat_row), g_in_1.sno, g_in.sno) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,in2.de_date, in2.arr_date, seat_type)) tmp1
    join t_k_z_train_info g5 on g5.tid = tmp1.tid and g5.station_name = tmp1.depart_station
    join t_k_z_train_info g6 on g6.tid = tmp1.tid and g6.station_name = tmp1.arrive_station

union all

select tmp2.tid, depart_station, arrive_station, cast(tmp2.de_date||'_'||tmp2.depart_time as varchar),
       cast(tmp2.arr_date||'_'||tmp2.arrive_time as varchar), sleeper_type, re,
       case sleeper_type when 'hard sleeper' then g6.hard_sleeper_price - g5.hard_sleeper_price
                      when 'soft sleeper' then g6.soft_sleeper_price - g5.soft_sleeper_price end from(
select tid, depart_station, arrive_station, in2.depart_time, in2.arrive_time,
       in2.de_date,in2.arr_date,in2.sleeper_type,
       sum(sleeper_A) + sum(sleeper_B) + sum(sleeper_C) + sum(sleeper_D) + sum(sleeper_E) + sum(sleeper_F) re from(
select g2_in_1.tid tid, g2_in.station_name depart_station, g2_in_1.station_name arrive_station,
       g2_in.depart_time, g2_in_1.arrive_time,g2_in.date de_date, g2_in_1.date arr_date,g2.sleeper_type, g2.car_number, g2.sleeper_row,
       case sum(g2.sleeper_a) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_A,
       case sum(g2.sleeper_b) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_B,
       case sum(g2.sleeper_c) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_C,
       case sum(g2.sleeper_d) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_D,
       case sum(g2.sleeper_e) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_E,
       case sum(g2.sleeper_f) when (g2_in_1.sno - g2_in.sno) then 1 else 0 end sleeper_F
    from T_K_Z_train_info g2_in
    join T_K_Z_train_info g2_in_1
        on g2_in.tid = g2_in_1.tid and g2_in.station_name = de_station and g2_in_1.station_name = arr_station
    join T_K_Z_sleeper g2
        on g2.tid = g2_in.tid and g2.sno >= g2_in.sno and g2.sno < g2_in_1.sno
group by (g2_in_1.tid, g2_in.station_name, g2_in_1.station_name, g2_in.depart_time, g2_in_1.arrive_time,
          g2_in.date, g2_in_1.date,g2.sleeper_type
         ,g2.car_number, g2.sleeper_row, g2_in.sno, g2_in_1.sno)) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,in2.de_date,in2.arr_date,sleeper_type)) tmp2
    join t_k_z_train_info g5 on g5.tid = tmp2.tid and g5.station_name = tmp2.depart_station
    join t_k_z_train_info g6 on g6.tid = tmp2.tid and g6.station_name = tmp2.arrive_station;
end
$$
language plpgsql;