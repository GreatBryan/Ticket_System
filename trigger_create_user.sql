--users表更新
create table users(
    user_name varchar(10) unique,
    password varchar(50) not null,
    gender char(1) not null,
    student_remaining int not null,
    ID_num varchar(18) primary key,
    phone_num varchar(11) not null,
    authority char(1) not null
);

--log_order表格更新
create table log_order(
    log_id serial primary key,
    username varchar(10),
    adult_student varchar(10),
    tid varchar(10),
    ticket_gate varchar(10),
    depart_station varchar(10),
    arrive_station varchar(10),
    depart_time varchar(10),
    arrive_time varchar(10),
    seat_sleeper_type varchar(20),
    car_number int,
    seat_sleeper_number varchar(10),
    price_rmb float,
    constraint fr1 foreign key(username)
                             references users(user_name)
);

--插入用户触发器
create or replace function trigger_create_user()
    returns trigger
as
$$
declare
    in_id users.ID_num%type;
    ch_sum int;
begin
    if length(new.password) <=  8
        then raise exception 'The length of password is lower than 9';
    elseif length(new.password) >  15
        then raise exception 'The length of password is greater than 15';
    end if;
    if upper(new.gender) not in ('F','M')
        then raise exception 'The input gender is error';
        else new.authority = upper(new.authority);
    end if;
    if (length(new.phone_num) =  11 and substr(new.phone_num,1,1) in ('1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,2,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,3,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,4,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,5,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,6,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,7,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,8,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,9,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,10,1) in ('0','1','2','3','4','5','6','7','8','9')
        and substr(new.phone_num,11,1) in ('0','1','2','3','4','5','6','7','8','9'))
        then
    else raise exception 'The phone number is error';
    end if;
    if upper(new.authority) not in ('A','P','S')
        then raise exception 'The input authority is error';
        else new.authority = upper(new.authority);
    end if;
    new.password := md5(new.password);

    new.ID_num := upper(new.ID_num);
    in_id := new.ID_num;
    if length(in_id) < 18 or length(in_id) > 18
        then raise 'ID number is not valid';
        end if;
    if (select count(*) from (select substr(substr(t1.words, 1, 17),t2,1) x
            from (select cast(in_id as text) as words) t1
            cross join generate_series(1, 17) t2) z
        where z.x in('0','1','2','3','4','5','6','7','8','9') ) != 17
        then raise 'ID number is not valid';
        end if;
    if substr(in_id, 18, 1) not in('0','1','2','3','4','5','6','7','8','9', 'X')
        then raise 'ID number is not valid';
        end if;
    if cast(substr(in_id, 7, 4) as int) < 1900
        then raise 'ID number is not valid';
        end if;
    if cast(substr(in_id, 11, 2) as int) not in(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
        then raise 'ID number is not valid';
    end if;
    if cast(substr(in_id, 11, 2) as int) in(1, 3, 5, 7, 8, 10, 12)
        then if cast(substr(in_id, 13, 2) as int) > 31
                    or cast(substr(in_id, 13, 2) as int) < 1
                then raise 'ID number is not valid';
             end if;
    end if;
    if cast(substr(in_id, 11, 2) as int) in (4, 6, 9, 11)
        then if cast(substr(in_id, 13, 2) as int) > 30
                    or cast(substr(in_id, 13, 2) as int) < 1
                then raise 'ID number is not valid';
             end if;
    end if;
    if cast(substr(in_id, 11, 2) as int) = 2
        then if (cast(substr(in_id, 7, 4) as int) % 4 = 0
                    and cast(substr(in_id, 7, 4) as int) % 100 > 0 )
                or (cast(substr(in_id, 7, 4) as int) % 400 = 0)
                then if cast(substr(in_id, 13, 2) as int) > 29
                       or cast(substr(in_id, 13, 2) as int) < 1
                      then raise 'ID number is not valid';
                      end if;
             else if cast(substr(in_id, 13, 2) as int) > 28
                       or cast(substr(in_id, 13, 2) as int) < 1
                      then raise 'ID number is not valid';
                      end if;
             end if;
    end if;
    ch_sum = (select (12 - sum(mul) % 11) % 11 ch from (select x, case
    when z.t = 1 then z.x * 7
    when z.t = 2 then z.x * 9
    when z.t = 3 then z.x * 10
    when z.t = 4 then z.x * 5
    when z.t = 5 then z.x * 8
    when z.t = 6 then z.x * 4
    when z.t = 7 then z.x * 2
    when z.t = 8 then z.x * 1
    when z.t = 9 then z.x * 6
    when z.t = 10 then z.x * 3
    when z.t = 11 then z.x * 7
    when z.t = 12 then z.x * 9
    when z.t = 13 then z.x * 10
    when z.t = 14 then z.x * 5
    when z.t = 15 then z.x * 8
    when z.t = 16 then z.x * 4
    else z.x * 2 end as mul
      from (select cast(t2 as int) t , cast(substr(substr(t1.words, 1, 17),t2,1) as int) x
            from (select cast(in_id as text) as words) t1
            cross join generate_series(1, 17) t2) z) last);
    if (case substr(in_id, 18, 1) when 'X' then 10 else cast(substr(in_id, 18, 1) as int) end = ch_sum) = false
        then raise 'ID number is not valid';
    end if;
    return new;
end
$$
language plpgsql;

create trigger create_user
    before insert on users for each row
    execute procedure trigger_create_user();