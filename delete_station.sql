create or replace function delete_station(in_tid varchar, in_station varchar)
returns varchar
as
$$
  declare
      de_sno int;
  begin
      if substr(in_tid,1,1) in ('G','D','C') then
          alter table g_d_c_seat drop constraint fr;
          de_sno := (select sno from g_d_c_train_info where tid = in_tid and station_name = in_station);
          delete from g_d_c_seat where tid = in_tid and sno = de_sno;
          delete from g_d_c_train_info where tid = in_tid and station_name = in_station;
          update g_d_c_seat set sno = sno - 1 where tid = in_tid and sno > de_sno;
          update g_d_c_train_info set sno = sno - 1 where tid = in_tid and sno > de_sno;
          alter table g_d_c_seat
	        add constraint fr
		     foreign key (tid, sno) references g_d_c_train_info (tid, sno);
      else
          alter table t_k_z_seat drop constraint fr;
          alter table t_k_z_sleeper drop constraint fr;

          de_sno := (select sno from t_k_z_train_info where tid = in_tid and station_name = in_station);
          delete from t_k_z_seat where tid = in_tid and sno = de_sno;
          delete from t_k_z_sleeper where tid = in_tid and sno = de_sno;
          delete from t_k_z_train_info where tid = in_tid and station_name = in_station;
          update t_k_z_seat set sno = sno - 1 where tid = in_tid and sno > de_sno;
          update t_k_z_sleeper set sno = sno - 1 where tid = in_tid and sno > de_sno;
          update t_k_z_train_info set sno = sno - 1 where tid = in_tid and sno > de_sno;
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