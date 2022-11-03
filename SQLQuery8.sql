/****** Script for SelectTopNRows command from SSMS  ******/
  SELECT TOP (1000) * FROM [claims_dev].[dbo].[FDOC_PHOTO_ANNOTATE]
  SELECT TOP (1000) * from trx0008 where iCASEID = 33673
  SELECT TOP (1000) * from trx0001 where iCASEID = 792
  SELECT TOP (1000) * from trx0070;
  SELECT TOP (1000) * from POL4001;
  SELECT TOP (1000) * from POLB4002;
  --certain claim icaseid -> (objid) tender iobjid
  SELECT TOP (1000) * from trx0035
  SELECT TOP (1000) * from fFOBJCoSecTable;
  SELECT TOP (1000) * from fobjd3010 ORDER BY ITATYPEID desc;--list of audit types (1000613)
  SELECT TOP (1000) * from fobj3010 order by DTCRTON desc --list of all audit records
  SELECT TOP (1000) * from fobj3010 where VATAREMARKS LIKE '%ISAAC123.%' --list of all audit records
  SELECT TOP (1000) * from fobj3001 ORDER BY iDOMAINID ASC; --list of domain (901)
  SELECT TOP (1000) * from fobj3003; --list of domain-corole
  SELECT TOP (1000) * from fdoc3003; --framework docs
  SELECT TOP (1000) * from SEC0001; --list of user
  SELECT TOP (1000) * from SEC0003 where sipgroup >= 7000; --list of permission definition
  SELECT TOP (1000) * from SEC0004 where sipgroup >= 7000 ORDER BY SIPGROUP ASC; -- list of permission set to user
  SELECT TOP (1000) * from SEC0005 order by iCOID asc; --list of companies
  SELECT TOP (1000) * from fsec4001 order by iGRPID DESC; -- list of group definition > 6461
  SELECT TOP (1000) * from fsec4002 order by iGRPID DESC; -- list of group set to user
  SELECT TOP (1000) * from FSEC4004 order by iGRPID DESC; -- list of permission bind to which group
  SELECT TOP (1000) * from SEC0023; --list of category for permission group
  SELECT TOP (1000) * from SEC0003_CO;
  SELECT TOP (1000) * from fCSI('7000,7004');
  SELECT * from FOBJ3020 WHERE IDOMAINID = 1; 
  SELECT * from FOBJB3022;
  SELECT TOP (1000) * from FOBJB3020 where iLBLDEFID = 1111 --list of label definition;
  SELECT TOP (1000) * from FOBJB3022 where iLBLDEFID = 1111 order by iGCOID asc --list of Label-Company Linkage;
  select icoid,ilocid,igcoid,vaconame from sec0005 where icoid = 0
  select igcoid 
        from FOBJB3022 
        where 
            iLBLDEFID = 9999
            and iGCOID = 1

  SP_HELP FOBJB3022

SELECT b.siPGROUP
FROM fsec4002 a 
JOIN FSEC4004 b WITH (NOLOCK) ON a.iGRPID = b.iGRPID
WHERE a.iUSID = 1

SELECT TOP 1000 * FROM FSEC4004 ORDER BY siPGROUP ASC


select a.igrpid,a.icoid,a.vagrpname,a.vagrpdesc,a.dtcrton 
from fsec4001 a WITH (NOLOCK) 
where a.icoid = 35
and a.sistatus=0  
order by a.vagrpname

  sp_help fsec4001

  select iusid from sec0001 where vausid IN ('MMDANNY');

  select a.igrpid,a.icoid,a.vagrpname,a.vagrpdesc,a.dtcrton 
  from fsec4001 a WITH (NOLOCK) 
  where a.icoid = 35 and a.sistatus=0 order by a.vagrpname

  select a.itskgrpid,a.vatskgrpname 
  from ftsk1001 a WITH (NOLOCK) 
  where a.icoid = 35 and a.sistatus=0 order by a.itskgrpid

  sp_help SEC0005

  SELECT TOP (1000) * from fdoc3001;
  SELECT TOP (1000) * from fdoc3002; --doc class
  SELECT TOP (1000) * from fdoc3003; --uploaded file table
  SELECT TOP (1000) * from fdoc3004;
  SELECT TOP (1000) * from fdoc3005; --file location
  SELECT TOP (1000) * from fdoc3006; --file folder
  SELECT TOP (1000) * from fdoc3007;
  SELECT TOP (1000) * from fdoc3008;
  SELECT TOP (1000) * from fdoc3009;
  SELECT TOP (1000) * from fdoc3010;
  SELECT TOP (1000) * from FDOC3001 --document ID definition
  SELECT TOP (1000) * from FDOC3010 --document access right
  SELECT TOP (1000) * from [STRGY_TYPE];
  SELECT TOP (1000) * from [STRG_DATA] order by iSTRGID asc;
  SELECT TOP (1000) * from SYS0001;
  SELECT TOP (1000) * from SYS0009;


SELECT TOP 1 COTYPE=1,iUSID,vaUSID,iCOID 
FROM SEC0001 WITH (NOLOCK) 
WHERE vaUSID = 'mmadminn' 
AND iCOID=1 
AND siSTATUS=0
UNION
SELECT TOP 1 COTYPE=2,iUSID,vaUSID,iCOID 
FROM SEC0001 WITH (NOLOCK) 
WHERE iUSID=0
AND siSTATUS=0
ORDER BY COTYPE ASC

SELECT * FROM [FOBJ3010] WITH (NOLOCK)
WHERE IDOMAINID = 901
ORDER BY ITAID DESC

select distinct iUSID, vaUSName
from SEC0001 a join STRG_DATA b
on a.iUSID = b.vaCREATOR;

SELECT *
FROM SEC0003 a JOIN SEC0004 b WITH (NOLOCK)
ON a.siPGROUP = b.siPGROUP
WHERE b.iUSID = 1 and b.siPGROUP >= 7000

SELECT *
FROM STRG_DATA a LEFT JOIN FDOC3006 b WITH (NOLOCK)
ON a.iOBJID = b.IFILEID
ORDER BY iSTRGID;

SELECT a.iPERMGRPID, c.vaPERMGRPNAME,a.siPGROUP,a.siPREQUIRED,a.vaDESC, 
CHK=CASE WHEN b.siPGROUP IS NULL THEN 0 ELSE 1 END, 
PRIVATE_PERM=CASE WHEN EXISTS(SELECT 1 FROM SEC0003_CO d WITH (NOLOCK) WHERE d.siPGROUP=a.siPGROUP) THEN 1 ELSE 0 END, 
PRIVATE_GCOID=d.iGCOID 
FROM SEC0003 a WITH (NOLOCK) 
LEFT JOIN FSEC4004 b WITH (NOLOCK) ON a.siPGROUP=b.siPGROUP AND b.iGRPID=6468 AND b.siSTATUS=0 
LEFT JOIN SEC0023 c WITH (NOLOCK) ON a.iPERMGRPID=c.iPERMGRPID 
LEFT JOIN SEC0003_CO d WITH (NOLOCK) ON d.siPGROUP=a.siPGROUP AND d.iGCOID=1 
WHERE a.siSTATUS=0
order by a.iPERMGRPID desc

select 1 AND 8 > 0

SP_HELP SEC0003
SELECT TOP 1000 * FROM SEC0003 WHERE siPGROUP >= 7000;
SELECT TOP 1000 * FROM FSEC4004 where siPGROUP >= 7000;
SELECT TOP 1000 * FROM SEC0023;
SELECT TOP 1000 * FROM SEC0003_CO;

select *
from STRG_DATA a JOIN SEC0001 b WITH (NOLOCK)
on a.vaCREATOR = b.iUSID
select * from STRG_DATA

select a.vaCREATOR, b.vaUSName, a.iSTRGTYPEID as storage_type_id, 
( select count(iSTRGID) from STRG_DATA where vaSTATUS != 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR ) as Unverified_counters, 
( select count(iSTRGID) from STRG_DATA a where vaSTATUS = 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR ) as Verified_counters, 
( select count(iSTRGID) from STRG_DATA where iCLASSIFIED = 1 and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR ) as Classified_counters, 
( select count(iSTRGID) from STRG_DATA where vaCREATOR = a.vaCREATOR ) as Total_counters 
from STRG_DATA a JOIN SEC0001 b WITH (NOLOCK) 
on a.vaCREATOR = b.iUSID 
where 0=0 and a.dtCREATIONDATE >= '2022-01-11 00:00:00' AND a.dtCREATIONDATE <= '2022-02-11 23:59:59' 
group by a.vaCREATOR, b.vaUSName, a.iSTRGTYPEID order by a.vaCREATOR