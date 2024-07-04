show databases;
						-- creating database
create schema RegressionDataset;
use RegressionDataset;
						-- creating table
CREATE TABLE laptopPricePrediction (Company varchar(255),TypeName varchar(255),
Inches float,ScreenResolution varchar(255),CPU varchar(255),Ram varchar(255),Memory varchar(255),
Gpu varchar(255),OpySys varchar(255),Weight varchar(255),Price decimal(18,4));
Select * from laptopPricePrediction; 
Select (CASE WHEN locate("IPS",screenresolution)>0 THEN 1 ELSE 0 END) from laptopPricePrediction;
Select (CASE WHEN locate("Touchscreen",screenresolution)>0 THEN 1 ELSE 0 END) from laptopPricePrediction;
SELECT REGEXP_SUBSTR(substr(screenresolution,1,locate("x",screenresolution)-1),'[0-9]+') from laptopPricePrediction;
SELECT substr(screenresolution,locate("x",screenresolution)+1,length(screenresolution)) from laptopPricePrediction;
SELECT 
CASE
    WHEN (CPU like 'Intel Core i7%' or CPU like'Intel Core i5%' or CPU like'Intel Core i3%') THEN substring(CPU,1,13)
    WHEN locate("Intel",CPU)>0 THEN 'Other Intel Processor'
    ELSE 'AMD Processor'
END,CPU
FROM laptopPricePrediction;
SELECT REPLACE(Ram,"GB","") from laptopPricePrediction;
Select substr(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"),locate("+",replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"))+1,length(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000")))
,Memory from  laptopPricePrediction ;
Select substr(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"),1,locate("+",replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"))-1)
,Memory from  laptopPricePrediction ;

select * FROM laptopPricePrediction WHERE GPU like 'Arm%';
SET SQL_SAFE_UPDATES = 0;
Delete from laptopPricePrediction where gpu like 'Arm%';
SET SQL_SAFE_UPDATES = 1;
SELECT substr(gpu,1,locate(" ",gpu)-1)  from laptopPricePrediction;

SELECT 
CASE
    WHEN OpySys='Windows 10' or OpySys='Windows 7' or OpySys='Windows 10 S'
        then 'Windows'
    WHEN OpySys='macOS' or OpySys='Mac OS X'
        then 'Mac'
    else
        'Others/No OS/Linux'
END,OpySys
FROM laptopPricePrediction;
SELECT REPLACE(Weight,"kg","") from laptopPricePrediction;

					-- new table creation

CREATE TABLE finalLaptopPrediction (Company varchar(255),TypeName varchar(255),
Inches float,ScreenWidth int, ScreenHeight int,Touchscreen int,IPS int,CPU varchar(255),Ram varchar(255),Memory varchar(255),Memory1 varchar(255),
Gpu varchar(255),OpySys varchar(255),Weight varchar(255),Price decimal(18,4),
HDD int,SDD int,FlashStorage int,Hybrid int,HDD1 int,SDD1 int,FlashStorage1 int,Hybrid1 int
);
					-- insert data into new table

insert into finalLaptopPrediction 
select Company,TypeName,Inches,REGEXP_SUBSTR(substr(screenresolution,1,locate("x",screenresolution)-1),'[0-9]+') ScreenWidth
,substr(screenresolution,locate("x",screenresolution)+1,length(screenresolution)) ScreenHeight
,(CASE WHEN locate("Touchscreen",screenresolution)>0 THEN 1 ELSE 0 END) Touchscreen
,(CASE WHEN locate("IPS",screenresolution)>0 THEN 1 ELSE 0 END)  IPS
,CASE
    WHEN (CPU like 'Intel Core i7%' or CPU like'Intel Core i5%' or CPU like'Intel Core i3%') THEN substring(CPU,1,13)
    WHEN locate("Intel",CPU)>0 THEN 'Other Intel Processor'
    ELSE 'AMD Processor'
END CPU
,REPLACE(Ram,"GB","") Ram
,substr(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"),locate("+",replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"))+1,length(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"))) Memory
,substr(replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"),1,locate("+",replace(replace(replace(Memory,".0",""),"GB",""),"TB","000"))-1) Memory1
,substr(gpu,1,locate(" ",gpu)-1) gpu
,CASE
    WHEN OpySys='Windows 10' or OpySys='Windows 7' or OpySys='Windows 10 S'
        then 'Windows'
    WHEN OpySys='macOS' or OpySys='Mac OS X'
        then 'Mac'
    else
        'Others/No OS/Linux'
END OpySys
,REPLACE(Weight,"kg","") weight
,Price 
,0,0,0,0,0,0,0,0 From laptopPricePrediction;
Select * from finalLaptopPrediction;

					-- updating new table

ALTER TABLE finalLaptopPrediction ADD COLUMN PPI DECIMAL(7, 4);
UPDATE finalLaptopPrediction
SET PPI = SQRT(POW(ScreenWidth, 2) + POW(ScreenHeight, 2)) / Inches;
ALTER TABLE finalLaptopPrediction drop ScreenWidth;
ALTER TABLE finalLaptopPrediction drop ScreenHeight;
ALTER TABLE finalLaptopPrediction drop Inches;


UPDATE finalLaptopPrediction
SET SDD=1 where locate("SSD",Memory)>0;
UPDATE finalLaptopPrediction
SET HDD=1 where locate("HDD",Memory)>0;
UPDATE finalLaptopPrediction
SET FlashStorage=1 where locate("Flash Storage",Memory)>0;
UPDATE finalLaptopPrediction
SET Hybrid=1 where locate("Hybrid",Memory)>0;
Select * from finalLaptopPrediction;

UPDATE finalLaptopPrediction
SET SDD1=1 where locate("SSD",Memory1)>0;
UPDATE finalLaptopPrediction
SET HDD1=1 where locate("HDD",Memory1)>0;
UPDATE finalLaptopPrediction
SET FlashStorage1=1 where locate("Flash Storage",Memory1)>0;
Select * from finalLaptopPrediction;

-- df["HDD"]=(df["first"]*df["Layer1HDD"]+df["second"]*df["Layer2HDD"]);

SELECT REGEXP_SUBSTR(Memory,'[0-9]+') from finalLaptopPrediction;
SELECT  REGEXP_SUBSTR(Memory1,'[0-9]+') from finalLaptopPrediction;
-- select * from finalLaptopPrediction where Memory1 like '%Flash Storage';
select  * from finalLaptopPrediction;

ALTER TABLE finalLaptopPrediction ADD COLUMN HDDStorage int;
ALTER TABLE finalLaptopPrediction ADD COLUMN SSDStorage int;
ALTER TABLE finalLaptopPrediction ADD COLUMN FlashMemory int;
ALTER TABLE finalLaptopPrediction ADD COLUMN HybridStorage int;

update finalLaptopPrediction set HDDStorage = 0 ;
update finalLaptopPrediction set SSDStorage = 0 ;
update finalLaptopPrediction set FlashMemory = 0 ;
update finalLaptopPrediction set HybridStorage = 0 ;

update finalLaptopPrediction set HDDStorage = (REGEXP_SUBSTR(Memory,'[0-9]+')*HDD)+(REGEXP_SUBSTR(isnull(Memory1),'[0-9]+')*HDD1) ;
update finalLaptopPrediction set SSDStorage = (REGEXP_SUBSTR(Memory,'[0-9]+')*SDD)+(REGEXP_SUBSTR(isnull(Memory1),'[0-9]+')*SDD1) ;
update finalLaptopPrediction set FlashMemory = (REGEXP_SUBSTR(Memory,'[0-9]+')*FlashStorage)+(REGEXP_SUBSTR(isnull(Memory1),'[0-9]+')*FlashStorage1) ;
update finalLaptopPrediction set HybridStorage = (REGEXP_SUBSTR(Memory,'[0-9]+')*Hybrid)+(REGEXP_SUBSTR(isnull(Memory1),'[0-9]+')*Hybrid1) ;

ALTER TABLE finalLaptopPrediction drop HDD;
ALTER TABLE finalLaptopPrediction drop SDD;
ALTER TABLE finalLaptopPrediction drop FlashStorage;
ALTER TABLE finalLaptopPrediction drop Hybrid;
ALTER TABLE finalLaptopPrediction drop HDD1;
ALTER TABLE finalLaptopPrediction drop SDD1;
ALTER TABLE finalLaptopPrediction drop FlashStorage1;
ALTER TABLE finalLaptopPrediction drop Hybrid1;
ALTER TABLE finalLaptopPrediction drop Memory;
ALTER TABLE finalLaptopPrediction drop Memory1;

select *  from finalLaptopPrediction
