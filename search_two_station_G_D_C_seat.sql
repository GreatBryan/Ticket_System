create or replace function search_two_station_G_D_C_seat(de_station varchar, arr_station varchar)
returns table(re_tid varchar, re_depart_station1 varchar, re_arrive_station1 varchar,
                re_de_time varchar, re_arr_time varchar, re_seat_type1 varchar, re_remaining1 bigint
              ,re_price float)
as
$$
begin
    return query
select tmp1.tid, depart_station, arrive_station, cast(tmp1.de_date||'_'||tmp1.depart_time as varchar),
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar),seat_type, re,
       case seat_type when 'first class' then g6.first_class_price - g5.first_class_price
                      when 'second class' then g6.second_class_price - g5.second_class_price
                      when 'business class' then g6.business_class_price - g5.business_class_price
                      end from(
select tid, depart_station, arrive_station, in2.depart_time, in2.arrive_time,de_date, arr_date,in2.seat_type,
       sum(seat_A) + sum(seat_B) + sum(seat_C) + sum(seat_D) + sum(seat_E) re from(
select g_in_1.tid tid, g_in.station_name depart_station, g_in_1.station_name arrive_station,
       g_in.depart_time, g_in_1.arrive_time, g_in.date de_date, g_in_1.date arr_date, g.seat_type, g.car_number, g.seat_row,
       case sum(g.seat_A) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_A,
       case sum(g.seat_C) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_B,
       case sum(g.seat_C) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_C,
       case sum(g.seat_D) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_D,
       case sum(g.seat_E) when (g_in_1.sno - g_in.sno) then 1 else 0 end seat_E
    from G_D_C_train_info g_in
    join G_D_C_train_info g_in_1
        on g_in.tid = g_in_1.tid and g_in.station_name = de_station and g_in_1.station_name = arr_station
    join G_D_C_seat g
        on g.tid = g_in.tid and g.sno >= g_in.sno and g.sno < g_in_1.sno
group by (g_in_1.tid, g_in.station_name, g_in_1.station_name,g_in.depart_time,
          g_in_1.arrive_time,g_in.date, g_in_1.date, g.seat_type, g.car_number, g.seat_row, g_in_1.sno, g_in.sno)) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,de_date, arr_date,seat_type) ) tmp1
    join G_D_C_train_info g5 on g5.tid = tmp1.tid and g5.station_name = tmp1.depart_station
    join G_D_C_train_info g6 on g6.tid = tmp1.tid and g6.station_name = tmp1.arrive_station;

end
$$
language plpgsql;