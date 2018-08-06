DROP PROCEDURE `usp_ci_UploadSKUCodesFile`

GO

CREATE  PROCEDURE `usp_ci_UploadSKUCodesFile`(
    strPathFileName varchar(500)
)
BEGIN

declare recordcount integer;

declare uniquerecordcount integer;

declare recordcount2 integer;

declare uniquerecordcount2 integer;


drop temporary table if exists temp;

create temporary table temp
(
    SKUCode varchar(100) default '' null,
    UPC varchar(100) default '' null,
    Description varchar(100) default '' null,
    Channel varchar(100) default '' null,
    Customer varchar(100) default '' null
);


 

insert into temp
select *
from tblUploadSKUCodesFile;



delete
from    temp
where   SKUCode = 'SKUCode';


 drop temporary table if exists temp_validation;

create temporary table temp_validation
(
    SKUCode varchar(100) default '' null,
    UPC varchar(100) default '' null,
    Description varchar(100) default '' null,
    Channel varchar(100) default '' null,
    Customer varchar(100) default '' null,
    ChannelID int default 0 null,
    CustomerID int default 0 null,
    Active int default 1 null,
    ETimeStamp varchar(100) default '' null
);


insert into temp_validation(SKUCode,UPC,Description,Channel,Customer)
    select  SKUCode,UPC,Description,Channel,Customer
    from    temp;


update  temp_validation
set     Description = REPLACE(Description, '"', '');


update  temp_validation
set     SKUCode = REPLACE(SKUCode, '"', '');


update  temp_validation
set     UPC = REPLACE(UPC, '"', '');


update  temp_validation
set     Channel = REPLACE(Channel, '"', '');


update  temp_validation
set     Customer = REPLACE(Customer, '"', '');


update  temp_validation tv, Channels cha
set     tv.ChannelID = cha.ChannelID
where   tv.Channel = cha.ChannelName;


update  temp_validation tv, Customers cus
set     tv.CustomerID = cus.CustomerID
where   tv.Customer = cus.CustomerName;


drop temporary table if exists tmpReturn;

create temporary table tmpReturn
(ireturn1 int default 0 null,
 ireturn2 int default 0 null,
 ireturn3 int default 0 null,
 ireturn4 int default 0 null,
 ireturn5 int default 0 null,
 ireturn6 int default 0 null,
 ireturn7 int default 0 null,
 ireturn10 int default 0 null,
 SKUCode varchar(200) null,
 Description varchar(200) null,
 UPC varchar(200) null,
 Channel varchar(200) null,
 Customer varchar(200) null,
 ireturn11 int default 0 null);

 if exists(select 1 from	temp where SKUCode like '%,%') then                         
 	insert into tmpReturn (ireturn1)
    values (-1);

    select * from tmpReturn;

end if;

 if exists(select 1 from temp_validation where SKUCode is null) then          
 	insert into tmpReturn(ireturn3, UPC)
    select distinct -2, UPC from temp_validation where SKUCode is null;

end if;

if exists(select 1 from temp_validation where UPC is null) then          
	insert into tmpReturn(ireturn4, SKUCode)
    select distinct -3, SKUCode from temp_validation where UPC is null;

end if;

if exists(select 1 from temp_validation where Description is null) then          
	insert into tmpReturn(ireturn4, SKUCode)
    select distinct -4, SKUCode from temp_validation where Description is null;

end if;

if exists(select 1 from temp_validation where CustomerID is null ) then           
	update temp_validation
    set Customer = ''
    where CustomerID = 0;

end if;

if exists(select 1 from temp_validation where ChannelID is null) then        
	update temp_validation
    set Channel = ''
    where ChannelID = 0;

end if;

if exists(select 1 from temp_validation a inner join skucodes b on a.upc = b.upc) then           
	insert into tmpReturn(ireturn6, SKUCode, UPC)
    select distinct -6, a.SKUCode, b.UPC from temp_validation a inner join skucodes b on a.upc = b.upc;

end if;
if exists(select 1 from temp_validation a inner join skucodes b on a.skucode = b.skucode) then      -- duplicate skucode
    insert into tmpReturn(ireturn7, Description, SKUcode)
    select distinct -7, a.Description, b.SKUCode from temp_validation a inner join skucodes b on a.skucode = b.skucode;
end if;

 select  count(1)
into    recordcount2
from    temp_validation
where   SKUCode IS NOT NULL;


select  count(distinct SKUCode)
into    uniquerecordcount2
from    temp_validation
where   SKUCode IS NOT NULL;


drop temporary table if exists tmp_duplicate_skucodes;

create temporary table tmp_duplicate_skucodes
(
    skucode varchar (50)
);


if recordcount2 <> uniquerecordcount2 then           
		insert into tmp_duplicate_skucodes (skucode)
        select SKUCode
                from    temp_validation
                where   SKUCode is not null
                group by  SKUCode
                having  count(1) > 1;


    insert into tmpReturn(ireturn11, SKUCode)
    select
    distinct -11,
        tv.SKUCode
    from    temp_validation tv
    inner join tmp_duplicate_skucodes tmp
    on tv.skucode = tmp.skucode;


end if;


 select  count(1)
into    recordcount2
from    temp_validation
where   UPC IS NOT NULL;


select  count(distinct UPC)
into    uniquerecordcount2
from    temp_validation
where   UPC IS NOT NULL;


if recordcount2 <> uniquerecordcount2 then           
	insert into tmpReturn(ireturn5, UPC)
    select
    distinct -5,
        UPC
    from    temp_validation
    where   UPC in
        (select	UPC
        from    temp_validation
        where   UPC is not null
        group
        by  UPC
        having  count(1) > 1);

end if;

 
if not exists (select * from tmpReturn) then

    if exists(select 1 from information_schema.tables where table_name like '%tblSKUCodeList%') then
        drop table tblSKUCodeList;

    end if;


    create table tblSKUCodeList
    (
        SKUCode varchar(100) default '' null,
        UPC varchar(100) default '' null,
        Description varchar(100) default '' null,
        Channel varchar(100) default '' null,
        Customer varchar(100) default '' null,
        ChannelID int default 0 null,
        CustomerID int default 0 null,
        Active int default 1 null,
        ETimeStamp timestamp default CURRENT_TIMESTAMP,           
        ireturn1 int default 0 null,
        ireturn2 int default 0 null,
        ireturn3 int default 0 null,
        ireturn4 int default 0 null,
        ireturn5 int default 0 null,
        ireturn6 int default 0 null,
        ireturn7 int default 0 null,
        ireturn10 int default 0 null,
        ireturn11 int default 0 null,
        SKUCode1 varchar(100) default '' null
    );


    insert
    into    tblSKUCodeList
        (
        ireturn10,
        SKUCode,
        UPC,
        Description,
        Channel,
        Customer,
        ChannelID,
        CustomerID,
        Active
        )
    select  
		1,
        SKUCode,
        UPC,
        Description,
        Channel,
        Customer,
        ChannelID,
        CustomerID,
        Active
    from    temp_validation;


    insert into tmpReturn (ireturn10)
    values (1);


end if;

     if exists (select 1 from tmpReturn where ireturn10 = 1) then
        select  ireturn1,
                ireturn2,
                ireturn3,
                ireturn4,
                ireturn5,
                ireturn6,
                ireturn7,
                ireturn10,
                ireturn11,
                SKUCode,
                UPC,
                Description,
                Channel,
                Customer,
                ChannelID,
                CustomerID,
                Active
        from tblSKUCodeList;

    else
        select  ireturn1,
                ireturn2,
                ireturn3,
                ireturn4,
                ireturn5,
                ireturn6,
                ireturn7,
                ireturn10,
                SKUCode,
                UPC,
                Description,
                Channel,
                Customer,
                ireturn11
        from tmpReturn;

    end if;

 
END