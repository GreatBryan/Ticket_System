create or replace function search_two_City_G_D_C_seat(de_city varchar, arr_city varchar)
returns table(re_tid varchar, re_depart_station1 varchar, re_arrive_station1 varchar,
                re_de_time varchar, re_arr_time varchar,
                re_seat_type1 varchar, re_remaining1 bigint,
                re_price float)
as
$$
begin
    return query
select tmp1.tid, depart_station, arrive_station, cast(tmp1.de_date||'_'||tmp1.depart_time as varchar),
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar),seat_type, re,
       case seat_type when 'first class' then g6.first_class_price - g5.first_class_price
                      when 'second class' then g6.second_class_price - g5.second_class_price
                      when 'business class' then g6.business_class_price - g5.business_class_price
                      end
from(
with in1 as(
    select g.tid tid, g.station_name station_name, s.city city, g.sno sno, g.depart_time,
           g.arrive_time, g.date from G_D_C_train_info g
            join station s on g.station_name = s.station_name
        where s.city in (de_city,arr_city)
    )
select tid, depart_station, arrive_station, in2.depart_time, in2.arrive_time,in2.de_date,in2.arr_date,in2.seat_type,
       sum(seat_A) + sum(seat_B) + sum(seat_C) + sum(seat_D) + sum(seat_E) re from(
    select in1_1.tid tid, in1.station_name depart_station, in1_1.station_name arrive_station,
       in1.depart_time, in1_1.arrive_time,in1.date de_date, in1_1.date arr_date, g.seat_type, g.car_number,g.seat_row,
       case sum(g.seat_A) when (in1_1.sno - in1.sno) then 1 else 0 end seat_A,
       case sum(g.seat_C) when (in1_1.sno - in1.sno) then 1 else 0 end seat_B,
       case sum(g.seat_C) when (in1_1.sno - in1.sno) then 1 else 0 end seat_C,
       case sum(g.seat_D) when (in1_1.sno - in1.sno) then 1 else 0 end seat_D,
       case sum(g.seat_E) when (in1_1.sno - in1.sno) then 1 else 0 end seat_E from in1
    join in1 in1_1
        on in1.tid = in1_1.tid and in1.city = de_city and in1_1.city = arr_city
    join G_D_C_seat g
        on g.tid = in1.tid and g.sno >= in1.sno and g.sno < in1_1.sno
    group by (in1_1.tid, in1.station_name, in1_1.station_name,in1.depart_time, in1_1.arrive_time,de_date,arr_date,
          g.seat_type, g.car_number,g.seat_row, in1.sno, in1_1.sno) ) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,in2.de_date,in2.arr_date,seat_type)
    )tmp1
    join G_D_C_train_info g5 on g5.tid = tmp1.tid and g5.station_name = tmp1.depart_station
    join G_D_C_train_info g6 on g6.tid = tmp1.tid and g6.station_name = tmp1.arrive_station;
end
$$
language plpgsql;
