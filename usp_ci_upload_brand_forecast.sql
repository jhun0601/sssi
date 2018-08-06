DROP PROCEDURE if exists `usp_ci_upload_brand_forecast_adjustment`;



CREATE  PROCEDURE `usp_ci_upload_brand_forecast_adjustment`(
    eyear int,
    eperiod int
)
BEGIN


declare recordcount integer;
declare uniquerecordcount integer;
declare recordcount2 integer;
declare uniquerecordcount2 integer;

declare int_total_rows int default 0;
declare int_counter int default 0;
declare int_counter2 int default 0;

declare brand_flag int;
declare int_brandid int;
declare str_brand varchar(50);
declare str_forcasted_value varchar(50);


drop temporary table if exists temp;


create temporary table temp
	(
		rowid int AUTO_INCREMENT NOT NULL,
	 	BrandName varchar(100) default '',
		column30 varchar(100),
		Jan1 varchar(100),
		Feb1 varchar(100),
		Mar1 varchar(100),
		Apr1 varchar(100),
		May1 varchar(100),
		Jun1 varchar(100),
		Jul1 varchar(100),
		Aug1 varchar(100),
		Sept1 varchar(100),
		Oct1 varchar(100),
		Nov1 varchar(100),
		Dec1 varchar(100),
		column43 varchar(100),
		column44 varchar(100),
		Jan2 varchar(100),
		Feb2 varchar(100),
		Mar2 varchar(100),
		Apr2 varchar(100),
		May2 varchar(100),
		Jun2 varchar(100),
		Jul2 varchar(100),
		Aug2 varchar(100),
		Sept2 varchar(100),
		Oct2 varchar(100),
		Nov2 varchar(100),
		Dec2 varchar(100),
		column57 varchar(100),
		EYEAR  varchar(100) default '',
		f_Period int,
		PRIMARY KEY (`rowid`)
	);




insert into temp
(BrandName,Column30,Jan1,Feb1,Mar1,Apr1,May1,Jun1,Jul1,Aug1,Sept1,Oct1,Nov1,Dec1,Column43,Column44,
Jan2,Feb2,Mar2,Apr2,May2,Jun2,Jul2,Aug2,Sept2,Oct2,Nov2,Dec2,Column57, EYEAR, f_Period)
select 
	Column2,Column30,Column31,Column32,Column33,Column34,Column35,Column36,
	Column37,Column38,Column39,Column40,Column41,Column42,Column43,Column44,Column45,Column46,Column47,Column48,
	Column49,Column50,Column51,Column52,Column53,Column54,Column55,Column56,Column57,2018,4
from tbl_upload_brands_forecast_adjustment;

drop temporary table if exists tmp_brand_forecast_adjustment;
create temporary table tmp_brand_forecast_adjustment(
 	`trans_id` int AUTO_INCREMENT not null, 
    `Brandid` int null,
    `Brandname` varchar(50),
    `forcasted_value` varchar(50),
    `eyear` int null, 
    `eperiod` int null,
    `fyear` int null,
    `fperiod` int null,
PRIMARY KEY (`trans_id`)
) ENGINE=InnoDB  COLLATE=utf8_general_ci ; 


select count(1) into int_total_rows from temp;

set int_counter = 1;
set @field_counter = eperiod;

-- current eyear
-- From Selected Month to December
while (int_counter <= int_total_rows) do 
	
	if (@field_counter = 1) then
	
		set brand_flag = 1; 
		select brandname, jan1 into str_brand, str_forcasted_value from temp where rowid = int_counter;

		if(int_counter = int_total_rows)then
			set int_counter = 0;
			set @field_counter = 2;
		end if;
		
	elseif (@field_counter = 2) then
		
		set brand_flag = 2; 
		select brandname, feb1 into str_brand, str_forcasted_value from temp where rowid = int_counter;
		
		if(int_counter = int_total_rows)then
			set int_counter = 0;
			set @field_counter = 3;
		end if;
	
	elseif (@field_counter = 3) then
		
		set brand_flag = 3; 
		select brandname, mar1 into str_brand, str_forcasted_value from temp where rowid = int_counter;
		
		if(int_counter = int_total_rows)then
			set int_counter = 0;
			set @field_counter = 4;
		end if;
	
	elseif (@field_counter = 4) then
		
		set brand_flag = 4; 
		select brandname, apr1 into str_brand, str_forcasted_value from temp where rowid = int_counter;
		
	end if;
		
		insert into tmp_brand_forecast_adjustment(brandname,forcasted_value,eyear,eperiod,fyear,fperiod)
		select str_brand, str_forcasted_value, eyear, eperiod, eyear ,brand_flag;
	
	-- select int_counter;
	set int_counter = int_counter +1;
	
end while;

set int_counter2 = 1;
set @field_counters =1;

-- (eyear + 1) 
-- From January to December
while (int_counter2 <= int_total_rows) do 
	
	if (@field_counters = 1) then
	
		set brand_flag = 1; 
		select brandname, jan2 into str_brand, str_forcasted_value from temp where rowid = int_counter2;

		if(int_counter2 = int_total_rows)then
			set int_counter2 = 0;
			set @field_counters = 2;
		end if;
		
	elseif (@field_counters = 2) then
		
		set brand_flag = 2; 
		select brandname, feb2 into str_brand, str_forcasted_value from temp where rowid = int_counter2;
		
	end if;
		
		insert into tmp_brand_forecast_adjustment(brandname,forcasted_value,eyear,eperiod,fyear,fperiod)
		select str_brand, str_forcasted_value, eyear, eperiod, (eyear + 1) ,brand_flag;
	
	-- select int_counter;
	set int_counter2 = int_counter2 +1;
	
end while;


select * from tmp_brand_forecast_adjustment;
select * from temp;
end;

call usp_ci_upload_brand_forecast_adjustment(2018, 4);

*/



drop temporary table if exists temp_val;


	create temporary table temp_val
	(
	ctreeid varchar(100) default '',
	ctreename varchar(100) default '',
	brandid varchar(100) default '',
	brandname varchar(100) default '',
	label varchar(100) default '');



	insert into temp_val	
		select a.cTreeID,
			a.CtreeName,
			e.branchid,
			f.BrandName,
			c.Label
		from ctrees a
		inner join ctreeperiods b
		on a.ctreeid = b.ctreeid
		inner join ctreenodes c
		on b.ctreeperiodid = c.ctreeperiodid
		inner join ctreedefn d 
		on  c.ctreenodeid = d.ctreenodeid
		inner join ctreenodes e
		on d.prevnodeid = e.ctreenodeid
		inner join brands f
		on e.branchid = f.brandid
		where a.CtreeName = '';


		
		

drop temporary table if exists temp_validation;

create temporary table temp_validation
(	rowid int,
	BrandID varchar(100) default '',
 	BrandName varchar(100) default '',
	Forecasted_Value1 varchar(100) default '',
	Forecasted_Value2 varchar(100) default '',
	Forecasted_Value3 varchar(100) default '',
	Forecasted_Value4 varchar(100) default '',
	Forecasted_Value5 varchar(100) default '',
	Forecasted_Value6 varchar(100) default '',
	Forecasted_Value7 varchar(100) default '',
	Forecasted_Value8 varchar(100) default '',
	Forecasted_Value9 varchar(100) default '',
	Forecasted_Value10 varchar(100) default '',
	Forecasted_Value11 varchar(100) default '',
	Forecasted_Value12 varchar(100) default '',
	Ctreeid varchar(100) default '',
	EYEAR  varchar(100) default '',
	int_f_Period varchar(100) default '',
	strForecastTree varchar(100) default '');


insert into temp_validation(
	rowid,
	BrandID,
	BrandName,
	Forecasted_Value1 ,
	Forecasted_Value2 ,
	Forecasted_Value3 ,
	Forecasted_Value4 ,
	Forecasted_Value5 ,
	Forecasted_Value6 ,
	Forecasted_Value7 ,
	Forecasted_Value8 ,
	Forecasted_Value9 ,
	Forecasted_Value10 ,
	Forecasted_Value11 ,
	Forecasted_Value12 ,
	Ctreeid ,
	eyear,
	int_f_Period,
	strForecastTree)
    select  
    DISTINCT(rowid),
	tv.BrandID,
	t.BrandName,
	t.Forecasted_Value1 ,
	t.Forecasted_Value2 ,
	t.Forecasted_Value3 ,
	t.Forecasted_Value4 ,
	t.Forecasted_Value5 ,
	t.Forecasted_Value6 ,
	t.Forecasted_Value7 ,
	t.Forecasted_Value8 ,
	t.Forecasted_Value9 ,
	t.Forecasted_Value10 ,
	t.Forecasted_Value11 ,
	t.Forecasted_Value12 ,
	tv.ctreeId ,
	t.eyear,
	t.f_period,
	t.strTreeName
    from temp t
    left join temp_val tv 
    	on tv.BrandName = t.BrandName
    	or tv.Label = t.BrandName;




update  temp_validation
set     BrandName = REPLACE(BrandName, '"', '');



/*
drop temporary table if exists tmpReturn
*/
																		
create temporary table tmpReturn (ireturn1 int default 0,
	ireturn2 int default 0,
	ireturn3 int default 0,
	ireturn4 int default 0,
	ireturn5 int default 0,
	ireturn6 int default 0,
	ireturn7 int default 0,
	ireturn8 int default 0,
	ireturn9 int default 0,
	rowid int,
	BrandID varchar(100) default '',
 	BrandName varchar(100) default '',
	Forecasted_Value1 varchar(100) default '',
	Forecasted_Value2 varchar(100) default '',
	Forecasted_Value3 varchar(100) default '',
	Forecasted_Value4 varchar(100) default '',
	Forecasted_Value5 varchar(100) default '',
	Forecasted_Value6 varchar(100) default '',
	Forecasted_Value7 varchar(100) default '',
	Forecasted_Value8 varchar(100) default '',
	Forecasted_Value9 varchar(100) default '',
	Forecasted_Value10 varchar(100) default '',
	Forecasted_Value11 varchar(100) default '',
	Forecasted_Value12 varchar(100) default '',
	Ctreeid varchar(100) default '',
	EYEAR  varchar(100) default '',
	int_f_Period varchar(100) default '',
	strForecastTree varchar(100) default '');




if exists(select 1 from	temp where BrandName like '%,%' 
	and Forecasted_Value1 like '%,%'
	and Forecasted_Value2 like '%,%'
	and Forecasted_Value3 like '%,%'
	and Forecasted_Value4 like '%,%'
	and Forecasted_Value5 like '%,%'
	and Forecasted_Value6 like '%,%'
	and Forecasted_Value7 like '%,%'
	and Forecasted_Value8 like '%,%'
	and Forecasted_Value9 like '%,%'
	and Forecasted_Value10 like '%,%'
	and Forecasted_Value11 like '%,%'
	and Forecasted_Value12 like '%,%') then
    
    
    insert into tmpReturn (ireturn2)
    values (-2);



end if;





if exists(select * from temp_validation where BrandName = '') then     
    
    insert into tmpReturn(ireturn3, rowid)
    select distinct -3, rowid from temp_validation where BrandName = '';



end if;



/*

if exists(select * from temp_validation where BrandID is NULL and brandname <> '' and  brandname is not null) then     
    
    insert into tmpReturn(ireturn4,BrandName, rowid)
    select distinct -4, BrandName, rowid from temp_validation where BrandID is NULL and brandname <> '' and  brandname is not null;

end if;

*/

select  count(1)
into    recordcount
from    temp_validation
where   BrandName IS NOT NULL;





select  count(distinct BrandName)
into    uniquerecordcount
from    temp_validation
where   BrandName IS NOT NULL;





if recordcount <> uniquerecordcount then      
    insert into tmpReturn(ireturn5, BrandName, Brandid, rowid)
    
	select 
    distinct -5, 
        BrandName, brandid,  rowid
    from    temp_validation
    where   brandid is not null
    group by   brandid
    having  count(1) > 1;


	
end if;






if exists(select * from temp_validation 
where ctreeid is null and brandname <> '' and  brandname is not null) 

then

	insert into tmpReturn(ireturn6,BrandName, rowid)
    select distinct -6, BrandName, rowid from temp_validation 
	where ctreeid is null and brandname <> '' and  brandname is not null;





end if;






select  count(1)
into    recordcount
from    temp_validation
where   BrandID IS NOT NULL;




select  count(distinct BrandID)
into    uniquerecordcount
from    temp_validation
where   BrandID IS NOT NULL;





select  count(1)
into    recordcount2
from    temp_validation;





if recordcount2 = 0 then
	insert into tmpReturn(ireturn7,BrandName, rowid)
	select -7, 
        '',
        '';



end if;



/*
if recordcount <> uniquerecordcount then      
    insert into tmpReturn(ireturn8, BrandName, rowid)
    
	select 
    distinct -8, 
        BrandName, rowid
    from    temp_validation
    where   BrandID is not null
    group by   BrandID
    having  count(1) > 1;
	
end if;

*/



if not exists (select * from tmpReturn) then

	if exists(select * from brandforecast where eyear = ieyear and eperiod = iePeriod) then     
    
    insert into tmpReturn(ireturn9)
    values (-9);



	else
	insert into tmpReturn (ireturn1)
    values (1);



	
	end if;




end if;


    
    
if exists (select * from tmpReturn) then

				delete
				from temp_validation 
				where brandid IN (select brandid from tmpReturn
								where ireturn5 = -5);


	
    			delete a
			    from temp_validation a
			    right join tmpReturn b
			    on a.rowid = b.rowid;



    
end if;





		delete from tbl_brandforecast_list ;


	
	    insert 
	    into   tbl_brandforecast_list
	   (
	    BrandID ,
		BrandName ,
		Forecasted_Value1 ,
		Forecasted_Value2 ,
		Forecasted_Value3 ,
		Forecasted_Value4 ,
		Forecasted_Value5 ,
		Forecasted_Value6 ,
		Forecasted_Value7 ,
		Forecasted_Value8 ,
		Forecasted_Value9 ,
		Forecasted_Value10 ,
		Forecasted_Value11 ,
		Forecasted_Value12 ,
		eyear ,
		ctreeid,
		ePeriod
		)
	    
	    select
	    tv.BrandID ,
		b.BrandName ,
		tv.Forecasted_Value1 ,
		tv.Forecasted_Value2 ,
		tv.Forecasted_Value3 ,
		tv.Forecasted_Value4 ,
		tv.Forecasted_Value5 ,
		tv.Forecasted_Value6 ,
		tv.Forecasted_Value7 ,
		tv.Forecasted_Value8 ,
		tv.Forecasted_Value9 ,
		tv.Forecasted_Value10 ,
		tv.Forecasted_Value11 ,
		tv.Forecasted_Value12 ,
		tv.eyear ,
		tv.ctreeid,
		tv.int_f_Period
	    from temp_validation tv
	    left join brands b
	    on tv.BrandID = b.BrandID
	    WHERE tv.BrandID IS NOT NULL and tv.ctreeID IS NOT NULL;



	    



	delete from brandforecast_tmp ;




    insert 
    into   brandforecast_tmp
    select ireturn1,
    ireturn2,
    ireturn3,
    ireturn4,
    ireturn5,
    ireturn6,
    ireturn7,
    ireturn8,
    ireturn9,
    rowid,
	BrandID,
	BrandName
	from tmpReturn;



	
END;