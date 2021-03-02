create or replace procedure order_withdraw(in_log_id int)
as
$$
    declare
        get_tid varchar;
        get_de_name varchar;
        get_arr_name varchar;
        get_de_sno int;
        get_arr_sno int;
        get_car_num int;
        get_seat_type varchar;
        get_seat_row int;
        get_seat_char varchar;
        get_ticket_type varchar;
    begin
        get_ticket_type := (select adult_student from log_order where log_id = in_log_id);
        if(get_ticket_type = 'student')then
            update users set student_remaining = student_remaining + 1
            where user_name = (select username from log_order where log_id = in_log_id);
        end if;
        get_tid := (select tid from log_order where log_id = in_log_id);
        get_de_name := (select depart_station from log_order where log_id = in_log_id);
        get_arr_name := (select arrive_station from log_order where log_id = in_log_id);
        get_car_num := (select car_number from log_order where log_id = in_log_id);
        get_seat_type := (select seat_sleeper_type from log_order where log_id = in_log_id);
        get_seat_row := (select case length(seat_sleeper_number)
                            when 2 then cast(substr(seat_sleeper_number,1,1) as int)
                            else cast(substr(seat_sleeper_number,1,2) as int) end from log_order where log_id = in_log_id);
        get_seat_char := (select case length(seat_sleeper_number)
                            when 2 then substr(seat_sleeper_number,2,1)
                            else substr(seat_sleeper_number,3,1) end from log_order where log_id = in_log_id);
        if( (select seat_sleeper_type from log_order where log_id = in_log_id) = 'hard seat') then
            get_de_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_de_name);
            get_arr_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_arr_name);
            if(get_seat_char = 'A') then
                update t_k_z_seat t set seat_a = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'B') then
                update t_k_z_seat t set seat_b = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'C') then
                update t_k_z_seat t set seat_c = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'D') then
                update t_k_z_seat t set seat_d = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'E') then
                update t_k_z_seat t set seat_e = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            end if;

        elseif( (select seat_sleeper_type from log_order where log_id = in_log_id) = 'hard sleeper') then
            get_de_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_de_name);
            get_arr_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_arr_name);
            if(get_seat_char = 'A') then
                update t_k_z_sleeper t set sleeper_a = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'B') then
                update t_k_z_sleeper t set sleeper_b = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'C') then
                update t_k_z_sleeper t set sleeper_c = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'D') then
                update t_k_z_sleeper t set sleeper_d = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'E') then
                update t_k_z_sleeper t set sleeper_e = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'F') then
                update t_k_z_sleeper t set sleeper_f = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            end if;
        elseif( (select seat_sleeper_type from log_order where log_id = in_log_id) = 'soft sleeper') then
            get_de_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_de_name);
            get_arr_sno := (select sno from t_k_z_train_info where tid = get_tid and station_name = get_arr_name);
            if(get_seat_char = 'A') then
                update t_k_z_sleeper t set sleeper_a = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'B') then
                update t_k_z_sleeper t set sleeper_b = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'C') then
                update t_k_z_sleeper t set sleeper_c = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            elseif(get_seat_char = 'D') then
                update t_k_z_sleeper t set sleeper_d = 1
                    where t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.sleeper_type = get_seat_type
                          and t.sleeper_row = get_seat_row;
            end if;

    else
        get_seat_type := (select seat_sleeper_type from log_order where log_id = in_log_id);
        get_de_sno := (select sno from g_d_c_train_info where tid = get_tid and station_name = get_de_name);
        get_arr_sno := (select sno from g_d_c_train_info where tid = get_tid and station_name = get_arr_name);
        if(get_seat_char = 'A') then
                update g_d_c_seat t set seat_a = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'B') then
                update g_d_c_seat t set seat_b = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'C') then
                update g_d_c_seat t set seat_c = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'D') then
                update g_d_c_seat t set seat_d = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            elseif(get_seat_char = 'E') then
                update g_d_c_seat t set seat_e = 1
                    where t.tid = get_tid and t.sno >= get_de_sno and t.sno < get_arr_sno
                      and t.car_number = get_car_num and t.seat_type = get_seat_type
                          and t.seat_row = get_seat_row;
            end if;
    end if;
    delete from log_order where log_id = in_log_id;
    return;
    end
$$
language plpgsql;
