create or replace function add_station
    (in_tid varchar, in_sno int, in_station varchar, in_arr_time varchar, in_de_time varchar,
     in_date varchar, in_mileage int, in_f_price float, in_s_price float, in_b_price float)
returns varchar
as
$$
  declare
  begin
      if substr(in_tid,1,1) in ('G','D','C') then
          alter table g_d_c_seat drop constraint fr;
          alter table g_d_c_train_info drop constraint g_d_c_train_info_tid_sno_key;
          alter table g_d_c_seat drop constraint g_d_c_seat_tid_sno_car_number_seat_row_key;

          update g_d_c_train_info set sno = sno + 1 where tid = in_tid and sno >= in_sno;
          update g_d_c_seat set sno = sno + 1 where tid = in_tid and sno >= in_sno;
          insert into g_d_c_train_info
              (tid, sno, station_name, arrive_time, depart_time, date,
               mileage, first_class_price, second_class_price, business_class_price)
               values (in_tid, in_sno, in_station, in_arr_time, in_de_time, in_date,
                       in_mileage, in_f_price, in_s_price, in_b_price);
          insert into G_D_C_seat (tid, sno, car_number, seat_type, seat_row, seat_a, seat_b, seat_c, seat_d, seat_e)
            select tid,sno, in1.car_number,
                case in1.car_number when 1 then 'business class' when 2 then 'business class'
                                    when 3 then 'first class' when 4 then 'first class'
                         else 'second class' end
                        seat_type, seat_row, 1,1,1,1,1
                from(
                    select tid, sno, station_name, t2 car_number
                            from  g_d_c_train_info
                             cross join generate_series(1, 8) t2
                    where substr(tid,1,1) in ('G','D','C')
                    ) in1
                cross join generate_series(1, 13) seat_row where tid = in_tid and sno = in_sno;
          alter table g_d_c_train_info add constraint g_d_c_train_info_tid_sno_key unique (tid,sno);
          alter table g_d_c_seat add constraint g_d_c_seat_tid_sno_car_number_seat_row_key unique(tid,sno,car_number,seat_row);
          alter table g_d_c_seat
	        add constraint fr
		     foreign key (tid, sno) references g_d_c_train_info (tid, sno);



      else
          alter table t_k_z_seat drop constraint fr;
          alter table t_k_z_sleeper drop constraint fr;
          alter table t_k_z_train_info drop constraint t_k_z_train_info_tid_sno_key;
          alter table t_k_z_seat drop constraint t_k_z_seat_tid_sno_car_number_seat_row_key;
          alter table t_k_z_sleeper drop constraint t_k_z_sleeper_tid_sno_car_number_sleeper_row_key;

          update t_k_z_train_info set sno = sno + 1 where tid = in_tid and sno >= in_sno;
          update t_k_z_seat set sno = sno + 1 where tid = in_tid and sno >= in_sno;
          update t_k_z_sleeper set sno = sno + 1 where tid = in_tid and sno >= in_sno;
          insert into T_K_Z_train_info(tid, sno, station_name, arrive_time, depart_time, date,
                                       mileage, hard_seat_price, hard_sleeper_price, soft_sleeper_price)
          values (in_tid, in_sno, in_station, in_arr_time, in_de_time,
                  in_date, in_mileage, in_f_price, in_s_price, in_b_price);

          insert into T_K_Z_seat (tid, sno, car_number, seat_type, seat_row, seat_a, seat_b, seat_c, seat_d, seat_e)
              select tid,sno, in1.car_number,
              'hard seat' seat_type, seat_row, 1,1,1,1,1
            from(
                    select tid, sno, station_name, t2 car_number
                        from  T_K_Z_train_info
                     cross join generate_series(1, 4) t2
                where substr(tid,1,1) in ('T','K','Z')) in1
             cross join generate_series(1, 13) seat_row where tid = in_tid and sno = in_sno;

          insert into T_K_Z_sleeper (tid, sno, car_number, sleeper_type, sleeper_row,
                                     sleeper_a,sleeper_b,sleeper_c,sleeper_d,sleeper_e,sleeper_f)
              select tid,sno, in1.car_number,
                case in1.car_number when 5 then 'hard sleeper' when 6 then 'hard sleeper'
                                       else 'soft sleeper' end
              seat_type,seat_row,1,1,1,1,
                     case in1.car_number when 5 then 1 when 6 then 1 else 0 end,
                     case in1.car_number when 5 then 1 when 6 then 1 else 0 end
            from(
                    select tid, sno, station_name, t2 car_number
                    from  T_K_Z_train_info
                     cross join generate_series(5, 8) t2
                where substr(tid,1,1) in ('T','K','Z')) in1
            cross join generate_series(1, 13) seat_row where tid = in_tid and sno = in_sno;



          alter table t_k_z_train_info add constraint t_k_z_train_info_tid_sno_key unique (tid,sno);
          alter table t_k_z_seat add constraint t_k_z_seat_tid_sno_car_number_seat_row_key unique (tid,sno,car_number,seat_row);
          alter table t_k_z_sleeper add constraint t_k_z_sleeper_tid_sno_car_number_sleeper_row_key unique (tid,sno,car_number,sleeper_row);
          alter table t_k_z_seat
	        add constraint fr
		     foreign key (tid, sno) references t_k_z_train_info (tid, sno);
          alter table t_k_z_sleeper
	        add constraint fr
		     foreign key (tid, sno) references t_k_z_train_info (tid, sno);
      end if;
      return null;
  end
$$
language plpgsql;