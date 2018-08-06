DROP PROCEDURE if exists `usp_ci_upload_mdc_data_job`;



CREATE  PROCEDURE `usp_ci_upload_mdc_data_job`(
    strPathFileName varchar(500),
    int_eperiod int,
    int_eyear int
)
BEGIN


declare recordcount integer;
declare uniquerecordcount integer;

drop temporary table if exists temp;
create temporary table temp(
    rowid int AUTO_INCREMENT NOT NULL,
    eyear varchar(100),
    eperiod varchar(100),
    mdccode varchar(100),
    branchcode varchar(100),
    productcode varchar(100),
    quantity varchar(100),
    clientid varchar (100),
    clientcodeid varchar (100),
    skuid varchar (100),
    skucodeid varchar (100),
    customerid varchar(100),
    channelid varchar(100),
    distributorid varchar(100),
    PRIMARY KEY (`rowid`));

insert into temp (mdccode, branchcode, productcode, quantity ,eyear, eperiod)
    select mdccode, concat(branchcode,'-',branchcode), 
    concat(productcode,'-','MDC'), quantity, 2018, 3 from tbl_upload_mdc_data;
/*truncate table tbl_upload_mdc_data;
select * from tbl_upload_mdc_data;*/


delete from temp
    where mdccode in ('1','3','4','5') or quantity = 'QUANTITY'; 

update  temp a
    left join clientcodes b on a.branchcode = b.clientcode
    left join clientcodesdefn c on b.clientcodeid  = c.clientcodeid
    left join clients d on c.clientid = d.clientid
    set a.clientid = d.clientid, a.clientcodeid = b.clientcodeid;

update temp a 
    left join skucodes b on a.productcode = b.skucode
    left join skucodesdefn c on b.skucodeid = c.skucodeid
    left join skus d on c.skuid = d.skuid
    set a.skuid = d.skuid, a.skucodeid = c.skucodeid;

update  temp a 
    left join clients b on a.clientid = b.clientid
    left join datasourceoffilesclientdefn c on b.clientid = c.clientid
    left join datasourceoffiles d on c.datasourceoffilesid = d.datasourceoffilesid
    set a.distributorid = d.datasourceoffilesid;

update  temp a 
    left join clients b ON a.clientid = b.clientid
    left join channels c on b.channel = c.channelname 
    set a.channelid = c.channelid;

  
update temp a 
	left join clients b on a.clientid = b.clientid
	left join customers c on b.customerid = c.customerid
	set a.customerid = c.customerid;
	/*
	select * from transferdata where clientid = 73484 and skuid = 256
	select * from skuhistoricalprice
	select * from clientcodesdefn where clientcodeid  = 84602
	select * from clientcodes where clientcode = 1108
	select * from clients where icc = 1108
	select * from temp where clientid = 73484
select * from customercodes;
select * from clientcodes where clientcodeid = 84602;
select * from skucodes where skucodeid = 48037

select * from customers;*/
drop temporary table if exists temp_validation;
create temporary table temp_validation(
    rowid int,
    eyear varchar(100) default '',
    eperiod varchar(100) default '',
    mdccode varchar(100) default '',
    branchcode varchar(100) default '',
    productcode varchar(100) default '',
    quantity varchar(100) default '',
    errordescription varchar(100) default '',
    clientid varchar (100),
    clientcodeid varchar (100),
    skuid varchar (100),
    skucodeid varchar (100),
    customerid varchar(100),
    channelid varchar(100),
    distributorid varchar(100)
);

insert into temp_validation(rowid, mdccode, branchcode, productcode, quantity, eyear, eperiod,clientid, clientcodeid,skuid, skucodeid,customerid, channelid, distributorid )
select rowid, mdccode, branchcode, productcode, quantity, eyear, eperiod,clientid, clientcodeid,skuid, skucodeid,customerid, channelid, distributorid  from temp;


update temp_validation
    set mdccode = replace(mdccode, '"', '');
update temp_validation
    set branchcode = replace(branchcode, '"', '');
update temp_validation
    set productcode = replace(productcode, '"', '');

update temp_validation
    set quantity = replace(quantity, '"', '');


drop temporary table if exists tmpReturn;
create temporary table tmpReturn 
    (
    ireturn1 int default 0,
    ireturn2 int default 0, 
    ireturn3 int default 0,  
    ireturn4 int default 0, 
    ireturn5 int default 0, 
    ireturn6 int default 0, 
    ireturn7 int default 0,  
    ireturn8 int default 0,  
    ireturn10 int default 0, 
    rowid varchar(100) default '',
    eyear varchar(100) default '',
    eperiod varchar(100) default '',
    mdccode varchar(100) default '',
    branchcode varchar(100) default '',
    productcode varchar(100) default '',
    quantity varchar(100) default '',
	errordescription varchar(100) default '',
    clientid varchar (100) default '',
    clientcodeid varchar (100) default '',
    skuid varchar (100) default '',
    skucodeid varchar (100) default '',
    customerid varchar(100) default '',
    channelid varchar(100) default '',
    distributorid varchar(100)  default ''
    );

if exists(select 1 from temp where branchcode like '%,%') then 
    insert into tmpReturn (ireturn1)
    values (-1);
end if;

if exists(select * from temp_validation where branchcode = "-") then            
    insert into tmpReturn(ireturn2, rowid, branchcode, errordescription)
    select distinct -2, rowid, branchcode, 'Branch Code does not exist' from temp_validation where branchcode = "-";
end if;

if exists(select * from temp_validation where productcode = "-MDC") then     
    insert into tmpReturn(ireturn3, rowid, productcode, errordescription)
    select distinct -3, rowid, productcode, 'Product Code does not exist'  from temp_validation where productcode = "-MDC";
end if;

if exists(select * from temp_validation where quantity = "" and quantity is null) then            
    insert into tmpReturn(ireturn4, rowid, quantity, errordescription)
    select distinct -4, rowid, quantity, 'Quantity does not exist'  from temp_validation where quantity = "" and quantity is null;
end if;

if exists(select * from clientcodes a right join temp_validation b on a.clientcode = b.branchcode 
	where a.clientcode is null and b.branchcode <> "") then
	
	insert into tmpReturn(ireturn5, rowid, branchcode, errordescription) 
	select distinct -5, rowid , b.branchcode, 'Branch Code not yet enrolled' 
	from clientcodes a right join temp_validation b on a.clientcode = b.branchcode 
	where a.clientcode is null and b.branchcode <> "";
	
end if;

select  count(1)
into    recordcount
from    temp_validation
where   branchcode IS NOT NULL and productcode IS NOT NULL;

select  count(distinct branchcode, productcode) 
into    uniquerecordcount
from    temp_validation
where   branchcode IS NOT NULL and productcode IS NOT NULL;

if recordcount <> uniquerecordcount then      
    insert into tmpReturn(ireturn6, rowid, branchcode, productcode, errordescription)
    
    select 
    distinct -6, 
        rowid, branchcode,productcode, 'Duplicate row'
    from    temp_validation
    where   branchname is not null
    group by   branchname
    having  count(1) > 1;   
end if;

if exists(select * from skucodes a right join temp_validation b on a.skucode = b.productcode 
	where a.skucode is null and b.productcode <> "") then
	
	insert into tmpReturn(ireturn7, rowid, productcode, errordescription) 
	select distinct -7, rowid , b.productcode, 'Product Code not yet enrolled' 
	from skucodes a right join temp_validation b on a.skucode = b.productcode 
	where a.skucode is null and b.productcode <> "";
	
end if;

if exists(select * from clientcodes a inner join temp_validation b on a.clientcode = b.branchcode 
		where a.channelid = "" or a.customerid = ""  or a.channelid = 0 or a.customerid = 0) then
		
		insert into tmpReturn(ireturn8, rowid, productcode, errordescription)
		select distinct -8, b.rowid, b.branchcode, 'Product code not yet enrolled'
		from clientcodes a inner join temp_validation b on a.clientcode = b.branchcode 
		where a.channelid = "" or a.customerid = ""  or a.channelid = 0 or a.customerid = 0;
		
end if;

truncate table tbl_mdc_errorlist;
if not exists(select * from tbl_mdc_list) then 
	insert 
	into tbl_mdc_errorlist(
		eyear,
	    eperiod,
	    mdccode,
	    branchcode,
	    productcode,
	    quantity,
	    errordescription,
	    clientid,
	    clientcodeid,
	    skuid,
	    skucodeid,
	    customerid,
	    channelid,
	    distributorid)
	    
	select distinct
		
		eyear,
	    eperiod,
	    mdccode,
	    branchcode,
	    productcode,
	    quantity,
	    errordescription,
	    clientid,
	    clientcodeid,
	    skuid,
	    skucodeid,
	    customerid,
	    channelid,
	    distributorid
	    from tmpReturn;
	    
	    
end if;
		

if not exists (select * from tmpReturn) then

	truncate table tbl_mdc_list ;

    insert 
    into   tbl_mdc_list
   (eyear,
    eperiod,
    mdccode,
    branchcode,
    productcode,
    quantity,
    clientid,
    clientcodeid,
    skuid,
    skucodeid,
    customerid,
    channelid,
    distributorid)
    
    select distinct
    eyear,
    eperiod,
    mdccode,
    branchcode,
    productcode,
    quantity,
    clientid,
    clientcodeid,
    skuid,
    skucodeid,
    customerid,
    channelid,
    distributorid
    from    temp_validation;

	insert into tmpReturn (ireturn10)
    values (1);

end if;

truncate table tmp_mdc;

INSERT INTO tmp_mdc
 select 
    ireturn1,
    ireturn2, 
    ireturn3,  
    ireturn4, 
    ireturn5, 
    ireturn6, 
    ireturn7,
    ireturn8,  
    ireturn10, 
    rowid,
    eyear,
    eperiod,
    mdccode,
    branchcode,
    productcode,
    quantity,
    errordescription,
    clientid,
    clientcodeid ,
    skuid,
    skucodeid,
    customerid,
    channelid,
    distributorid 
    from tmpReturn;


end;