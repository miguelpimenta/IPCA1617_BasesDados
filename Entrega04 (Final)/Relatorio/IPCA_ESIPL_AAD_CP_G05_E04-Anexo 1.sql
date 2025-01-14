USE [master]
GO
/****** Object:  Database [Barcacellos]    Script Date: 29/05/2017 17:23:32 ******/
CREATE DATABASE [Barcacellos]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Barcacellos', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER\MSSQL\DATA\Barcacellos.mdf' , SIZE = 10240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'Barcacellos_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER\MSSQL\DATA\Barcacellos_log.ldf' , SIZE = 10240KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Barcacellos] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Barcacellos].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Barcacellos] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Barcacellos] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Barcacellos] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Barcacellos] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Barcacellos] SET ARITHABORT OFF 
GO
ALTER DATABASE [Barcacellos] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Barcacellos] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Barcacellos] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Barcacellos] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Barcacellos] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Barcacellos] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Barcacellos] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Barcacellos] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Barcacellos] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Barcacellos] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Barcacellos] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Barcacellos] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Barcacellos] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Barcacellos] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Barcacellos] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Barcacellos] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Barcacellos] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Barcacellos] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Barcacellos] SET  MULTI_USER 
GO
ALTER DATABASE [Barcacellos] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Barcacellos] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Barcacellos] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Barcacellos] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Barcacellos] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Barcacellos] SET QUERY_STORE = OFF
GO
USE [Barcacellos]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Barcacellos]
GO
/****** Object:  UserDefinedFunction [dbo].[CalcularAnos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <2017-05-24>
-- Description:	<...>
-- =============================================
CREATE FUNCTION [dbo].[CalcularAnos]
(
	@Data AS DATETIME
)
RETURNS INT

AS
BEGIN
	
	DECLARE @Anos INT;

	SET @Anos = ((CAST(CONVERT(VARCHAR(8),GETDATE(),112) AS INT)-(CAST(CONVERT(VARCHAR(8), @Data,112) AS INT)))/10000)

	RETURN @Anos

END

GO
/****** Object:  UserDefinedFunction [dbo].[TratarNome]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Remover Diacríticos
CREATE FUNCTION [dbo].[TratarNome]
    (
		@Input				VARCHAR(MAX),
		@ToUpper			BIT,
		@ToProperCase		BIT,
		@RemoveDiacritics	BIT
    )
    RETURNS VARCHAR(MAX)
    AS
    BEGIN

        DECLARE @Output VARCHAR(MAX)

		SET @Output = RTRIM(LTRIM(@Input));

		IF (@ToUpper = 1 AND @Output != '')
		BEGIN
			SET @Output = (SELECT UPPER(@Output))			
		END

		IF (@RemoveDiacritics = 1 AND @Output != '')
		BEGIN
			SET @Output = (SELECT @Output Collate SQL_Latin1_General_CP1253_CI_AI)			
		END	

		IF (@ToProperCase = 1 AND @Output != '')
		BEGIN
			DECLARE @Pos1 INT = 1
			DECLARE @Pos2  INT
			SET @Output = LOWER(@Output)
			WHILE (1 = 1)
			BEGIN
				SET @Output = STUFF(@Output, @Pos1, 1, UPPER(SUBSTRING(@Output, @Pos1, 1)))
				SET @Pos2 = PATINDEX('%[- ''.)(]%', SUBSTRING(@Output, @Pos1, 500))
				SET @Pos1 += @Pos2
				IF (ISNULL(@Pos2, 0) = 0 or @Pos1 > LEN(@Output))
				BEGIN
					BREAK
				END
			END
		END

		RETURN @Output

    END

GO
/****** Object:  UserDefinedFunction [dbo].[ValidarNIF]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:           <Author,,Name>
-- Create date:      <Create Date, ,>
-- Description:      <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ValidarNIF]
(      
        @NIF VARCHAR( 50)
)
RETURNS bit

AS
BEGIN
    DECLARE @Output BIT;
    SET @Output = 0 ;

    IF(ISNUMERIC(@NIF) = 0)
    BEGIN
        SET @Output = 0
        RETURN @Output
    END

    --Tem de ter 9 digitos e o digito inicial tem de ser 1,2,5,6,7,8,9
    IF (@NIF < 100000000 OR @NIF > 999999999) OR (@NIF > 299999999 AND @NIF < 500000000)
    BEGIN
        SET @Output = 0
        RETURN @Output
    END

    DECLARE @NIFString VARCHAR(9)
    SET @NIFString = CAST(@NIF AS VARCHAR(9))

    DECLARE @Control INT
    SET @Control = 9 * (cast(SUBSTRING(@NIFString , 1, 1) AS INT)) + 8*(cast(SUBSTRING(@NIFString , 2, 1) AS INT )) +
    7 *(cast(SUBSTRING(@NIFString , 3, 1) AS INT )) + 6*(CAST(SUBSTRING(@NIFString , 4, 1) AS INT )) +
    5 *(cast(SUBSTRING(@NIFString , 5, 1) AS INT )) + 4*(CAST(SUBSTRING(@NIFString , 6, 1) AS INT )) +
    3 *(cast(SUBSTRING(@NIFString , 7, 1) AS INT )) + 2*(CAST(SUBSTRING(@NIFString , 8, 1) AS INT ))

    DECLARE @Remainder INT
    SET @Remainder = @Control % 11

    IF @Remainder < 2
		BEGIN
			IF CAST(SUBSTRING(@NIFString, 9 , 1) AS INT) = 0
				BEGIN
					SET @Output = 1
				END
			ELSE
				BEGIN
					SET @Output = 0
				END
		END
    ELSE
        BEGIN
            IF (11 - @Remainder) = CAST(SUBSTRING(@NIFString, 9, 1) AS INT)
            BEGIN
				SET @Output = 1
            END
            ELSE
            BEGIN
                SET @Output = 0
				RETURN @Output
            END
        END
    RETURN @Output
END

GO
/****** Object:  UserDefinedFunction [dbo].[VerificarInfraccaoAcesso]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <24/05/2017>
-- Description:	<...>
-- =============================================
CREATE FUNCTION [dbo].[VerificarInfraccaoAcesso]
(      
        @NumColab	INT,
		@DataHora	DATETIME
)
RETURNS BIT

AS
BEGIN
    DECLARE @Output BIT;
    SET @Output = 0;

    
    RETURN @Output
END

GO
/****** Object:  Table [dbo].[Colaboradores]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Colaboradores](
	[IdColaborador] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [varchar](100) NOT NULL,
	[IdHabLiteraria] [int] NOT NULL,
	[IdFuncao] [int] NOT NULL,
	[IdDepartamento] [int] NULL,
	[DataNasc] [date] NULL,
	[Localidade] [varchar](100) NULL,
	[CodPostal] [char](10) NULL,
	[Morada] [varchar](100) NULL,
	[Concelho] [varchar](100) NULL,
	[Distrito] [varchar](100) NULL,
	[IdEstCivil] [int] NOT NULL,
	[Conjugue] [varchar](100) NULL,
	[Telef] [nvarchar](50) NULL,
	[Tlm] [nvarchar](50) NULL,
	[Email] [varchar](254) NULL,
	[IdNacionalidade] [int] NOT NULL,
	[NumCC] [nvarchar](50) NULL,
	[DtValCC] [date] NULL,
	[NIF] [numeric](9, 0) NULL,
	[NISS] [numeric](11, 0) NULL,
	[Activo] [bit] NOT NULL,
	[IdBinario] [uniqueidentifier] NULL,
	[IdHorario] [int] NULL,
 CONSTRAINT [Colaboradores_PK] PRIMARY KEY CLUSTERED 
(
	[IdColaborador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ColaboradoresHorarios]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ColaboradoresHorarios](
	[IdHorario] [int] IDENTITY(1,1) NOT NULL,
	[Descricao] [varchar](254) NOT NULL,
	[IdComposicao] [int] NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Colaboradores_Horario_PK] PRIMARY KEY CLUSTERED 
(
	[IdHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AcessosColaboradores]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AcessosColaboradores](
	[IdAcessoColab] [bigint] IDENTITY(1,1) NOT NULL,
	[IdColaborador] [int] NOT NULL,
	[DataHora] [datetime] NOT NULL,
	[Tipo] [char](1) NULL,
	[Categoria] [char](1) NOT NULL,
	[Infraccao] [bit] NOT NULL,
	[Override] [bit] NULL,
 CONSTRAINT [Acessos_Colaboradores_PK] PRIMARY KEY CLUSTERED 
(
	[IdAcessoColab] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sys_Departamentos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_Departamentos](
	[IdDepartamento] [int] IDENTITY(1,1) NOT NULL,
	[Departamento] [varchar](100) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [sys_Departamentos_PK] PRIMARY KEY CLUSTERED 
(
	[IdDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sys_Funcoes]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_Funcoes](
	[IdFuncao] [int] IDENTITY(1,1) NOT NULL,
	[Funcao] [varchar](200) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [sys_Funcoes_PK] PRIMARY KEY CLUSTERED 
(
	[IdFuncao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vw_AcessosColabInfracoesUltimos30Dias]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_AcessosColabInfracoesUltimos30Dias]
AS
SELECT        dbo.Colaboradores.IdColaborador AS [Nº Colab.], dbo.Colaboradores.Nome, dbo.sys_Departamentos.Departamento, dbo.sys_Funcoes.Funcao AS Função, dbo.ColaboradoresHorarios.Descricao AS Horário, 
                         dbo.AcessosColaboradores.DataHora, dbo.AcessosColaboradores.Tipo
FROM            dbo.AcessosColaboradores INNER JOIN
                         dbo.Colaboradores ON dbo.AcessosColaboradores.IdColaborador = dbo.Colaboradores.IdColaborador INNER JOIN
                         dbo.sys_Departamentos ON dbo.Colaboradores.IdDepartamento = dbo.sys_Departamentos.IdDepartamento INNER JOIN
                         dbo.sys_Funcoes ON dbo.Colaboradores.IdFuncao = dbo.sys_Funcoes.IdFuncao INNER JOIN
                         dbo.ColaboradoresHorarios ON dbo.Colaboradores.IdHorario = dbo.ColaboradoresHorarios.IdHorario
WHERE        (dbo.AcessosColaboradores.Infraccao = 1) AND (dbo.AcessosColaboradores.DataHora BETWEEN DATEADD(DAY, - 30, GETDATE()) AND GETDATE())

GO
/****** Object:  Table [dbo].[sys_HabLiterarias]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_HabLiterarias](
	[IdHabLiteraria] [int] IDENTITY(1,1) NOT NULL,
	[HabLiteraria] [varchar](254) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [sys_HabLiterarias_PK] PRIMARY KEY CLUSTERED 
(
	[IdHabLiteraria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vw_Professores]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Professores]
AS
SELECT        dbo.Colaboradores.Nome, dbo.Colaboradores.Telef, dbo.Colaboradores.Tlm, dbo.Colaboradores.Email, dbo.sys_Departamentos.Departamento, dbo.sys_HabLiterarias.HabLiteraria AS [Hab. Lit.], 
                         dbo.sys_Funcoes.Funcao AS Função
FROM            dbo.Colaboradores INNER JOIN
                         dbo.sys_Departamentos ON dbo.Colaboradores.IdDepartamento = dbo.sys_Departamentos.IdDepartamento INNER JOIN
                         dbo.sys_HabLiterarias ON dbo.Colaboradores.IdHabLiteraria = dbo.sys_HabLiterarias.IdHabLiteraria INNER JOIN
                         dbo.sys_Funcoes ON dbo.Colaboradores.IdFuncao = dbo.sys_Funcoes.IdFuncao
WHERE        (dbo.Colaboradores.IdFuncao = 1)

GO
/****** Object:  Table [dbo].[Utentes]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Utentes](
	[IdUtente] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [varchar](100) NOT NULL,
	[DataNasc] [date] NOT NULL,
	[Telef] [char](20) NULL,
	[Tlm] [char](20) NULL,
	[Email] [varchar](254) NULL,
	[CodPostal] [char](10) NOT NULL,
	[Morada] [varchar](254) NULL,
	[IdEstCivil] [int] NOT NULL,
	[CC] [char](15) NULL,
	[NIF] [char](9) NULL,
	[Aluno] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Utentes_PK] PRIMARY KEY CLUSTERED 
(
	[IdUtente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Alunos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alunos](
	[IdAluno] [int] IDENTITY(1,1) NOT NULL,
	[IdUtente] [int] NOT NULL,
	[IdTurma] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Alunos_PK] PRIMARY KEY CLUSTERED 
(
	[IdAluno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Turmas]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Turmas](
	[IdTurma] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoTurma] [int] NOT NULL,
	[IdHorario] [int] NOT NULL,
	[NumVagas] [int] NOT NULL,
	[IdProfessor] [int] NOT NULL,
	[Descricao] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Turmas] PRIMARY KEY CLUSTERED 
(
	[IdTurma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TurmasTipos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TurmasTipos](
	[IdTipoTurma] [int] IDENTITY(1,1) NOT NULL,
	[TipoTurma] [varchar](1) NOT NULL,
	[Nivel] [int] NOT NULL,
	[LimiteAlunos] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [TiposTurma_PK] PRIMARY KEY CLUSTERED 
(
	[IdTipoTurma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vw_Alunos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Alunos]
AS
SELECT        dbo.Utentes.Nome, dbo.Utentes.DataNasc AS [Dt. Nasc.], dbo.Utentes.Telef AS [Telef.], dbo.Utentes.Tlm AS TLM, dbo.Utentes.Email, dbo.TurmasTipos.TipoTurma AS [Tipo Turma], 
                         dbo.Turmas.Descricao AS Turma, dbo.Colaboradores.Nome AS Professor
FROM            dbo.Alunos INNER JOIN
                         dbo.Utentes ON dbo.Alunos.IdUtente = dbo.Utentes.IdUtente INNER JOIN
                         dbo.Turmas ON dbo.Alunos.IdTurma = dbo.Turmas.IdTurma INNER JOIN
                         dbo.TurmasTipos ON dbo.Turmas.IdTipoTurma = dbo.TurmasTipos.IdTipoTurma INNER JOIN
                         dbo.Colaboradores ON dbo.Turmas.IdProfessor = dbo.Colaboradores.IdColaborador

GO
/****** Object:  View [dbo].[vw_AniversariosProx7Dias]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_AniversariosProx7Dias]
AS
SELECT        TOP (100) dbo.Colaboradores.IdColaborador AS [Nº Colab.], dbo.TratarNome(dbo.Colaboradores.Nome, 0, 0, 0) AS Nome, dbo.Colaboradores.DataNasc, CAST(dbo.CalcularAnos(dbo.Colaboradores.DataNasc) 
                         + 1 AS VARCHAR) + ' Anos' AS Faz, dbo.sys_Departamentos.Departamento, dbo.sys_Funcoes.Funcao
FROM            dbo.Colaboradores INNER JOIN
                         dbo.sys_Funcoes ON dbo.Colaboradores.IdFuncao = dbo.sys_Funcoes.IdFuncao INNER JOIN
                         dbo.sys_Departamentos ON dbo.Colaboradores.IdDepartamento = dbo.sys_Departamentos.IdDepartamento
WHERE        (DATEADD(Year, DATEPART(Year, GETDATE()) - DATEPART(Year, dbo.Colaboradores.DataNasc), dbo.Colaboradores.DataNasc) BETWEEN CONVERT(DATE, GETDATE()) AND CONVERT(DATE, GETDATE() + 7))

GO
/****** Object:  Table [dbo].[sys_Nacionalidades]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_Nacionalidades](
	[IdNacionalidade] [int] IDENTITY(1,1) NOT NULL,
	[Nacionalidade] [varchar](100) NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [sys_Nacionalidades_PK] PRIMARY KEY CLUSTERED 
(
	[IdNacionalidade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sys_EstCivil]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_EstCivil](
	[IdEstCivil] [int] IDENTITY(1,1) NOT NULL,
	[EstCivil] [varchar](50) NULL,
 CONSTRAINT [sys_EstCivil_PK] PRIMARY KEY CLUSTERED 
(
	[IdEstCivil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vw_Colaboradores]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Colaboradores]
AS
SELECT        dbo.Colaboradores.IdColaborador AS [Nº Colab.], dbo.TratarNome(dbo.Colaboradores.Nome, 0, 0, 1) AS Nome, dbo.Colaboradores.DataNasc AS [Dt. Nasc.], dbo.CalcularAnos(dbo.Colaboradores.DataNasc) 
                         AS Idade, dbo.sys_EstCivil.EstCivil AS [Est. Civil], dbo.Colaboradores.Conjugue, dbo.Colaboradores.Morada, dbo.Colaboradores.Localidade, dbo.Colaboradores.CodPostal AS [Cod. Postal], 
                         dbo.Colaboradores.Telef, dbo.Colaboradores.Tlm, LOWER(dbo.TratarNome(dbo.Colaboradores.Email, 0, 0, 1)) AS Email, dbo.sys_Nacionalidades.Nacionalidade, dbo.Colaboradores.NumCC AS [Nº CC], 
                         dbo.Colaboradores.DtValCC AS [Dt. Val. CC.], dbo.Colaboradores.NIF, dbo.Colaboradores.NISS, dbo.sys_HabLiterarias.HabLiteraria AS [Hab. Lit.], dbo.sys_Departamentos.Departamento, 
                         dbo.sys_Funcoes.Funcao AS Função, dbo.ColaboradoresHorarios.Descricao AS Horário
FROM            dbo.Colaboradores INNER JOIN
                         dbo.sys_Departamentos ON dbo.Colaboradores.IdDepartamento = dbo.sys_Departamentos.IdDepartamento INNER JOIN
                         dbo.sys_EstCivil ON dbo.Colaboradores.IdEstCivil = dbo.sys_EstCivil.IdEstCivil INNER JOIN
                         dbo.sys_Funcoes ON dbo.Colaboradores.IdFuncao = dbo.sys_Funcoes.IdFuncao INNER JOIN
                         dbo.sys_HabLiterarias ON dbo.Colaboradores.IdHabLiteraria = dbo.sys_HabLiterarias.IdHabLiteraria INNER JOIN
                         dbo.sys_Nacionalidades ON dbo.Colaboradores.IdNacionalidade = dbo.sys_Nacionalidades.IdNacionalidade INNER JOIN
                         dbo.ColaboradoresHorarios ON dbo.ColaboradoresHorarios.IdHorario = dbo.Colaboradores.IdHorario

GO
/****** Object:  View [dbo].[vw_Utentes]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Utentes]
AS
SELECT        dbo.Utentes.IdUtente AS [Nº Utente], dbo.Utentes.Nome, dbo.Utentes.DataNasc AS [Dt. Nasc.], dbo.Utentes.Telef, dbo.Utentes.Tlm, dbo.Utentes.Email, dbo.Utentes.CodPostal AS [Cod. Postal], 
                         dbo.Utentes.Morada, dbo.Utentes.CC AS [Nº CC], dbo.Utentes.NIF, CASE WHEN dbo.Utentes.Aluno = 1 THEN 'Sim' ELSE 'Não' END AS Aluno
FROM            dbo.Utentes INNER JOIN
                         dbo.sys_EstCivil ON dbo.Utentes.IdEstCivil = dbo.sys_EstCivil.IdEstCivil
WHERE        (dbo.Utentes.Activo = 1)

GO
/****** Object:  Table [dbo].[AcessosUtentes]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AcessosUtentes](
	[IdAcessoUtente] [bigint] IDENTITY(1,1) NOT NULL,
	[IdUtente] [int] NOT NULL,
	[DataHora] [datetime] NOT NULL,
	[Categoria] [char](1) NOT NULL,
	[Override] [bit] NOT NULL,
 CONSTRAINT [Acessos_Utentes_PK] PRIMARY KEY CLUSTERED 
(
	[IdAcessoUtente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AlunosHistorico]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlunosHistorico](
	[IdHistoricoAluno] [int] IDENTITY(1,1) NOT NULL,
	[IdAluno] [int] NOT NULL,
	[IdTurma] [int] NOT NULL,
	[DtInicio] [date] NOT NULL,
	[DtFim] [date] NOT NULL,
 CONSTRAINT [Alunos_Historico_PK] PRIMARY KEY CLUSTERED 
(
	[IdHistoricoAluno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Binarios]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Binarios](
	[IdBinario] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[FileType] [char](10) NOT NULL,
	[FileBytes] [binary](5000) NOT NULL,
 CONSTRAINT [PK_Binarios] PRIMARY KEY CLUSTERED 
(
	[IdBinario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ColaboradoresHorarioComposicao]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ColaboradoresHorarioComposicao](
	[IdComposicao] [int] IDENTITY(1,1) NOT NULL,
	[IdHorario] [int] NULL,
	[Dia] [int] NOT NULL,
	[HoraEntrada] [time](7) NOT NULL,
	[SaidaRefeicao] [time](7) NULL,
	[EntradaRefeicao] [time](7) NULL,
	[HoraSaida] [time](7) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_ColaboradoresHorarioComposicao] PRIMARY KEY CLUSTERED 
(
	[IdComposicao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ColaboradoresLog]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ColaboradoresLog](
	[IdColabLog] [int] IDENTITY(1,1) NOT NULL,
	[IdColaborador] [int] NOT NULL,
	[DataHora] [datetime] NOT NULL,
	[Descricao] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ColaboradoresLog] PRIMARY KEY CLUSTERED 
(
	[IdColabLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ComprasProdutosPecas]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ComprasProdutosPecas](
	[IdCompraProdPecas] [int] IDENTITY(1,1) NOT NULL,
	[DataCompra] [datetime] NOT NULL,
	[Qt] [int] NOT NULL,
	[IdProdutoPeca] [int] NOT NULL,
	[Fornecedor] [varchar](50) NOT NULL,
 CONSTRAINT [Compras_ProdutosPecas_PK] PRIMARY KEY CLUSTERED 
(
	[IdCompraProdPecas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Equipamentos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Equipamentos](
	[IdEquipamento] [int] IDENTITY(1,1) NOT NULL,
	[Equipamento] [varchar](254) NULL,
	[Descricao] [varchar](1000) NULL,
	[DataCompra] [datetime] NULL,
	[NumSerie] [varchar](50) NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [Equipamentos_PK] PRIMARY KEY CLUSTERED 
(
	[IdEquipamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ManutencaoEquipa]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManutencaoEquipa](
	[IdEquipaManutencao] [int] IDENTITY(1,1) NOT NULL,
	[IdManutencao] [int] NOT NULL,
	[IdColaborador] [int] NOT NULL,
 CONSTRAINT [Manutencao_Equipa_PK] PRIMARY KEY CLUSTERED 
(
	[IdEquipaManutencao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ManutencaoProdutosPecasUsados]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManutencaoProdutosPecasUsados](
	[IdProdutosPecasUsados] [int] IDENTITY(1,1) NOT NULL,
	[IdManutencao] [int] NOT NULL,
	[IdProdutoPeca] [int] NOT NULL,
 CONSTRAINT [Manutencao_ProdutosPecas_Usados_PK] PRIMARY KEY CLUSTERED 
(
	[IdProdutosPecasUsados] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Manutencoes]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Manutencoes](
	[IdManutencao] [int] IDENTITY(1,1) NOT NULL,
	[Equipamentos_IdEquipamento] [int] NOT NULL,
	[Descricao] [varchar](max) NULL,
	[Obs] [varchar](1000) NULL,
 CONSTRAINT [Manutencoes_PK] PRIMARY KEY CLUSTERED 
(
	[IdManutencao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Presencas]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Presencas](
	[IdPresenca] [bigint] IDENTITY(1,1) NOT NULL,
	[IdColaborador] [int] NOT NULL,
	[DataHora] [datetime] NOT NULL,
	[TipoMov] [char](1) NOT NULL,
	[Infraccao] [bit] NOT NULL,
 CONSTRAINT [Presencas_PK] PRIMARY KEY CLUSTERED 
(
	[IdPresenca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProdutosPecas]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProdutosPecas](
	[IdProdutoPeca] [int] IDENTITY(1,1) NOT NULL,
	[Tipo] [varchar](20) NULL,
	[Descricao] [varchar](254) NOT NULL,
	[ControlarStock] [bit] NOT NULL,
	[StockMin] [int] NOT NULL,
	[StockActual] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Produtos_Pecas_PK] PRIMARY KEY CLUSTERED 
(
	[IdProdutoPeca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProdutosPecasMovimentos]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProdutosPecasMovimentos](
	[IdMovProdPeca] [int] IDENTITY(1,1) NOT NULL,
	[DataHora] [datetime] NOT NULL,
	[TipoMov] [varchar](1) NULL,
	[Qt] [int] NULL,
	[IdProdutoPeca] [int] NOT NULL,
 CONSTRAINT [ProdutosPecas_Movimentos_PK] PRIMARY KEY CLUSTERED 
(
	[IdMovProdPeca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProdutosPecasOrdensCompra]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProdutosPecasOrdensCompra](
	[IdOrdemCompraProdPeca] [int] IDENTITY(1,1) NOT NULL,
	[IdProdutoPeca] [int] NOT NULL,
	[Data] [datetime] NOT NULL,
	[Qt] [int] NOT NULL,
	[Processada] [bit] NOT NULL,
 CONSTRAINT [PK_ProdutosPecasOrdensCompra] PRIMARY KEY CLUSTERED 
(
	[IdOrdemCompraProdPeca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sys_CodPostal]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_CodPostal](
	[CodPostal] [char](10) NOT NULL,
	[Distrito] [varchar](254) NULL,
	[Concelho] [varchar](254) NULL,
	[Rua] [varchar](254) NULL,
	[Localidade] [varchar](254) NULL,
 CONSTRAINT [sys_CodPostal_PK] PRIMARY KEY CLUSTERED 
(
	[CodPostal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TurmasHorarioComposicao]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TurmasHorarioComposicao](
	[IdCompHorario] [int] IDENTITY(1,1) NOT NULL,
	[IdHorario] [int] NOT NULL,
	[DiaSemana] [varchar](2) NOT NULL,
	[HoraInicio] [time](7) NOT NULL,
	[HoraFim] [time](7) NOT NULL,
 CONSTRAINT [Turmas_Horario_Composicao_PK] PRIMARY KEY CLUSTERED 
(
	[IdCompHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TurmasHorarios]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TurmasHorarios](
	[IdHorario] [int] IDENTITY(1,1) NOT NULL,
	[Descricao] [varchar](1000) NOT NULL,
	[HoraInicio] [time](7) NOT NULL,
	[HoraFim] [time](7) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Turmas_Horarios_PK] PRIMARY KEY CLUSTERED 
(
	[IdHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[AcessosColaboradores] ADD  CONSTRAINT [DF_AcessosColaboradores_DataHora]  DEFAULT (getdate()) FOR [DataHora]
GO
ALTER TABLE [dbo].[AcessosColaboradores] ADD  CONSTRAINT [DF_AcessosColaboradores_Infraccao]  DEFAULT ((0)) FOR [Infraccao]
GO
ALTER TABLE [dbo].[Alunos] ADD  CONSTRAINT [DF_Alunos_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Binarios] ADD  CONSTRAINT [DF_Binarios_IdBinario]  DEFAULT (newid()) FOR [IdBinario]
GO
ALTER TABLE [dbo].[Colaboradores] ADD  CONSTRAINT [DF_Colaboradores_IdNacionalidade]  DEFAULT ((1)) FOR [IdNacionalidade]
GO
ALTER TABLE [dbo].[Colaboradores] ADD  CONSTRAINT [DF_Colaboradores_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[ColaboradoresHorarioComposicao] ADD  CONSTRAINT [DF_ColaboradoresHorarioComposicao_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[ColaboradoresHorarios] ADD  CONSTRAINT [DF_ColaboradoresHorarios_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[ColaboradoresLog] ADD  CONSTRAINT [DF_ColaboradoresLog_DataHora]  DEFAULT (getdate()) FOR [DataHora]
GO
ALTER TABLE [dbo].[ProdutosPecas] ADD  CONSTRAINT [DF_ProdutosPecas_ControlarStock]  DEFAULT ((1)) FOR [ControlarStock]
GO
ALTER TABLE [dbo].[ProdutosPecas] ADD  CONSTRAINT [DF_ProdutosPecas_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[ProdutosPecasMovimentos] ADD  CONSTRAINT [DF_ProdutosPecasMovimentos_DataHora]  DEFAULT (getdate()) FOR [DataHora]
GO
ALTER TABLE [dbo].[ProdutosPecasOrdensCompra] ADD  CONSTRAINT [DF_ProdutosPecasOrdensCompra_Data]  DEFAULT (getdate()) FOR [Data]
GO
ALTER TABLE [dbo].[ProdutosPecasOrdensCompra] ADD  CONSTRAINT [DF_ProdutosPecasOrdensCompra_Processada]  DEFAULT ((0)) FOR [Processada]
GO
ALTER TABLE [dbo].[TurmasHorarios] ADD  CONSTRAINT [DF_TurmasHorarios_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[TurmasTipos] ADD  CONSTRAINT [DF_TurmasTipos_Nivel]  DEFAULT ((1)) FOR [Nivel]
GO
ALTER TABLE [dbo].[TurmasTipos] ADD  CONSTRAINT [DF_TurmasTipos_LimiteAlunos]  DEFAULT ((15)) FOR [LimiteAlunos]
GO
ALTER TABLE [dbo].[TurmasTipos] ADD  CONSTRAINT [DF_TurmasTipos_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Utentes] ADD  CONSTRAINT [DF_Utentes_Aluno]  DEFAULT ((0)) FOR [Aluno]
GO
ALTER TABLE [dbo].[Utentes] ADD  CONSTRAINT [DF_Utentes_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[AcessosColaboradores]  WITH CHECK ADD  CONSTRAINT [FK_Colaboradores] FOREIGN KEY([IdColaborador])
REFERENCES [dbo].[Colaboradores] ([IdColaborador])
GO
ALTER TABLE [dbo].[AcessosColaboradores] CHECK CONSTRAINT [FK_Colaboradores]
GO
ALTER TABLE [dbo].[AcessosUtentes]  WITH CHECK ADD  CONSTRAINT [Acessos_Utentes_Utentes_FK] FOREIGN KEY([IdUtente])
REFERENCES [dbo].[Utentes] ([IdUtente])
GO
ALTER TABLE [dbo].[AcessosUtentes] CHECK CONSTRAINT [Acessos_Utentes_Utentes_FK]
GO
ALTER TABLE [dbo].[Alunos]  WITH CHECK ADD  CONSTRAINT [FK_Turmas] FOREIGN KEY([IdTurma])
REFERENCES [dbo].[Turmas] ([IdTurma])
GO
ALTER TABLE [dbo].[Alunos] CHECK CONSTRAINT [FK_Turmas]
GO
ALTER TABLE [dbo].[Alunos]  WITH CHECK ADD  CONSTRAINT [FK_Utentes] FOREIGN KEY([IdUtente])
REFERENCES [dbo].[Utentes] ([IdUtente])
GO
ALTER TABLE [dbo].[Alunos] CHECK CONSTRAINT [FK_Utentes]
GO
ALTER TABLE [dbo].[AlunosHistorico]  WITH CHECK ADD  CONSTRAINT [FK_Alunos] FOREIGN KEY([IdAluno])
REFERENCES [dbo].[Alunos] ([IdAluno])
GO
ALTER TABLE [dbo].[AlunosHistorico] CHECK CONSTRAINT [FK_Alunos]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_Binarios] FOREIGN KEY([IdBinario])
REFERENCES [dbo].[Binarios] ([IdBinario])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_Binarios]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_IdDepartamento] FOREIGN KEY([IdDepartamento])
REFERENCES [dbo].[sys_Departamentos] ([IdDepartamento])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_IdDepartamento]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_IdEstCivil] FOREIGN KEY([IdEstCivil])
REFERENCES [dbo].[sys_EstCivil] ([IdEstCivil])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_IdEstCivil]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_IdFuncao] FOREIGN KEY([IdFuncao])
REFERENCES [dbo].[sys_Funcoes] ([IdFuncao])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_IdFuncao]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_IdHabLiteraria] FOREIGN KEY([IdHabLiteraria])
REFERENCES [dbo].[sys_HabLiterarias] ([IdHabLiteraria])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_IdHabLiteraria]
GO
ALTER TABLE [dbo].[Colaboradores]  WITH CHECK ADD  CONSTRAINT [FK_IdNacionalidade] FOREIGN KEY([IdNacionalidade])
REFERENCES [dbo].[sys_Nacionalidades] ([IdNacionalidade])
GO
ALTER TABLE [dbo].[Colaboradores] CHECK CONSTRAINT [FK_IdNacionalidade]
GO
ALTER TABLE [dbo].[ComprasProdutosPecas]  WITH CHECK ADD  CONSTRAINT [Compras_ProdutosPecas_Produtos_Pecas_FK] FOREIGN KEY([IdProdutoPeca])
REFERENCES [dbo].[ProdutosPecas] ([IdProdutoPeca])
GO
ALTER TABLE [dbo].[ComprasProdutosPecas] CHECK CONSTRAINT [Compras_ProdutosPecas_Produtos_Pecas_FK]
GO
ALTER TABLE [dbo].[ManutencaoEquipa]  WITH CHECK ADD  CONSTRAINT [Manutencao_Equipa_Manutencoes_FK] FOREIGN KEY([IdManutencao])
REFERENCES [dbo].[Manutencoes] ([IdManutencao])
GO
ALTER TABLE [dbo].[ManutencaoEquipa] CHECK CONSTRAINT [Manutencao_Equipa_Manutencoes_FK]
GO
ALTER TABLE [dbo].[ManutencaoProdutosPecasUsados]  WITH CHECK ADD  CONSTRAINT [Manutencao_ProdutosPecas_Usados_Manutencoes_FK] FOREIGN KEY([IdManutencao])
REFERENCES [dbo].[Manutencoes] ([IdManutencao])
GO
ALTER TABLE [dbo].[ManutencaoProdutosPecasUsados] CHECK CONSTRAINT [Manutencao_ProdutosPecas_Usados_Manutencoes_FK]
GO
ALTER TABLE [dbo].[ManutencaoProdutosPecasUsados]  WITH CHECK ADD  CONSTRAINT [Manutencao_ProdutosPecas_Usados_Produtos_Pecas_FK] FOREIGN KEY([IdProdutoPeca])
REFERENCES [dbo].[ProdutosPecas] ([IdProdutoPeca])
GO
ALTER TABLE [dbo].[ManutencaoProdutosPecasUsados] CHECK CONSTRAINT [Manutencao_ProdutosPecas_Usados_Produtos_Pecas_FK]
GO
ALTER TABLE [dbo].[Manutencoes]  WITH CHECK ADD  CONSTRAINT [Manutencoes_Equipamentos_FK] FOREIGN KEY([Equipamentos_IdEquipamento])
REFERENCES [dbo].[Equipamentos] ([IdEquipamento])
GO
ALTER TABLE [dbo].[Manutencoes] CHECK CONSTRAINT [Manutencoes_Equipamentos_FK]
GO
ALTER TABLE [dbo].[ProdutosPecasMovimentos]  WITH CHECK ADD  CONSTRAINT [ProdutosPecas_Movimentos_Produtos_Pecas_FK] FOREIGN KEY([IdProdutoPeca])
REFERENCES [dbo].[ProdutosPecas] ([IdProdutoPeca])
GO
ALTER TABLE [dbo].[ProdutosPecasMovimentos] CHECK CONSTRAINT [ProdutosPecas_Movimentos_Produtos_Pecas_FK]
GO
ALTER TABLE [dbo].[ProdutosPecasOrdensCompra]  WITH CHECK ADD  CONSTRAINT [FK_ProdutosPecasOrdensCompra_ProdutosPecas] FOREIGN KEY([IdProdutoPeca])
REFERENCES [dbo].[ProdutosPecas] ([IdProdutoPeca])
GO
ALTER TABLE [dbo].[ProdutosPecasOrdensCompra] CHECK CONSTRAINT [FK_ProdutosPecasOrdensCompra_ProdutosPecas]
GO
ALTER TABLE [dbo].[Turmas]  WITH CHECK ADD  CONSTRAINT [Turmas_TiposTurma_FK] FOREIGN KEY([IdTipoTurma])
REFERENCES [dbo].[TurmasTipos] ([IdTipoTurma])
GO
ALTER TABLE [dbo].[Turmas] CHECK CONSTRAINT [Turmas_TiposTurma_FK]
GO
ALTER TABLE [dbo].[Turmas]  WITH CHECK ADD  CONSTRAINT [Turmas_Turmas_Horarios_FK] FOREIGN KEY([IdHorario])
REFERENCES [dbo].[TurmasHorarios] ([IdHorario])
GO
ALTER TABLE [dbo].[Turmas] CHECK CONSTRAINT [Turmas_Turmas_Horarios_FK]
GO
ALTER TABLE [dbo].[TurmasHorarioComposicao]  WITH CHECK ADD  CONSTRAINT [Turmas_Horario_Composicao_Turmas_Horarios_FK] FOREIGN KEY([IdHorario])
REFERENCES [dbo].[TurmasHorarios] ([IdHorario])
GO
ALTER TABLE [dbo].[TurmasHorarioComposicao] CHECK CONSTRAINT [Turmas_Horario_Composicao_Turmas_Horarios_FK]
GO
ALTER TABLE [dbo].[Utentes]  WITH CHECK ADD  CONSTRAINT [Utentes_sys_EstCivil_FK] FOREIGN KEY([IdEstCivil])
REFERENCES [dbo].[sys_EstCivil] ([IdEstCivil])
GO
ALTER TABLE [dbo].[Utentes] CHECK CONSTRAINT [Utentes_sys_EstCivil_FK]
GO
/****** Object:  StoredProcedure [dbo].[sp_AcessosColaboradoresCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <24/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_AcessosColaboradoresCreate]
	@IdColaborador	AS INT,
	@DataHora		AS DATETIME,
	@Categoria		AS CHAR(1),
	/*@Infraccao		AS BIT,*/
	@Override		AS BIT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.AcessosColaboradores 
			(
				[IdColaborador],[DataHora],[Tipo],[Categoria],[Infraccao],[Override]
			)
			VALUES 
			(
				@IdColaborador,@DataHora, 
				CASE 
					WHEN (SELECT 
							TOP 1 AC.Tipo 
							FROM dbo.AcessosColaboradores AC 
							WHERE AC.IdColaborador = @IdColaborador 
							ORDER BY AC.IdAcessoColab /*AC.DataHora*/ DESC) = 'E' THEN 'S' ELSE 'E' END,
				@Categoria, 
				[dbo].[VerificarInfraccaoAcesso](@IdColaborador, @DataHora),				
				@Override 				
			)
		COMMIT TRANSACTION
		SELECT CAST('S' AS CHAR) -- Retorna Sucesso
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST('E' AS CHAR) -- Retorna Erro  
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END

GO
/****** Object:  StoredProcedure [dbo].[sp_AlunoCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_AlunoCreate]
	@IdUtente	AS INT,
	@IdTurma	AS INT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION		
			INSERT INTO dbo.Alunos 
			(
				IdUtente, IdTurma
			)
			VALUES 
			(
				@IdUtente, @IdTurma
			)

			--DECLARE @TempId INT;
			--SET @TempId = (SELECT SCOPE_IDENTITY() FROM dbo.Alunos);

			UPDATE dbo.Utentes
			SET
			    Aluno = 1   
			WHERE
				IdUtente = @IdUtente
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_AlunoUpdate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
create PROCEDURE [dbo].[sp_AlunoUpdate]
	@IdAluno	INT,
	@IdTurma	INT,
	@Activo		BIT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION		
			UPDATE dbo.Alunos 
			SET
				IdTurma = @IdTurma,
				Activo = @Activo
			WHERE
				IdAluno = @IdAluno
			
			IF (@Activo = 0)
			BEGIN
				UPDATE dbo.Utentes
				SET
					Aluno = 0
				WHERE
					IdUtente = (SELECT IdUtente FROM dbo.Alunos WHERE IdAluno = @IdAluno)
			END


		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_BinarioCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_BinarioCreate]
	@FileType		AS VARCHAR(10),
	@FileBytes		AS VARBINARY(5000)
	
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @Output table(PkId UNIQUEIDENTIFIER);

	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.Binarios 
			(
				[FileType],[FileBytes]
			)
			OUTPUT INSERTED.IdBinario INTO @Output
			VALUES 
			(
				@FileType,@FileBytes
			)
		COMMIT TRANSACTION
		--SELECT CAST(1 AS BIT)
		SELECT * FROM @Output
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END
GO
/****** Object:  StoredProcedure [dbo].[sp_BinarioRead]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
create PROCEDURE [dbo].[sp_BinarioRead]
	@IdBinario		AS UNIQUEIDENTIFIER,
	@FileType		AS VARCHAR(10),
	@FileBytes		AS VARBINARY(5000)
	
AS
BEGIN

	SET NOCOUNT ON;
	SELECT
		FileType,
		FileBytes
	FROM
		dbo.Binarios
	WHERE
		IdBinario = @IdBinario

END
GO
/****** Object:  StoredProcedure [dbo].[sp_ColaboradorCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ColaboradorCreate]
	@Nome				VARCHAR(100),
	@IdHabLiteraria		INT,
	@IdFuncao			INT,
	@IdDepartamento		INT,
	@DataNasc			DATE,
	@Localidade			VARCHAR(100),
	@CodPostal			VARCHAR(50),
	@Morada				VARCHAR(100),
	@Concelho			VARCHAR(100),
	@Distrito			VARCHAR(100),
	@IdEstCivil			INT,
	@Conjugue			VARCHAR(100),
	@Telef				VARCHAR(100),
	@Tlm				VARCHAR(100),
	@Email				VARCHAR(100),
	@IdNacionalidade	INT,
	@NumCC				NUMERIC,
	@DtValCC			DATE,
	@NIF				NUMERIC(9,0),
	@NISS				NUMERIC(11,0),
	@Activo				BIT,
	@IdBinario			UNIQUEIDENTIFIER,
	@IdHorario			INT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.Colaboradores 
			(
				[Nome],[IdHabLiteraria],[IdFuncao],[IdDepartamento],[DataNasc],[Localidade],[CodPostal],[Morada],[Concelho],[Distrito],
				[IdEstCivil],[Conjugue],[Telef],[Tlm],[Email],[IdNacionalidade],[NumCC],[DtValCC],[NIF],[NISS],[Activo],[IdBinario],[IdHorario])
			VALUES 
			(
				@Nome,@IdHabLiteraria, @IdFuncao, @IdDepartamento, @DataNasc, @Localidade, @CodPostal, @Morada, @Concelho, @Distrito, 
				@IdEstCivil, @Conjugue, @Telef, @Tlm, @Email, @IdNacionalidade, @NumCC, @DtValCC, @NIF, @NISS, @Activo, @IdBinario, @IdHorario
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END
GO
/****** Object:  StoredProcedure [dbo].[sp_ColaboradorRead]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ColaboradorRead]	
	@IdColaborador	INT

AS
BEGIN

	SET NOCOUNT ON;
	SELECT 
		[IdColaborador]
		,[Nome]
		,[IdHabLiteraria]
		,[IdFuncao]
		,[IdDepartamento]
		,[DataNasc]
		,[Localidade]
		,[CodPostal]
		,[Morada]
		,[Concelho]
		,[Distrito]
		,[IdEstCivil]
		,[Conjugue]
		,[Telef]
		,[Tlm]
		,[Email]
		,[IdNacionalidade]
		,[NumCC]
		,[DtValCC]
		,[NIF]
		,[NISS]
		,[Activo]
		,[IdBinario]
		,[IdHorario]
	FROM 
		[Barcacellos].[dbo].[Colaboradores]
	WHERE
		[IdColaborador] = @IdColaborador

END
GO
/****** Object:  StoredProcedure [dbo].[sp_ColaboradorReadListDadosEmFalta]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <24/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ColaboradorReadListDadosEmFalta]

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TempTable TABLE (IdColaborador INT, Nome VARCHAR(250), Msg VARCHAR(MAX));

	DECLARE @_IdColaborador INT;
	DECLARE @_Nome VARCHAR(250);
	DECLARE @_Msg VARCHAR(MAX);

	DECLARE DADOSCOLAB_CURSOR CURSOR FOR 
		SELECT
			IdColaborador, Nome, NULL
		FROM 
			dbo.Colaboradores

	OPEN DADOSCOLAB_CURSOR;
	FETCH NEXT FROM DADOSCOLAB_CURSOR INTO @_IdColaborador, @_Nome, @_Msg;

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		BEGIN	
			SET @_Msg = '';
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.IdDepartamento FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Departamento. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.DataNasc FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta DT. Nasc. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Localidade FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Localidade. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.CodPostal FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Cod. Postal. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Morada FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Morada. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Concelho FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Concelho. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Distrito FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Distrito. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Telef FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Telef. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Tlm FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Tlm. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Conjugue FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.IdEstCivil = 1 AND C.Activo = 1) IS NULL THEN 'Falta Nome Conjugue.' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Email FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Email. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.NumCC FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta NumCC. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.DtValCC FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Dt. Val. CC. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.NIF FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta NIF. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT dbo.ValidarNIF(C.NIF) FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.NIF IS NOT NULL AND C.Activo = 1) = 0 THEN 'NIF Inválido ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.NISS FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta NISS. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.IdBinario FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Foto. ' END));
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.IdHorario FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.Activo = 1) IS NULL THEN 'Falta Horário. ' END));			
			SET @_Msg = CONCAT(@_Msg, (SELECT CASE WHEN (SELECT C.Conjugue FROM dbo.Colaboradores C WHERE C.IdColaborador = @_IdColaborador AND C.IdEstCivil = 1) IS NULL THEN 'Falta Nome Conjugue.' END));

			IF (@_Msg != '')
			BEGIN
				INSERT INTO @TempTable
				VALUES (@_IdColaborador, @_Nome, @_Msg)
			END

		END		
		
		FETCH NEXT FROM DADOSCOLAB_CURSOR INTO @_IdColaborador, @_Nome, @_Msg;
	END
	CLOSE DADOSCOLAB_CURSOR;
	DEALLOCATE DADOSCOLAB_CURSOR;

	SELECT * FROM @TempTable;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ColaboradorUpdate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <23/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ColaboradorUpdate]
	@IdColaborador		INT,
	@Nome				VARCHAR(100),
	@IdHabLiteraria		INT,
	@IdFuncao			INT,
	@IdDepartamento		INT,
	@DataNasc			DATE,
	@Localidade			VARCHAR(100),
	@CodPostal			VARCHAR (50),
	@Morada				VARCHAR(100),
	@Concelho			VARCHAR(100),
	@Distrito			VARCHAR(100),
	@IdEstCivil			INT,
	@Conjugue			VARCHAR(100),
	@Telef				VARCHAR(100),
	@Tlm				VARCHAR(100),
	@Email				VARCHAR(100),
	@IdNacionalidade	INT,
	@NumCC				NUMERIC,
	@DtValCC			DATE,
	@NIF				NUMERIC(9,0),
	@NISS				NUMERIC(11,0),
	@Activo				BIT,
	@IdBinario			UNIQUEIDENTIFIER,
	@IdHorario			INT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			UPDATE dbo.Colaboradores 
			SET
				[Nome] = @Nome,
				[IdHabLiteraria] = @IdHabLiteraria,
				[IdFuncao] = @IdFuncao,
				[IdDepartamento] = @IdDepartamento,
				[DataNasc] =  @DataNasc,
				[Localidade] = @Localidade,
				[CodPostal] = @CodPostal,
				[Morada] = @Morada,
				[Concelho] = @Concelho,
				[Distrito] = @Distrito,
				[IdEstCivil] = @IdEstCivil,
				[Conjugue] = @Conjugue,
				[Telef] = @Telef,
				[Tlm] = @Tlm,
				[Email] = @Email,
				[IdNacionalidade] = @IdNacionalidade,
				[NumCC] = @NumCC,
				[DtValCC] = @DtValCC,
				[NIF] = @NIF,
				[NISS] = @NISS,
				[Activo] = @Activo,
				[IdBinario] = @IdBinario,
				[IdHorario] = @IdHorario
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS 'ErrorMessage'; 
	END CATCH; 

END

GO
/****** Object:  StoredProcedure [dbo].[sp_DepartamentosCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DepartamentosCreate]
	@Departamento varchar(50)

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.sys_Departamentos 
			(
				[Departamento], [Activo]
			)
			VALUES 
			(
				@Departamento, 1
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_DepartamentosReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <13/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DepartamentosReadList]

AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		Departamento
	FROM
		dbo.sys_Departamentos
	WHERE
		Activo = 1
	ORDER BY 
		Departamento
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_EstCivilCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_EstCivilCreate]
	@EstCivil as varchar(50)

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.sys_EstCivil ([EstCivil])
			VALUES (@EstCivil)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_EstCivilReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <13/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_EstCivilReadList]

AS
BEGIN

	SET NOCOUNT ON;
	SELECT
		EstCivil
	FROM
		dbo.sys_EstCivil
	ORDER BY
		EstCivil
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_FuncoesCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_FuncoesCreate]
	@Funcao varchar(50)

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.sys_Funcoes 
			(
				[Funcao], [Activo]
			)
			VALUES 
			(
				@Funcao, 1
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END
GO
/****** Object:  StoredProcedure [dbo].[sp_FuncoesReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <13/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_FuncoesReadList]

AS
BEGIN

	SET NOCOUNT ON;

    SELECT
		Funcao
	FROM
		dbo.sys_Funcoes
	WHERE
		Activo = 1
	ORDER BY
		Funcao
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_HabLiterariaCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_HabLiterariaCreate]
	@HabLiteraria varchar(100)

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.sys_HabLiterarias
			(
				[HabLiteraria], [Activo]
			)
			VALUES 
			(
				@HabLiteraria, 1
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END
GO
/****** Object:  StoredProcedure [dbo].[sp_HabLiterariaReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_HabLiterariaReadList]

AS
BEGIN

	SET NOCOUNT ON;

    SELECT
		HabLiteraria
	FROM
		dbo.sys_HabLiterarias
	WHERE
		Activo = 1
	ORDER BY
		HabLiteraria
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_NacionalidadeCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_NacionalidadeCreate]
	@Nacionalidade as varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.sys_Nacionalidades 
			(
				[Nacionalidade], [Activo]
			)
			VALUES 
			(
				@Nacionalidade, 1
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_NacionalidadeReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <11/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_NacionalidadeReadList]

AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		Nacionalidade
	FROM
		dbo.Nacionalidade
	WHERE
		Activo = 1
	ORDER BY
		Nacionalidade
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ProdutosPecasCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProdutosPecasCreate]
	@Tipo				VARCHAR(20),
	@Descricao			VARCHAR(254),
	@ControlarStock		BIT,
	@StockMin			INT,
	@StockActual		INT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO [dbo].[ProdutosPecas] 
			(
				[Tipo],[Descricao],[ControlarStock],[StockMin],[StockActual]
			)
			VALUES 
			(
				@Tipo, @Descricao, @ControlarStock, @StockMin, @StockActual
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ProdutosPecasUpdate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <23/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProdutosPecasUpdate]
	@IdProdutoPeca		INT,
	@Tipo				VARCHAR(20),
	@Descricao			VARCHAR(254),
	@ControlarStock		BIT,
	@StockMin			INT,
	@StockActual		INT,
	@Activo				BIT

AS
BEGIN

	BEGIN TRY 
		BEGIN TRANSACTION
			UPDATE [dbo].[ProdutosPecas]
			SET
				[dbo].[ProdutosPecas].Tipo = @Tipo,
				[Descricao] = @Descricao,
				[ControlarStock] = @ControlarStock,
				[StockMin] = @StockMin,
				[StockActual] = @StockActual,
				[Activo] = @Activo
			WHERE
				[dbo].[ProdutosPecas].[IdProdutoPeca] = @IdProdutoPeca
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 
	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ProdutosPecasUpdateStocks]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <23/05/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProdutosPecasUpdateStocks]
	@IdProdutoPeca	INT,
	@TipoMov		VARCHAR(1), -- E - Entrada / S - Saida	
	@Qt				INT

AS
BEGIN

	BEGIN TRY 
		BEGIN TRANSACTION

		IF (@TipoMov = 'S' AND ((SELECT [StockActual] FROM [dbo].[ProdutosPecas] WHERE [IdProdutoPeca] = @IdProdutoPeca) - @Qt) < 0 )
		BEGIN
			RAISERROR('ERRO - Valor de saida de stock não pode ser superior ao valor de stock actual.', 11, 1);
		END			

		ELSE
		BEGIN
			UPDATE [dbo].[ProdutosPecas]
			SET			
				[StockActual] = 
					CASE 
						WHEN UPPER(@TipoMov) = 'S' THEN ([StockActual] - @Qt)
						WHEN UPPER(@TipoMov) = 'E' THEN ([StockActual] + @Qt)					
					END
			WHERE
				[dbo].[ProdutosPecas].[IdProdutoPeca] = @IdProdutoPeca
		END			
				
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS 'Msg Erro'; 
	END CATCH; 
	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_TiposTurmasCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <13/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_TiposTurmasCreate]
	@TipoTurma		AS VARCHAR(1), 
	@Nivel			AS INT,
	@LimiteAlunos	AS INT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO [dbo].[TiposTurma] 
			(
				[TipoTurma],[Nivel],[LimiteAlunos],[Activo]
			)
			VALUES 
			(
				@TipoTurma, @Nivel, @LimiteAlunos, 1
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH; 

END

GO
/****** Object:  StoredProcedure [dbo].[sp_TiposTurmasReadList]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <13/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_TiposTurmasReadList]

AS
BEGIN

	SET NOCOUNT ON;

	SELECT
		[IdTipoTurma]
		,[TipoTurma]
		,[Nivel]
		,[LimiteAlunos]
	FROM
		[dbo].[TiposTurma]
	WHERE
		Activo = 1
	ORDER BY 
		TipoTurma
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_UtenteCreate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_UtenteCreate]
	@Nome		VARCHAR(100),
	@DataNasc	DATE,
	@Telef		VARCHAR(100),
	@Tlm		VARCHAR(100),
	@Email		VARCHAR(100),
	@CodPostal	VARCHAR(10),
	@Morada		VARCHAR(100),
	@IdEstCivil INT,
	@CC			NUMERIC,
	@NIF		NUMERIC

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			INSERT INTO dbo.Utentes 
			(
				[Nome],[DataNasc],[Telef],[Tlm],[Email],[CodPostal],[Morada],[IdEstCivil],[CC],[NIF]
			)
			VALUES 
			(
				@Nome,@DataNasc,@Telef,@Tlm,@Email,@CodPostal,@Morada,@IdEstCivil,@CC,@NIF
			)
		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS 'ErrorMessage'; 
	END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_UtenteRead]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <25/54/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_UtenteRead]
	@IdUtente	INT
AS
BEGIN

	SET NOCOUNT ON;
	SELECT
		[IdUtente],
		[Nome],
		[DataNasc],
		[Telef],
		[Tlm],
		[Email],
		[CodPostal],
		[Morada],
		[IdEstCivil],
		[CC],
		[NIF],
		[Aluno],
		[Activo]
	FROM
		dbo.Utentes
	WHERE
		IdUtente = @IdUtente

END
GO
/****** Object:  StoredProcedure [dbo].[sp_UtenteReadListAniverProx15Dias]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <25/54/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_UtenteReadListAniverProx15Dias]

AS
BEGIN

	SET NOCOUNT ON;
	SELECT 
		[IdUtente] AS 'Nº Utente'
		,[Nome] AS 'Utente'
		,[DataNasc] AS 'Dt. Nasc.',
		'Faz ' + CAST(dbo.CalcularAnos([DataNasc]) AS VARCHAR) + ' Anos' AS 'Obs.'
	INTO #TempTable 
	FROM 
		dbo.Utentes
	WHERE
		Activo = 1 
		AND (DATEADD(Year, DATEPART(Year, GETDATE()) - DATEPART(Year, DataNasc), DataNasc) BETWEEN CONVERT(DATE, GETDATE()) AND CONVERT(DATE, GETDATE() + 15))

	SELECT *
	FROM 
		#TempTable
	
	DROP TABLE #TempTable

END
GO
/****** Object:  StoredProcedure [dbo].[sp_UtenteUpdate]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Angelo Ferreira, Rui Costa, Miguel Pimenta>
-- Create date: <06/04/2017>
-- Description:	<...>
-- =============================================
CREATE PROCEDURE [dbo].[sp_UtenteUpdate]
	@IdUtente	INT,
	@Nome		VARCHAR(100),
	@DataNasc	DATE,
	@Telef		VARCHAR(100),
	@Tlm		VARCHAR(100),
	@Email		VARCHAR(100),
	@CodPostal	VARCHAR(10),
	@Morada		VARCHAR(100),
	@IdEstCivil INT,
	@CC			NUMERIC,
	@NIF		NUMERIC,
	@Aluno		BIT,
	@Activo		BIT

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			UPDATE dbo.Utentes
			SET
				[Nome] = @Nome,
				[DataNasc] = @DataNasc,
				[Telef] = @Telef,
				[Tlm] = @Tlm,
				[Email] = @Email,
				[CodPostal] = @CodPostal,
				[Morada] = @Morada,
				[IdEstCivil] = @IdEstCivil,
				[CC] = @CC,
				[NIF] = @NIF,
				[Aluno] = @Aluno,
				[Activo] = @Activo
			WHERE
				[IdUtente] = @IdUtente

		COMMIT TRANSACTION
		SELECT CAST(1 AS BIT)
	END TRY 

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT CAST(0 AS BIT)      
		SELECT ERROR_MESSAGE() AS 'ErrorMessage'; 
	END CATCH;

END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetErrorInfo]    Script Date: 29/05/2017 17:23:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetErrorInfo]  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  


GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Abertura pelo Recepcionista' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AcessosColaboradores', @level2type=N'COLUMN',@level2name=N'Override'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Produto ou Peça' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProdutosPecas', @level2type=N'COLUMN',@level2name=N'Tipo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valida se o sys deve emitir alertas de stock ou n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProdutosPecas', @level2type=N'COLUMN',@level2name=N'ControlarStock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entrada / Saida (In/Out)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProdutosPecasMovimentos', @level2type=N'COLUMN',@level2name=N'TipoMov'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'I - infantil / A - adulto / H - hidroginástica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TurmasTipos', @level2type=N'COLUMN',@level2name=N'TipoTurma'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1, 2 ,3, ...' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TurmasTipos', @level2type=N'COLUMN',@level2name=N'Nivel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[infantil 10]
[adulto 20]
[hidroginástica 15]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TurmasTipos', @level2type=N'COLUMN',@level2name=N'LimiteAlunos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[26] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "AcessosColaboradores"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 241
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Colaboradores"
            Begin Extent = 
               Top = 4
               Left = 426
               Bottom = 325
               Right = 601
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Departamentos"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 421
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Funcoes"
            Begin Extent = 
               Top = 6
               Left = 639
               Bottom = 119
               Right = 809
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ColaboradoresHorarios"
            Begin Extent = 
               Top = 6
               Left = 847
               Bottom = 266
               Right = 1017
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 6585
         Or = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_AcessosColabInfracoesUltimos30Dias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_AcessosColabInfracoesUltimos30Dias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_AcessosColabInfracoesUltimos30Dias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[32] 4[29] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Alunos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 267
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Utentes"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 285
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Turmas"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 220
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TurmasTipos"
            Begin Extent = 
               Top = 18
               Left = 699
               Bottom = 210
               Right = 869
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Colaboradores"
            Begin Extent = 
               Top = 42
               Left = 939
               Bottom = 320
               Right = 1114
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 2025
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Alunos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Alunos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Alunos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[28] 4[33] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Colaboradores"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 322
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Funcoes"
            Begin Extent = 
               Top = 6
               Left = 251
               Bottom = 119
               Right = 421
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Departamentos"
            Begin Extent = 
               Top = 6
               Left = 459
               Bottom = 119
               Right = 634
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 4830
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_AniversariosProx7Dias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_AniversariosProx7Dias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Colaboradores"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 344
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Departamentos"
            Begin Extent = 
               Top = 5
               Left = 407
               Bottom = 131
               Right = 582
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_EstCivil"
            Begin Extent = 
               Top = 6
               Left = 672
               Bottom = 117
               Right = 842
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Funcoes"
            Begin Extent = 
               Top = 90
               Left = 884
               Bottom = 203
               Right = 1054
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_HabLiterarias"
            Begin Extent = 
               Top = 6
               Left = 1088
               Bottom = 119
               Right = 1258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Nacionalidades"
            Begin Extent = 
               Top = 154
               Left = 697
               Bottom = 267
               Right = 872
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ColaboradoresHorarios"
            Begin Extent = 
               Top = 132
               Left = 251
               Bottom = 262
               R' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Colaboradores'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'ight = 421
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 20
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3870
         Alias = 2190
         Table = 3240
         Output = 1860
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Colaboradores'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Colaboradores'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Colaboradores"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 334
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Departamentos"
            Begin Extent = 
               Top = 6
               Left = 251
               Bottom = 242
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_HabLiterarias"
            Begin Extent = 
               Top = 6
               Left = 464
               Bottom = 253
               Right = 634
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_Funcoes"
            Begin Extent = 
               Top = 6
               Left = 672
               Bottom = 220
               Right = 842
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 1035
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Professores'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Professores'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[27] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Utentes"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 324
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_EstCivil"
            Begin Extent = 
               Top = 6
               Left = 287
               Bottom = 102
               Right = 457
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 6420
         Alias = 900
         Table = 1170
         Output = 1080
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Utentes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Utentes'
GO
USE [master]
GO
ALTER DATABASE [Barcacellos] SET  READ_WRITE 
GO
