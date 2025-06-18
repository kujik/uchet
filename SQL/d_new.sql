
--производственные маршруты стандартных изделий
--drop table or_std_item_route cascade constraints;
create table or_std_item_route (
  id_or_std_item number(11),
  id_work_cell_type number(11),
  constraint pk_or_std_item_route primary key (id_or_std_item, id_work_cell_type),
  constraint fk_or_std_item_route_oi foreign key (id_or_std_item) references or_std_items(id) on delete cascade,
  constraint fk_or_std_item_route_wct foreign key (id_work_cell_type) references work_cell_types(id)
);   

delete from or_std_item_route;

alter table or_std_items add route varchar2(400);



--------------------------------------------------------------------------------
--v_or_std_items
--D ConvertNewOrStdItemRoutes