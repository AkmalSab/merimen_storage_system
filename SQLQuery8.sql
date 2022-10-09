/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [claims_dev].[dbo].[FDOC_PHOTO_ANNOTATE]

  SELECT TOP (1000) * from trx0008 where iCASEID = 33673
  SELECT TOP (1000) * from trx0001 where iCASEID = 33673
  SELECT TOP (1000) * from trx0070;
  SELECT TOP (1000) * from POL4001;
  SELECT TOP (1000) * from POLB4002;

  certain claim icaseid -> (objid) tender iobjid

  SELECT TOP (1000) * from trx0035


  SELECT TOP (1000) * from fobj3010 where IOBJID = 33673 --audit
  SELECT TOP (1000) * from fobj3010 where IDOMAINID = 1 --audit
  SELECT TOP (1000) * from fobj3001 ORDER BY iDOMAINID asc; --list of domain
  SELECT TOP (1000) * from fobj3003; --list of domain-corole
  SELECT TOP (1000) * from fdoc3001;
  SELECT TOP (1000) * from SEC0001; --list of user
 SELECT TOP (1000) * from SEC0005 where iCOID = 1; --list of user
  SELECT TOP (1000) * from fdoc3003
  SELECT TOP (1000) * from [STRGY_TYPE];
  SELECT TOP (1000) * from [STRG_DATA];

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