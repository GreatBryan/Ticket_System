create or replace function search_two_City_T_K_Z_seat_sleeper(de_city varchar, arr_city varchar)
returns table(re_tid varchar, re_depart_station1 varchar, re_arrive_station1 varchar,
                re_de_time varchar, re_arr_time varchar, re_seat_type1 varchar, re_remaining1 bigint,
                re_price float)
as
$$
begin
    return query
select tmp1.tid, depart_station, arrive_station, cast(tmp1.de_date||'_'||tmp1.depart_time as varchar),
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar),seat_type, re,
       g6.hard_seat_price - g5.hard_seat_price price from (
with in1 as(
    select t.tid tid, t.station_name station_name, s.city city,
           t.arrive_time, t.depart_time,t.date, t.sno sno from t_k_z_train_info t
            join station s on t.station_name = s.station_name
        where s.city in (de_city,arr_city)
    )
select tid, depart_station, arrive_station, in2.depart_time, in2.arrive_time,de_date,arr_date, in2.seat_type,
       sum(seat_A) + sum(seat_B) + sum(seat_C) + sum(seat_D) + sum(seat_E) re from(
select in1_1.tid tid, in1.station_name depart_station, in1_1.station_name arrive_station,
       in1.depart_time, in1_1.arrive_time,in1.date de_date, in1_1.date arr_date, t.seat_type, t.car_number, t.seat_row,
       case sum(t.seat_A) when (in1_1.sno - in1.sno) then 1 else 0 end seat_A,
       case sum(t.seat_C) when (in1_1.sno - in1.sno) then 1 else 0 end seat_B,
       case sum(t.seat_C) when (in1_1.sno - in1.sno) then 1 else 0 end seat_C,
       case sum(t.seat_D) when (in1_1.sno - in1.sno) then 1 else 0 end seat_D,
       case sum(t.seat_E) when (in1_1.sno - in1.sno) then 1 else 0 end seat_E
        from in1
    join in1 in1_1
        on in1.tid = in1_1.tid and in1.city = de_city and in1_1.city = arr_city
    join  T_K_Z_seat t
        on t.tid = in1.tid and t.sno >= in1.sno and t.sno < in1_1.sno
group by (in1_1.tid, in1.station_name, in1_1.station_name, in1.depart_time, in1_1.arrive_time,
          t.seat_type, t.car_number, t.seat_row,in1.date, in1_1.date, in1.sno, in1_1.sno)) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,de_date,arr_date,seat_type)) tmp1
join t_k_z_train_info g5 on g5.tid = tmp1.tid and g5.station_name = tmp1.depart_station
    join t_k_z_train_info g6 on g6.tid = tmp1.tid and g6.station_name = tmp1.arrive_station

union all

select tmp2.tid, depart_station, arrive_station, cast(tmp2.de_date||'_'||tmp2.depart_time as varchar),
       cast(tmp2.arr_date||'_'||tmp2.arrive_time as varchar), sleeper_type, re,
       case sleeper_type when 'hard sleeper' then g6.hard_sleeper_price - g5.hard_sleeper_price
                      when 'soft sleeper' then g6.soft_sleeper_price - g5.soft_sleeper_price
                      end from(

with in3 as(
    select t.tid tid, t.station_name station_name, s.city city,
           t.depart_time, t.arrive_time,t.date, t.sno sno from t_k_z_train_info t
            join station s on t.station_name = s.station_name
        where s.city in (de_city,arr_city)
    )
select tid, depart_station, arrive_station, in4.depart_time, in4.arrive_time,
       in4.de_date, in4.arr_date,in4.sleeper_type,
       sum(sleeper_A) + sum(sleeper_B) + sum(sleeper_C) + sum(sleeper_D) + sum(sleeper_E) + sum(sleeper_F) re from(
    select in3_1.tid tid,in3.station_name depart_station,in3_1.station_name arrive_station,
           in3.depart_time,in3_1.arrive_time,
           in3.date de_date, in3_1.date arr_date,t.sleeper_type,t.car_number, t.sleeper_row,
       case sum(t.sleeper_a) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_A,
       case sum(t.sleeper_b) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_B,
       case sum(t.sleeper_c) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_C,
       case sum(t.sleeper_d) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_D,
       case sum(t.sleeper_e) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_E,
       case sum(t.sleeper_f) when (in3_1.sno - in3.sno) then 1 else 0 end sleeper_F

    from in3
    join in3 in3_1
        on in3.tid = in3_1.tid and in3.city = de_city and in3_1.city = arr_city
    join  T_K_Z_sleeper t
        on t.tid = in3.tid and t.sno >= in3.sno and t.sno < in3_1.sno
group by (in3_1.tid, in3.station_name, in3_1.station_name, in3.depart_time, in3_1.arrive_time,
          in3.date, in3_1.date,
          t.sleeper_type, t.car_number, t.sleeper_row, in3.sno, in3_1.sno)) in4
group by (tid,depart_station,arrive_station,in4.depart_time,in4.de_date, in4.arr_date, in4.arrive_time,sleeper_type)) tmp2
    join t_k_z_train_info g5 on g5.tid = tmp2.tid and g5.station_name = tmp2.depart_station
    join t_k_z_train_info g6 on g6.tid = tmp2.tid and g6.station_name = tmp2.arrive_station;
end
$$
language plpgsql;