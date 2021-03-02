create or replace procedure order_product(in_user varchar, in_ticket_type varchar,
                                         in_tid varchar, in_de_station varchar,
                                         in_arr_station varchar, in_seat_type varchar)
as
$$
declare
    get_car_number int;
    get_seat_row int;
    get_seat_char varchar;
    get_price float;
begin
    in_ticket_type := lower(in_ticket_type);
    if in_ticket_type = 'student' then
        if(in_seat_type in ('soft sleeper','first class','business class'))then
            raise exception 'Cannot buy student ticket for soft sleeper, first class and business class';
        end if;
        if (select student_remaining from users where user_name = in_user) = 0 then
            raise exception 'Student tickets have been used up!';
        else update users set student_remaining = student_remaining - 1 where user_name = in_user;
        end if;
        elseif in_ticket_type = 'adult' then
        else
            raise exception 'The input of ticket_type is error!';
    end if;
    if(substr(in_tid,1,1) in ('G', 'D', 'C'))
        then
            if(
                (select count(*)
                 from (
                          select replace(split_part(cast(data as varchar), ',', 1), '(', '')              tid,
                                 split_part(cast(data as varchar), ',', 2)                                de_station,
                                 split_part(cast(data as varchar), ',', 3)                                arr_station,
                                 replace(split_part(cast(data as varchar), ',', 6), '"', '')              seat_type,
                                 cast(replace(split_part(cast(data as varchar), ',', 7), ')', '') as int) reamining
                          from (select search_two_station_g_d_c_seat as data
                                from (select '('||tmp1.tid||','|| depart_station||','||arrive_station||','||
                                             cast(tmp1.de_date||'_'||tmp1.depart_time as varchar)||','||
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar)||','||seat_type||','|| re||','||
       case seat_type when 'first class' then g6.first_class_price - g5.first_class_price
                      when 'second class' then g6.second_class_price - g5.second_class_price
                      when 'business class' then g6.business_class_price - g5.business_class_price
                      end||')' search_two_station_g_d_c_seat from(
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
        on g_in.tid = g_in_1.tid and g_in.station_name = in_de_station and g_in_1.station_name = in_arr_station
    join G_D_C_seat g
        on g.tid = g_in.tid and g.sno >= g_in.sno and g.sno < g_in_1.sno
group by (g_in_1.tid, g_in.station_name, g_in_1.station_name,g_in.depart_time,
          g_in_1.arrive_time,g_in.date, g_in_1.date, g.seat_type, g.car_number, g.seat_row, g_in_1.sno, g_in.sno)) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,de_date, arr_date,seat_type) ) tmp1
    join G_D_C_train_info g5 on g5.tid = tmp1.tid and g5.station_name = tmp1.depart_station
    join G_D_C_train_info g6 on g6.tid = tmp1.tid and g6.station_name = tmp1.arrive_station) tmp1) tmp2) tmp3
                 where tid = in_tid
                   and de_station = in_de_station
                   and arr_station = in_arr_station
                   and seat_type = in_seat_type
                   and reamining > 0
                ) >= 1) then
                get_car_number := (select car_number from (select car_number, seat_row, case (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from g_d_c_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                get_seat_row := (select seat_row from (select car_number, seat_row, case (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from g_d_c_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                get_seat_char := (select is_re from (select car_number, seat_row, case (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from g_d_c_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                get_price := (select case in_seat_type
                        when 'first class' then g2.first_class_price - gdc.first_class_price
                        when 'second class' then g2.second_class_price - gdc.second_class_price
                        when 'business class' then g2.business_class_price - gdc.business_class_price
                        end from G_D_C_train_info gdc
                                join G_D_C_train_info g2 on gdc.tid = g2.tid
                                where gdc.tid = in_tid and gdc.station_name = in_de_station
                                   and g2.station_name = in_arr_station
                             );
                if(in_ticket_type = 'student')then
                    get_price := round(cast(get_price as numeric) * 0.75, 1);
                end if;

                insert into log_order(username,adult_student,tid, ticket_gate, depart_station, arrive_station,depart_time,
                                      arrive_time, seat_sleeper_type, car_number, seat_sleeper_number,price_rmb)
                    values(in_user, in_ticket_type,in_tid,
               cast(ceil(random() * 16) as varchar) ||
                           case ceil(random() * 2) when 1 then 'A' else 'B' end,
                           in_de_station, in_arr_station,
                           (select cast(date||'_'||depart_time as varchar) from g_d_c_train_info where tid = in_tid and station_name = in_de_station),
                           (select cast(date||'_'||arrive_time as varchar) from g_d_c_train_info where tid = in_tid and station_name = in_arr_station),
                           in_seat_type, get_car_number,get_seat_row || get_seat_char,get_price
                            );
                if(get_seat_char = 'A') then
                    update g_d_c_seat g set seat_a = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'B')then
                    update g_d_c_seat g set seat_b = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'C')then
                    update g_d_c_seat g set seat_c = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'D')then
                    update g_d_c_seat g set seat_d = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'E')then
                    update g_d_c_seat g set seat_e = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from G_D_C_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                end if;
                else
                   raise exception 'There is no remaining ticket.';
            end if;
    else
        if(
                (select count(*)
                 from (
                          select replace(split_part(cast(data as varchar), ',', 1), '(', '')              tid,
                                 split_part(cast(data as varchar), ',', 2)                                de_station,
                                 split_part(cast(data as varchar), ',', 3)                                arr_station,
                                 replace(split_part(cast(data as varchar), ',', 6), '"', '')              seat_type,
                                 cast(replace(split_part(cast(data as varchar), ',', 7), ')', '') as int) reamining
                          from (select search_two_station_t_k_z_seat_sleeper as data
                                from (select '('||tmp1.tid||','|| depart_station||','|| arrive_station||','|| cast(tmp1.de_date||'_'||tmp1.depart_time as varchar)||','||
       cast(tmp1.arr_date||'_'||tmp1.arrive_time as varchar)||','|| seat_type||','||re||','||
       g6.hard_seat_price - g5.hard_seat_price ||')' search_two_station_t_k_z_seat_sleeper  from(
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
        on g_in.tid = g_in_1.tid and g_in.station_name = in_de_station and g_in_1.station_name = in_arr_station
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
        on g2_in.tid = g2_in_1.tid and g2_in.station_name = in_de_station and g2_in_1.station_name = in_arr_station
    join T_K_Z_sleeper g2
        on g2.tid = g2_in.tid and g2.sno >= g2_in.sno and g2.sno < g2_in_1.sno
group by (g2_in_1.tid, g2_in.station_name, g2_in_1.station_name, g2_in.depart_time, g2_in_1.arrive_time,
          g2_in.date, g2_in_1.date,g2.sleeper_type
         ,g2.car_number, g2.sleeper_row, g2_in.sno, g2_in_1.sno)) in2
group by (tid,depart_station,arrive_station,in2.depart_time, in2.arrive_time,in2.de_date,in2.arr_date,sleeper_type)) tmp2
    join t_k_z_train_info g5 on g5.tid = tmp2.tid and g5.station_name = tmp2.depart_station
    join t_k_z_train_info g6 on g6.tid = tmp2.tid and g6.station_name = tmp2.arrive_station) tmp1) tmp2) tmp3
                 where tid = in_tid
                   and de_station = in_de_station
                   and arr_station = in_arr_station
                   and seat_type = in_seat_type
                   and reamining > 0
                ) >= 1) then
              if (in_seat_type = 'hard seat') then
              get_car_number := (select car_number from (select car_number, seat_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from T_K_Z_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
              get_seat_row := (select seat_row from (select car_number, seat_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from t_k_z_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
              get_seat_char := (select is_re from (select car_number, seat_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               else 'X' end is_re
                           from
                           (select car_number,seat_row, sum(seat_a) sum_a, sum(seat_b) sum_b, sum(seat_c) sum_c,
                                   sum(seat_d) sum_d, sum(seat_e) sum_e  from t_k_z_seat g
                            where g.tid = in_tid and g.seat_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,seat_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
              get_price := (select g2.hard_seat_price - gdc.hard_seat_price
                            from t_k_z_train_info gdc
                                join t_k_z_train_info g2 on gdc.tid = g2.tid
                                where gdc.tid = in_tid and gdc.station_name = in_de_station
                                   and g2.station_name = in_arr_station
                             );
              if(in_ticket_type = 'student')then
                    get_price := round(cast(get_price as numeric) * 0.5, 1);
                end if;
              insert into log_order(username, adult_student,tid, ticket_gate, depart_station, arrive_station,depart_time,
                                      arrive_time, seat_sleeper_type, car_number, seat_sleeper_number,price_rmb)
                    values(in_user, in_ticket_type,in_tid,
               cast(ceil(random() * 16) as varchar) ||
                           case ceil(random() * 2) when 1 then 'A' else 'B' end,
                           in_de_station, in_arr_station,
                           (select cast(date||'_'||depart_time as varchar) from t_k_z_train_info where tid = in_tid and station_name = in_de_station),
                           (select cast(date||'_'||arrive_time as varchar) from t_k_z_train_info where tid = in_tid and station_name = in_arr_station),
                           in_seat_type, get_car_number,get_seat_row || get_seat_char,get_price
                            );
              if(get_seat_char = 'A') then
                    update t_k_z_seat g set seat_a = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'B')then
                    update t_k_z_seat g set seat_b = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'C')then
                    update t_k_z_seat g set seat_c = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'D')then
                    update t_k_z_seat g set seat_d = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                elseif(get_seat_char = 'E')then
                    update t_k_z_seat g set seat_e = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.seat_row = get_seat_row and seat_type = in_seat_type;
                end if;
              elseif(in_seat_type = 'hard sleeper') then
                  get_car_number := (select car_number from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               when sum_f then 'F'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d, sum(sleeper_e) sum_e, sum(sleeper_f) sum_f from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_seat_row := (select sleeper_row from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               when sum_f then 'F'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d, sum(sleeper_e) sum_e, sum(sleeper_f) sum_f from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_seat_char := (select is_re from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               when sum_e then 'E'
                               when sum_f then 'F'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d, sum(sleeper_e) sum_e, sum(sleeper_f) sum_f from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_price := (select g2.hard_sleeper_price - gdc.hard_sleeper_price
                        from t_k_z_train_info gdc
                                join t_k_z_train_info g2 on gdc.tid = g2.tid
                                where gdc.tid = in_tid and gdc.station_name = in_de_station
                                   and g2.station_name = in_arr_station
                             );
                  if(in_ticket_type = 'student')then
                    get_price := round(cast((get_price - 0.5 * (select g2.hard_seat_price - gdc.hard_seat_price
                        from t_k_z_train_info gdc
                                join t_k_z_train_info g2 on gdc.tid = g2.tid
                                where gdc.tid = in_tid and gdc.station_name = in_de_station
                                   and g2.station_name = in_arr_station
                             )) as numeric), 1);
                end if;
                  insert into log_order(username,adult_student, tid, ticket_gate, depart_station, arrive_station,depart_time,
                                      arrive_time, seat_sleeper_type, car_number, seat_sleeper_number, price_rmb)
                    values(in_user,in_ticket_type, in_tid,
               cast(ceil(random() * 16) as varchar) ||
                           case ceil(random() * 2) when 1 then 'A' else 'B' end,
                           in_de_station, in_arr_station,
                           (select cast(date||'_'||depart_time as varchar) from T_K_Z_train_info where tid = in_tid and station_name = in_de_station),
                           (select cast(date||'_'||arrive_time as varchar) from t_k_z_train_info where tid = in_tid and station_name = in_arr_station),
                           in_seat_type, get_car_number,get_seat_row || get_seat_char,get_price
                            );
                  if(get_seat_char = 'A') then
                    update t_k_z_sleeper g set sleeper_a = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'B')then
                    update t_k_z_sleeper g set sleeper_b = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'C')then
                    update t_k_z_sleeper g set sleeper_c = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'D')then
                    update t_k_z_sleeper g set sleeper_d = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'E')then
                    update t_k_z_sleeper g set sleeper_e = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'F')then
                      update t_k_z_sleeper g set sleeper_f = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                end if;
              elseif(in_seat_type = 'soft sleeper') then
                  get_car_number := (select car_number from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_seat_row := (select sleeper_row from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_seat_char := (select is_re from (select car_number, sleeper_row, case (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station) -
                                         (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                               when sum_a then 'A'
                               when sum_b then 'B'
                               when sum_c then 'C'
                               when sum_d then 'D'
                               else 'X' end is_re
                           from
                           (select car_number,sleeper_row, sum(sleeper_a) sum_a, sum(sleeper_b) sum_b, sum(sleeper_c) sum_c,
                                   sum(sleeper_d) sum_d from T_K_Z_sleeper g
                            where g.tid = in_tid and g.sleeper_type = in_seat_type and
                                  g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)  and
                                  g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                            group by car_number,sleeper_row
                            ) tmp1) tmp2 where is_re != 'X' limit 1);
                  get_price := (select g2.soft_sleeper_price - gdc.soft_sleeper_price
                            from t_k_z_train_info gdc
                                join t_k_z_train_info g2 on gdc.tid = g2.tid
                                where gdc.tid = in_tid and gdc.station_name = in_de_station
                                   and g2.station_name = in_arr_station
                             );
                  insert into log_order(username,adult_student, tid, ticket_gate, depart_station, arrive_station,depart_time,
                                      arrive_time, seat_sleeper_type, car_number, seat_sleeper_number, price_rmb)
                    values(in_user,adult_student, in_tid,
               cast(ceil(random() * 16) as varchar) ||
                           case ceil(random() * 2) when 1 then 'A' else 'B' end,
                           in_de_station, in_arr_station,
                           (select cast(date||'_'||depart_time as varchar) from T_K_Z_train_info where tid = in_tid and station_name = in_de_station),
                           (select cast(date||'_'||arrive_time as varchar) from t_k_z_train_info where tid = in_tid and station_name = in_arr_station),
                           in_seat_type, get_car_number,get_seat_row || get_seat_char,get_price
                            );
                  if(get_seat_char = 'A') then
                    update t_k_z_sleeper g set sleeper_a = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'B')then
                    update t_k_z_sleeper g set sleeper_b = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'C')then
                    update t_k_z_sleeper g set sleeper_c = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                elseif(get_seat_char = 'D')then
                    update t_k_z_sleeper g set sleeper_d = 0 where g.tid = in_tid
                    and g.sno >= (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_de_station)
                    and g.sno < (select min(sno) from T_K_Z_train_info
                                            where tid = in_tid and station_name = in_arr_station)
                    and g.car_number = get_car_number and g.sleeper_row = get_seat_row and sleeper_type = in_seat_type;
                end if;
              end if;
        else
            raise exception 'There is no remaining ticket';
        end if;
        end if;
    return;
end
$$
language plpgsql;



