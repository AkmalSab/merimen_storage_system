/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [claims_dev].[dbo].[FDOC_PHOTO_ANNOTATE]

  SELECT TOP (1000) * from trx0008 where iCASEID = 33673
  SELECT TOP (1000) * from trx0001 where iCASEID = 792
  sp_help STRG_DATA
  SELECT TOP (1000) * from trx0070;
  SELECT TOP (1000) * from POL4001;
  SELECT TOP (1000) * from POLB4002;

  certain claim icaseid -> (objid) tender iobjid

  SELECT TOP (1000) * from trx0035

  SELECT TOP (1000) * from fobjd3010 ORDER BY ITATYPEID desc;--list of audit types (1000613)
  SELECT TOP (1000) * from fobj3010 where IDOMAINID = 901 --list of all audit records
  SELECT TOP (1000) * from fobj3010 where VATAREMARKS LIKE '%ISAAC123.%' --list of all audit records
  SELECT TOP (1000) * from fobj3001 ORDER BY iDOMAINID desc; --list of domain (901)
  SELECT TOP (1000) * from fobj3003; --list of domain-corole
  SELECT TOP (1000) * from fdoc3003; --framework docs
  SELECT TOP (1000) * from SEC0001; --list of user
  SELECT TOP (1000) * from SEC0003; --list of permission definition
  SELECT TOP (1000) * from SEC0004; --list of permission set to user
  SELECT TOP (1000) * from SEC0005 where iCOID = 1; --list of user
  SELECT TOP (1000) * from fdoc3002; --doc class
  SELECT TOP (1000) * from fdoc3003; --uploaded file table
  SELECT TOP (1000) * from fdoc3004;
  SELECT TOP (1000) * from fdoc3005; --file location
  SELECT TOP (1000) * from fdoc3006; --file folder
  SELECT TOP (1000) * from fdoc3007;
  SELECT TOP (1000) * from fdoc3008;
  SELECT TOP (1000) * from fdoc3009;
  SELECT TOP (1000) * from FDOC3001 --document ID definition
  SELECT TOP (1000) * from FDOC3010 --document access right
  SELECT TOP (1000) * from [STRGY_TYPE];
  SELECT TOP (1000) * from [STRG_DATA] order by iSTRGID asc;
  SELECT TOP (1000) * from SYS0001;

  update [STRG_DATA] set vaSTATUS = 'Active';

  select
  a.vaCREATOR, 
  a.iSTRGTYPEID as storage_type_id,
  (
	select count(iSTRGID)
	from STRG_DATA 
	where vaSTATUS != 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
  ) as Unverified_counters,
  (
	select count(iSTRGID)
	from STRG_DATA a 
	where vaSTATUS = 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
  ) as Verified_counters,
  (
	select count(iSTRGID)
	from STRG_DATA
	where iCLASSIFIED = 1 and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
  ) as Classified_counters,
  (
	select count(iSTRGID)
	from STRG_DATA
	where vaCREATOR = a.vaCREATOR
  ) as Total_counters
  from STRG_DATA a WITH (NOLOCK)
  where 0=0
  group by a.vaCREATOR,  a.iSTRGTYPEID


  delete from STRG_DATA;
  delete from STRGY_TYPE;
  delete from fdoc3006;

  ALTER TABLE [STRG_DATA]
	ALTER COLUMN vaCREATOR INT;

  DBCC CHECKIDENT ('STRGY_TYPE', RESEED, 0);
GO

DBCC CHECKIDENT ('STRG_DATA', RESEED, 0);
GO

DBCC CHECKIDENT ('fdoc3006', RESEED, 0);
GO


  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [vaAPPINST]
      ,[vaAPPVAR]
      ,[vaAPPVALUE]
      ,[iCRTBY]
      ,[dtCRTON]
      ,[siSTATUS]
  FROM [merimen_storage_system].[dbo].[SYS0001] WHERE vaAPPINST = 'SCORPIO';


  UPDATE [merimen_storage_system].[dbo].[SYS0001] SET vaAPPVALUE = '/mrmstrgsys/' WHERE vaAPPVAR = 'LOGPATH' AND vaAPPINST = 'SCORPIO';
	UPDATE [merimen_storage_system].[dbo].[SYS0001] SET vaAPPVALUE = '/' WHERE vaAPPVAR = 'APPPATH' AND vaAPPINST = 'SCORPIO';
		UPDATE [merimen_storage_system].[dbo].[SYS0001] SET vaAPPVALUE = 'merimen_storage_system' WHERE vaAPPVAR = 'MTRAUDDSN' AND vaAPPINST = 'SCORPIO';
		SELECT DB_APP=dbo.fGetDBSettings('APP'),DB_COUNTRY=dbo.fGetDBSettings('COUNTRY'),DB_MODE=dbo.fGetDBSettings('MODE');


-- setup db mode for application.cfm usage
USE [merimen_storage_system]
GO
/****** Object:  UserDefinedFunction [dbo].[fGetDBSettings]    Script Date: 5/10/2022 11:46:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION dbo.fGetDBSettings
(
	@appvar nvarchar(50)
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @ret		nvarchar(max)
	SELECT @ret=vaAPPVALUE FROM SYS0001 WITH (NOLOCK) WHERE vaAPPVAR=@appvar AND vaAPPINST='DB';
	
	RETURN @ret;
END

-- create storage item into domain table
USE [merimen_storage_system]
GO

INSERT INTO [dbo].[FOBJ3001]
           ([iDOMAINID]
           ,[vaDESC]
           ,[vaOBJDBRELATION]
           ,[vaICON]
           ,[vaURL]
           ,[iCRTBY]
           ,[dtCRTON]
           ,[siSTATUS]
           ,[iOBJSECTYPE])
     VALUES
           (
		        901,
           'Storage Item',
           null,
           null,
           null,
           1,
           GETDATE(),
           0,
           1)
GO

-- insert storage type value's (URL,document,letter)
USE [merimen_storage_system]
GO

INSERT INTO [dbo].[STRGY_TYPE]
           ([vaSTRGDESCRIPTION])
     VALUES
           ('URL');
INSERT INTO [dbo].[STRGY_TYPE]
           ([vaSTRGDESCRIPTION])
     VALUES
           ('document');
INSERT INTO [dbo].[STRGY_TYPE]
           ([vaSTRGDESCRIPTION])
     VALUES
           ('letter');
GO

--create table main storage
USE [merimen_storage_system]
GO

/****** Object:  Table [dbo].[STRG_DATA]    Script Date: 6/10/2022 3:37:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[STRG_DATA](
	[iSTRGID] [int] IDENTITY(1,1) NOT NULL,
	[iSTRGTYPEID] [int] NOT NULL,
	[vaITEMNAME] [nvarchar](255) NOT NULL,
	[vaDESCRIPTION] [nvarchar](255) NOT NULL,
	[iDOMAINID] [int] NOT NULL,
	[iOBJID] [int] NOT NULL,
	[iRATING] [int] NOT NULL,
	[iCLASSIFIED] [int] NOT NULL,
	[vaREMARKS] [nvarchar](255) NOT NULL,
	[vaSTATUS] [nvarchar](255) NOT NULL,
	[vaCREATOR] [nvarchar](255) NOT NULL,
	[dtCREATIONDATE] [datetime] NOT NULL,
	[iMODIFIEDBY] [int] NOT NULL,
	[dtMODIFIEDDATE] [datetime] NOT NULL,
	[vaURLADDRESS] [nvarchar](255) NULL,
	[iDOCUMENTID] [int] NULL,
	[vaTEXTFIELD] [nvarchar](255) NULL,
 CONSTRAINT [PK_STRG_DATA] PRIMARY KEY CLUSTERED 
(
	[iSTRGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[STRG_DATA]  WITH CHECK ADD  CONSTRAINT [FK_STRG_DATA] FOREIGN KEY([iSTRGTYPEID])
REFERENCES [dbo].[STRGY_TYPE] ([iSTRGTYPEID])
GO

ALTER TABLE [dbo].[STRG_DATA] CHECK CONSTRAINT [FK_STRG_DATA]
GO

-- insert main storage values
USE [merimen_storage_system]
GO

INSERT INTO [dbo].[STRG_DATA]
           ([iSTRGTYPEID]
           ,[vaITEMNAME]
           ,[vaDESCRIPTION]
           ,[iDOMAINID]
           ,[iOBJID]
           ,[iRATING]
           ,[iCLASSIFIED]
           ,[vaREMARKS]
           ,[vaSTATUS]
           ,[vaCREATOR]
           ,[dtCREATIONDATE]
           ,[iMODIFIEDBY]
           ,[dtMODIFIEDDATE]
           ,[vaURLADDRESS]
           ,[iDOCUMENTID]
           ,[vaTEXTFIELD])
     VALUES
           (3,
           'homepage url for project',
           'first test',
           33,
           11,
           1,
           0,
           'first insert',
           'Active',
           'Akmal',
           GETDATE(),
           1,
           GETDATE(),
           'http://localhost/mrmstrgsys/index.cfm?fusebox=MTRroot&fuseaction=dsp_home&CFID=6058&CFTOKEN=29ea006306a009f-B5BC670C-ECF5-2E69-CEB1E5087048A3F8&USID=1&RID=8548932&wel=1',
           null,
           null)
GO

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

USE [merimen_storage_system]
GO

/****** Object:  Table [dbo].[FDOC3006]    Script Date: 14/10/2022 4:19:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FDOC3006](
	[IFILEID] [int] IDENTITY(1,1) NOT NULL,
	[VAFILEPATH] [nvarchar](255) NULL,
	[VAFILENAME] [nvarchar](150) NOT NULL,
	[VAFILEORIGNAME] [nvarchar](255) NULL,
	[VAFILEEXT] [varchar](30) NULL,
	[IFILESIZE] [int] NULL,
	[ICRTBY] [int] NOT NULL,
	[DTCRTON] [datetime] NOT NULL,
	[SISTATUS] [smallint] NOT NULL,
 CONSTRAINT [PK_FDOC3006] PRIMARY KEY CLUSTERED 
(
	[IFILEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FDOC3006] ADD  CONSTRAINT [DF_FDOC3006__ICRTBY__750FDE1D]  DEFAULT (1) FOR [ICRTBY]
GO

ALTER TABLE [dbo].[FDOC3006] ADD  CONSTRAINT [DF_FDOC3006__DTCRTON__76040256]  DEFAULT (getdate()) FOR [DTCRTON]
GO

ALTER TABLE [dbo].[FDOC3006] ADD  CONSTRAINT [DF_FDOC3006__SISTATU__76F8268F]  DEFAULT (0) FOR [SISTATUS]
GO

/****** Object:  StoredProcedure Script Date: 20/10/2022 3:40:56 PM ******/
USE [merimen_storage_system]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE sspSTRGDataInsertUpdate
@ai_strgid int = 0,
@ai_strgtypeid int,
@as_itemname nvarchar(255),
@as_description nvarchar(255),
@ai_domainid int = 33,
@ai_objid int = 0,
@ai_rating int,
@ai_classfied int = 0,
@as_remarks nvarchar(255),
@as_status nvarchar(255) = "Active",
@ai_creator int,
@adt_creationdate datetime,
@ai_modifiedby int = 1,
@adt_modifieddate datetime,
@as_urladdress nvarchar(255),
@ai_documentid int,
@as_textfield nvarchar(255),
@li_id int output
AS
BEGIN
SET NOCOUNT ON --To hide the number of rows affected messages, (improve performance)

IF (@ai_strgid = 0)
BEGIN
	insert into STRG_DATA 
    (
        iSTRGTYPEID,
        vaITEMNAME,
        vaDESCRIPTION, 
        iDOMAINID,
        iOBJID,
        iRATING,
        iCLASSIFIED,
        vaREMARKS,
        vaSTATUS,
        vaCREATOR,
        dtCREATIONDATE,
        iMODIFIEDBY,
        dtMODIFIEDDATE,
        vaURLADDRESS,
        iDOCUMENTID,
        vaTEXTFIELD
    )
    values 
    (
      @ai_strgtypeid,
      @as_itemname,
      @as_description,
      @ai_domainid,
	  @ai_objid,
      @ai_rating,
      @ai_classfied,
      @as_remarks,
      @as_status,
      @ai_creator,
      @adt_creationdate,
      @ai_modifiedby,
      @adt_modifieddate,
      @as_urladdress,
      @ai_documentid,
      @as_textfield
    );

	--get latest insert id
	SELECT @li_id = iSTRGID 
	FROM STRG_DATA 
	WHERE iSTRGID = @@Identity;
END

IF (@ai_strgid != 0)
BEGIN

	SET @li_id = @ai_strgid;

	update STRG_DATA set
    iSTRGTYPEID = @ai_strgtypeid,
    vaITEMNAME = @as_itemname,
    vaDESCRIPTION = @as_description,
	iOBJID = @ai_objid,
    iRATING = @ai_rating,
    vaREMARKS = @as_remarks,
	iMODIFIEDBY = @ai_modifiedby,
    dtMODIFIEDDATE = @ai_modifiedby,
    vaURLADDRESS = @as_urladdress,
    iDOCUMENTID = @ai_documentid,
    vaTEXTFIELD = @as_textfield
	where iSTRGID = @ai_strgid
END

END