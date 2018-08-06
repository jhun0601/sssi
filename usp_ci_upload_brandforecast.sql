DROP PROCEDURE `usp_ci_upload_brandforecast`

GO

CREATE  PROCEDURE `usp_ci_upload_brandforecast`(
    strPathFileName varchar(500),
    ieyear int,
    iePeriod int,
    str_cTreeName varchar(300)
)
BEGIN


declare recordcount integer;


declare uniquerecordcount integer;


declare recordcount2 integer;


declare uniquerecordcount2 integer;


if iePeriod = 1
then
	set iePeriod = 12 ;


	set ieyear = ieyear - 1;


else
	set iePeriod = iePeriod - 1;


end if;



create temporary table temp
	(
		rowid int AUTO_INCREMENT NOT NULL,
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
		EYEAR  varchar(100) default '',
		f_Period int,
    	strTreeName varchar(300),
		PRIMARY KEY (`rowid`)
	);


insert into temp (
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
			eyear,
			f_Period,
			strTreeName
	)
select 
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
	ieyear,
	iePeriod,
   str_cTreeName
from tbl_brandforecast_temp;


delete
from    temp
where   BrandName = 'LOCAL STRUCTURE';




	create temporary table temp_val
	(
	ctreeid varchar(100) default '',
	ctreecode varchar(100) default '',
	ctreeperiodid varchar(100) default '',
	typeid varchar(100) default '',
	istopmost varchar(100) default '',
	prevnodeid varchar(100) default '',
	label varchar(100) default '',
	brandname varchar(100) default '');




	insert into temp_val
	select 
	e.ctreeid,
	e.ctreecode,
	b.ctreeperiodid ,
	b.typeid, 
	b.istopmost, 
	d.prevnodeid, 
	b.label, 
	a.brandname 
	from  temp a
	inner join ctreenodes b
	on a.brandname = b.label
	inner join ctreeperiods c
	on b.ctreeperiodid = c.ctreeperiodid
	inner join ctreedefn d
	on b.ctreenodeid = d.ctreenodeid
	and c.ctreeperiodid = d.ctreeperiodid 
	inner join ctrees e
	on c.ctreeid = e.ctreeid
	and e.ctreecode = str_cTreeName
	where a.brandname <> "" or a.brandname is not null;


	create temporary table temp_val_2
	(
	ctreeid varchar(100) default '',
	ctreecode varchar(100) default '',
	ctreenodeid varchar(100) default '',
	ctreeperiodid varchar(100) default '',
	typeid varchar(100) default '',
	istopmost varchar(100) default '',
	prevnodeid varchar(100) default '',
	brandid varchar(100) default '',
	brandname varchar(100) default '');


	insert into temp_val_2
	select a.ctreeid, 
	a.ctreecode,
	c.ctreenodeid,
	b.ctreeperiodid,
	c.typeid, 
	c.istopmost, 
	d.prevnodeid,  
	f.brandid, 
	f.brandname
	from ctrees a
	inner join ctreeperiods b
	on a.ctreeid = b.ctreeid
	inner join ctreenodes c  
	on b.ctreeperiodid = c.ctreeperiodid
	inner join ctreedefn d
	on b.ctreeperiodid = d.ctreeperiodid 
	and c.ctreenodeid = d.ctreenodeid 
	inner join ctreebranchtypes e  
	on c.typeid = e.ctreebranchtypeid
	inner join brands f  
	on c.branchid = f.brandid
	where a.ctreecode = str_cTreeName
	and  e.ctreebranchtypename = 'brands';


	ALTER TABLE temp_val
	ADD BrandID int;


	update temp_val a
	inner join temp_val_2 b
	on a.prevnodeid = b.ctreenodeid
	and a.ctreeid = b.ctreeid
	and a.ctreeperiodid = b.ctreeperiodid
	set a.Brandid = b.Brandid;


	ALTER TABLE temp
	ADD CtreeID int;


	ALTER TABLE temp
	ADD BrandID int;


	update temp a
	inner join temp_val b
	on a.BrandName = b.BrandName
	set a.Brandid = b.Brandid;


	update temp a
	inner join temp_val b
	on a.BrandName = b.BrandName
	set a.Ctreeid = b.ctreeid;



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
    t.rowid,
	t.BrandID,
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
	t.ctreeId ,
	t.eyear,
	t.f_period,
	t.strTreeName
    from temp t;


update  temp_validation
set     BrandName = REPLACE(BrandName, '"', '');


update  temp_validation
set     BrandName = REPLACE(BrandName, ',', '');


update  temp_validation
set     Forecasted_Value1 = REPLACE(Forecasted_Value1, ',', '');


update  temp_validation
set     Forecasted_Value2 = REPLACE(Forecasted_Value2, ',', '');


update  temp_validation
set     Forecasted_Value3 = REPLACE(Forecasted_Value3, ',', '');


update  temp_validation
set     Forecasted_Value4 = REPLACE(Forecasted_Value4, ',', '');


update  temp_validation
set     Forecasted_Value5 = REPLACE(Forecasted_Value5, ',', '');


update  temp_validation
set     Forecasted_Value6 = REPLACE(Forecasted_Value6, ',', '');


update  temp_validation
set     Forecasted_Value7 = REPLACE(Forecasted_Value7, ',', '');


update  temp_validation
set     Forecasted_Value8 = REPLACE(Forecasted_Value8, ',', '');


update  temp_validation
set     Forecasted_Value9 = REPLACE(Forecasted_Value9, ',', '');


update  temp_validation
set     Forecasted_Value10 = REPLACE(Forecasted_Value10, ',', '');


update  temp_validation
set     Forecasted_Value11 = REPLACE(Forecasted_Value11, ',', '');


update  temp_validation
set     Forecasted_Value12 = REPLACE(Forecasted_Value12, ',', '');


																		
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
		tv.BrandName ,
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


END