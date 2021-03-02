create table station(
    station_name varchar(10) primary key,
    city varchar(10),
    address varchar(45)
);

create table G_D_C_train_info(
    tid varchar(10),
    sno int,
    station_name varchar(10),
    arrive_time varchar(10),
    depart_time varchar(10),
    date varchar(10),
    mileage int,
    first_class_price float,
    second_class_price float,
    business_class_price float,
    constraint fr foreign key(station_name)
                             references station(station_name),
    unique (tid, sno)
);

create table T_K_Z_train_info(
    tid varchar(10),
    sno int,
    station_name varchar(10),
    arrive_time varchar(10),
    depart_time varchar(10),
    date varchar(10),
    mileage int,
    hard_seat_price float,
    hard_sleeper_price float,
    soft_sleeper_price float,
    constraint fr foreign key(station_name)
                             references station(station_name),
    unique (tid, sno)
);

create table G_D_C_seat(
    tid varchar(10),
    sno int,
    car_number int,
    seat_type varchar(20),
    seat_row int,
    seat_a int,
    seat_b int,
    seat_c int,
    seat_d int,
    seat_e int,
    constraint fr foreign key(tid,sno)
                             references G_D_C_train_info(tid, sno),
    unique (tid, sno, car_number, seat_row)
);

create table T_K_Z_seat(
    tid varchar(10),
    sno int,
    car_number int,
    seat_type varchar(20),
    seat_row int,
    seat_a int,
    seat_b int,
    seat_c int,
    seat_d int,
    seat_e int,
    constraint fr foreign key(tid,sno)
                             references T_K_Z_train_info(tid, sno),
    unique (tid, sno, car_number, seat_row)
);

create table T_K_Z_sleeper(
    tid varchar(10),
    sno int,
    car_number int,
    sleeper_type varchar(20),
    sleeper_row int,
    sleeper_a int,
    sleeper_b int,
    sleeper_c int,
    sleeper_d int,
    sleeper_e int,
    sleeper_f int,
    constraint fr foreign key(tid,sno)
                             references T_K_Z_train_info(tid, sno),
    unique (tid, sno, car_number, sleeper_row)
);

create table users(
    user_name varchar(10) unique,
    password varchar(50) not null,
    gender char(1) not null,
    student_remaining int not null,
    ID_num varchar(18) primary key,
    phone_num varchar(11) not null,
    authority char(1) not null
);

create table log_order(
    log_id serial primary key,
    username varchar(10),
    adult_student varchar(10),
    tid varchar(10),
    ticket_gate varchar(10),
    depart_station varchar(10),
    arrive_station varchar(10),
    depart_time varchar(20),
    arrive_time varchar(20),
    seat_sleeper_type varchar(20),
    car_number int,
    seat_sleeper_number varchar(10),
    price_rmb float,
    constraint fr1 foreign key(username)
                             references users(user_name)
);