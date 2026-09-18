--------------------------------------------------------------------------------
--
-- Расчет мотивации сотрудников
--
--------------------------------------------------------------------------------

--таблица w_motivation_coefficients
--
--

create table w_motivation_coefficients (
  id number(11),
  name varchar2(150),
  ids_value_setters varchar2(400),
  
  
  
  
  
  login varchar2(50),               -- логин на компьютере, не обязателен
  name varchar2(50) not null,       -- отображаемое имя
  pwd varchar2(50),                 -- пароль, не обязателен
  active number(1) default 0,       -- активен, без этого флага можно зайти только специально, после даблкликана картинке юзера по паролю входа под любым 
  autologin number(1) default 1,    -- возможен автологин пользователя при совпадении его логина и логина на компьютере
  job number(2) default 0,          -- должность пользователя, для разграничения в коде программы, варианты зашиты в код
  job_comm varchar2(150),           -- комментарий (должность, место работы)
  email varchar2(100),              -- адрес электронной почты, если он произвольный
  emailauto number(1) default 1,    -- признак что адрес формируется автоматически, по лиогину и домену 
  idletime number default 0,      -- время простоя программы, через которое она автоматически завершится (если нпе 0)
  constraint pk_adm_users primary key (id)
);

create sequence sq_adm_users nocache start with 1;

-- имя пользователя и логин уникальны с точностью до регистра
create unique index idx_adm_users_name on adm_users(lower(name));
create unique index idx_adm_users_name_2 on adm_users(name);
create unique index idx_adm_users_login on adm_users(lower(login));

/*
insert into adm_users (id, name, login) values (0, 'Администратор', 'Администратор');
*/
insert into adm_users (id, name, login, active, emailauto) values (-100, '[нет]', '', 0, 0);
insert into adm_users (id, name, login, active, emailauto) values (-101, '[конструктор]', '', 0, 0);
insert into adm_users (id, name, login, active, emailauto) values (-102, '[технолог]', '', 0, 0);
insert into adm_users (id, name, login, active, emailauto) values (-103, 'X', '', 0, 0);

--update adm_users set pwd = get_hash_val('9987') where id = 0;

create or replace trigger trg_adm_users_auid 
after update or insert or delete
on adm_users
begin
  update adm_mailing set userids = userids;
end;
/
