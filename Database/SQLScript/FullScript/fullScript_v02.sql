USE [MEetAndYou-DB]
GO
/****** Object:  User [MEetAndYouDBUser]    Script Date: 4/10/2022 2:35:34 PM ******/
CREATE USER [MEetAndYouDBUser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[MEetAndYou]
GO
/****** Object:  User [MEetYouReadUserLogin]    Script Date: 4/10/2022 2:35:34 PM ******/
CREATE USER [MEetYouReadUserLogin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [MEetYouWriteUserLogin]    Script Date: 4/10/2022 2:35:34 PM ******/
CREATE USER [MEetYouWriteUserLogin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [MEetAndYouDBUser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [MEetAndYouDBUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [MEetYouReadUserLogin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [MEetYouWriteUserLogin]
GO
/****** Object:  Schema [MEetAndYou]    Script Date: 4/10/2022 2:35:34 PM ******/
CREATE SCHEMA [MEetAndYou]
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[CheckExistingLog]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[CheckExistingLog]
(
    -- Add the parameters for the function here
    @logId int
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @rowCount INT;

    -- Add the T-SQL statements to compute the return value here
    SET @rowCount = (SELECT COUNT(LogId) FROM [MEetAndYou].[EventLogs] WHERE @logId = EventLogs.LogId);

    -- Return the result of the function
    RETURN @rowCount
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetArchiveCount]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[GetArchiveCount] 
(

)
RETURNS int 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @logArchiveCount int;

    -- Add the T-SQL statements to compute the return value here
    SET @logArchiveCount = (SELECT COUNT(*) FROM EventLogs WHERE DATEDIFF(day, DateTime, GETDATE()) >= 30)

    -- Return the result of the function
    RETURN @logArchiveCount;

END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetCurrentIdentity]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[GetCurrentIdentity]
(

)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @lastId INT;

	SET @lastId = (SELECT IDENT_CURRENT('MEetAndYou.EventLogs'));

	-- Return the result of the function
	RETURN @lastId
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetUserID]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[GetUserID]
(
    @email VARCHAR(30)
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @uId INT;

    SET @uId = (SELECT [UserID] FROM [MEetAndYou].[UserAccountRecords]
                WHERE [UserEmail] = @email);

    -- Return the result of the function
    RETURN @uId
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[ValidateCredentialsInDB]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[ValidateCredentialsInDB] (
    @email VARCHAR(30),
    @password VARCHAR(15)
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT
    DECLARE @salt uniqueidentifier

    SELECT @salt = [Salt] FROM [MEetAndYou].[UserAccountRecords]
    WHERE [UserEmail] = @email

    SELECT @result = COUNT([UserID]) FROM [MEetAndYou].[UserAccountRecords] 
    WHERE [UserEmail] = @email
    AND [UserPassword] = HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36)))
    return @result
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[VerifyAdminRecordInDB]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[VerifyAdminRecordInDB] (
    @email VARCHAR(30),
    @password VARCHAR(15)
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT
    DECLARE @salt uniqueidentifier

    SELECT @salt = [Salt] FROM [MEetAndYou].[AdminAccountRecords]
    WHERE [AdminEmail] = @email

    SELECT @result = COUNT([AdminID]) FROM [MEetAndYou].[AdminAccountRecords] 
    WHERE [AdminEmail] = @email
    AND [AdminPassword] = HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36)))
    return @result
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[VerifyUserRecordInDB]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[VerifyUserRecordInDB] (
    @id INT,
    @email VARCHAR(30),
    @password VARCHAR(15), 
    @phoneNum VARCHAR(15), 
    @registerDate DateTime, 
    @active BIT
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT
    DECLARE @salt uniqueidentifier

    SELECT @salt = [Salt] FROM [MEetAndYou].[UserAccountRecords]
    WHERE [UserId] = @id

    SELECT @result = COUNT([UserID]) FROM [MEetAndYou].[UserAccountRecords] 
    WHERE [UserID] = @id
    AND [UserEmail] = @email
    AND [UserPassword] = HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36)))
    AND [UserPhoneNum] = @phoneNum
    AND [UserRegisterDate] = @registerDate
    AND [Active] = @active
    return @result
END
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[VerifyUserToken]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MEetAndYou].[VerifyUserToken]
(
    @userID INT,
    @token VARCHAR(25)
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @uId INT;

    DECLARE @salt nvarchar(64)
    SELECT @salt = [Salt] FROM [MEetAndYou].[UserAccountRecords]
    WHERE [UserId] = @userID

    DECLARE @hashedToken nvarchar(64)
    SELECT @hashedToken = HASHBYTES('SHA2_512', @token+@salt)

    SET @uId = (SELECT [UserID] FROM [MEetAndYou].[UserToken]
                WHERE [token] = @hashedToken);

    -- Return the result of the function
    RETURN @uId
END
GO
/****** Object:  Table [MEetAndYou].[EventLogs]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[EventLogs](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[Category] [varchar](15) NOT NULL,
	[LogLevel] [varchar](15) NOT NULL,
	[UserId] [int] NOT NULL,
	[Message] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[Logs30DaysOld]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date,,>
-- Description:    <Description,,>
-- =============================================
CREATE FUNCTION [MEetAndYou].[Logs30DaysOld]
(    
    -- Add the parameters for the function here

)
RETURNS TABLE 
AS
RETURN 
(
    -- Add the SELECT statement with parameter references here
    SELECT  * FROM EventLogs WHERE DATEDIFF(day, DateTime, GETDATE()) >= 30
)
GO
/****** Object:  Table [MEetAndYou].[EventCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[EventCategory](
	[eventID] [int] NOT NULL,
	[categoryName] [varchar](50) NOT NULL,
 CONSTRAINT [eventCategory_pk] PRIMARY KEY CLUSTERED 
(
	[eventID] ASC,
	[categoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetEventCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Return the category of a specific event

CREATE FUNCTION [MEetAndYou].[GetEventCategory] (@eventID int) 
RETURNS TABLE 
AS 
RETURN 
(
	SELECT * FROM MEetAndYou.EventCategory 
	WHERE EventCategory.eventID = @eventID
)
GO
/****** Object:  Table [MEetAndYou].[Events]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[Events](
	[eventID] [int] IDENTITY(1,1) NOT NULL,
	[eventName] [varchar](35) NULL,
	[description] [varchar](350) NULL,
	[address] [varchar](50) NULL,
	[price] [float] NULL,
	[eventDate] [datetime] NULL,
 CONSTRAINT [event_pk] PRIMARY KEY CLUSTERED 
(
	[eventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetEvent]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [MEetAndYou].[GetEvent] (@eventID int)
RETURNS TABLE 
AS
RETURN
(
	SELECT * from MEetAndYou.Events 
	WHERE MEetAndYou.Events.eventID = @eventID
);
GO
/****** Object:  Table [MEetAndYou].[AdminAccountRecords]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[AdminAccountRecords](
	[AdminID] [int] IDENTITY(1,1) NOT NULL,
	[AdminEmail] [varchar](30) NOT NULL,
	[AdminPassword] [binary](64) NOT NULL,
	[Salt] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[Category]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[Category](
	[categoryName] [varchar](50) NOT NULL,
 CONSTRAINT [category_pk] PRIMARY KEY CLUSTERED 
(
	[categoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[Itinerary]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[Itinerary](
	[itineraryID] [int] IDENTITY(1,1) NOT NULL,
	[itineraryName] [varchar](35) NOT NULL,
	[rating] [int] NOT NULL,
	[itineraryOwner] [int] NOT NULL,
 CONSTRAINT [itinerary_PK] PRIMARY KEY CLUSTERED 
(
	[itineraryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[Roles]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[Roles](
	[role] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[role] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[UserAccountRecords]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[UserAccountRecords](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](30) NULL,
	[UserPassword] [binary](64) NOT NULL,
	[UserPhoneNum] [varchar](15) NOT NULL,
	[UserRegisterDate] [varchar](30) NOT NULL,
	[Active] [bit] NOT NULL,
	[Salt] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[UserItinerary]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[UserItinerary](
	[itineraryID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [userItinerary_pk] PRIMARY KEY CLUSTERED 
(
	[itineraryID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[UserRole]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[UserRole](
	[UserID] [int] NOT NULL,
	[role] [varchar](50) NOT NULL,
 CONSTRAINT [user_rolePK] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[role] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MEetAndYou].[UserToken]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MEetAndYou].[UserToken](
	[UserID] [int] NOT NULL,
	[token] [binary](64) NOT NULL,
	[salt] [uniqueidentifier] NULL,
	[dateCreated] [varchar](30) NOT NULL,
 CONSTRAINT [userRole_PK] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [MEetAndYou].[EventCategory]  WITH CHECK ADD  CONSTRAINT [category_fk] FOREIGN KEY([categoryName])
REFERENCES [MEetAndYou].[Category] ([categoryName])
GO
ALTER TABLE [MEetAndYou].[EventCategory] CHECK CONSTRAINT [category_fk]
GO
ALTER TABLE [MEetAndYou].[EventCategory]  WITH CHECK ADD  CONSTRAINT [eventID_fk] FOREIGN KEY([eventID])
REFERENCES [MEetAndYou].[Events] ([eventID])
GO
ALTER TABLE [MEetAndYou].[EventCategory] CHECK CONSTRAINT [eventID_fk]
GO
ALTER TABLE [MEetAndYou].[Itinerary]  WITH CHECK ADD  CONSTRAINT [itinOwner_fk] FOREIGN KEY([itineraryOwner])
REFERENCES [MEetAndYou].[UserAccountRecords] ([UserID])
GO
ALTER TABLE [MEetAndYou].[Itinerary] CHECK CONSTRAINT [itinOwner_fk]
GO
ALTER TABLE [MEetAndYou].[UserItinerary]  WITH CHECK ADD  CONSTRAINT [itineraryID_fk] FOREIGN KEY([itineraryID])
REFERENCES [MEetAndYou].[Itinerary] ([itineraryID])
GO
ALTER TABLE [MEetAndYou].[UserItinerary] CHECK CONSTRAINT [itineraryID_fk]
GO
ALTER TABLE [MEetAndYou].[UserItinerary]  WITH CHECK ADD  CONSTRAINT [userIDitinerary_fk] FOREIGN KEY([UserID])
REFERENCES [MEetAndYou].[UserAccountRecords] ([UserID])
GO
ALTER TABLE [MEetAndYou].[UserItinerary] CHECK CONSTRAINT [userIDitinerary_fk]
GO
ALTER TABLE [MEetAndYou].[UserRole]  WITH CHECK ADD FOREIGN KEY([role])
REFERENCES [MEetAndYou].[Roles] ([role])
GO
ALTER TABLE [MEetAndYou].[UserRole]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [MEetAndYou].[UserAccountRecords] ([UserID])
GO
ALTER TABLE [MEetAndYou].[UserToken]  WITH CHECK ADD  CONSTRAINT [userID_fk] FOREIGN KEY([UserID])
REFERENCES [MEetAndYou].[UserAccountRecords] ([UserID])
GO
ALTER TABLE [MEetAndYou].[UserToken] CHECK CONSTRAINT [userID_fk]
GO
/****** Object:  StoredProcedure [MEetAndYou].[ArchiveDelete]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date,,>
-- Description:    <Description,,>
-- =============================================
CREATE PROCEDURE [MEetAndYou].[ArchiveDelete]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DELETE FROM EventLogs WHERE DATEDIFF(day, DateTime, GETDATE()) >= 30;
END
GO
/****** Object:  StoredProcedure [MEetAndYou].[CreateAdminAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[CreateAdminAccountRecord]
    -- Add the parameters for the stored procedure here
    @email VARCHAR(30),
    @password VARCHAR(15)
AS
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    -- Insert statements for procedure here
    INSERT INTO [MEetAndYou].[AdminAccountRecords] ([AdminEmail], [AdminPassword], [Salt])
    VALUES (@email,
            HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36))),
            @salt)
GO
/****** Object:  StoredProcedure [MEetAndYou].[CreateCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[CreateCategory]
    @categoryName varchar(50)    
AS   
	INSERT INTO MEetAndYou.Category (categoryName) values
		(@categoryName)

GO
/****** Object:  StoredProcedure [MEetAndYou].[CreateEvent]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[CreateEvent]
    @eventName varchar(35), 
	@eventDescription varchar(350),
	@eventAddress varchar (50), 
	@price float, 
	@eventDate DATETIME

AS   
	INSERT INTO MEetAndYou.Events (eventName, description, address, price, eventDate) values
		(@eventName, @eventDescription, @eventAddress, @price, @eventDate)

GO
/****** Object:  StoredProcedure [MEetAndYou].[CreateEventCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[CreateEventCategory]
    @eventID int, 
	@categoryName varchar(50)

AS   
	INSERT INTO MEetAndYou.EventCategory(eventID, categoryName) values
		(@eventID, @categoryName)

GO
/****** Object:  StoredProcedure [MEetAndYou].[CreateUserAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[CreateUserAccountRecord]
    -- Add the parameters for the stored procedure here
    @email VARCHAR(30),
    @password VARCHAR(15),
    @phoneNum VARCHAR(15),
    @registerDate VARCHAR(30),
    @active BIT
AS
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    -- Insert statements for procedure here
    INSERT INTO [MEetAndYou].[UserAccountRecords] ([UserEmail], [UserPassword], [UserPhoneNum], [UserRegisterDate], [Active], [Salt])
    VALUES (@email,
            HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36))),
            @phoneNum,
            @registerDate,
            @active,
            @salt)
GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteAdminAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteAdminAccountRecord]
    -- Add the parameters for the stored procedure here
    @id INT
AS
    -- Delete statements for procedure here
    DELETE FROM [MEetAndYou].[AdminAccountRecords]
    WHERE [AdminID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteCategory]
    @categoryName varchar(50)    
AS   
	DELETE FROM MEetAndYou.Category where categoryName = @categoryName

GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteEvent]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteEvent]
    @eventID int   
AS   
	DELETE FROM MEetAndYou.Events where eventID = @eventID

GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteEventCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteEventCategory]
    @eventID int,
	@categoryName varchar(50)
AS   
	DELETE FROM MEetAndYou.EventCategory where eventID = @eventID and categoryName = @categoryName

GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteUserAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteUserAccountRecord]
    -- Add the parameters for the stored procedure here
    @id INT
AS
    -- Delete statements for procedure here
    DELETE FROM [MEetAndYou].[UserAccountRecords]
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[DeleteUserFromUserRoles]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DeleteUserFromUserRoles]
    -- Add the parameters for the stored procedure here
    @id INT
AS
    -- Delete statements for procedure here
    DELETE FROM [MEetAndYou].[UserRole]
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[DisableUserAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[DisableUserAccountRecord]
    -- Add the parameters for the stored procedure here
    @id INT
AS
    -- Update statements for procedure here
    UPDATE [MEetAndYou].[UserAccountRecords] 
    SET [Active] = 0
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[EnableUserAccountRecord]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[EnableUserAccountRecord]
    -- Add the parameters for the stored procedure here
    @id INT
AS
    -- Update statements for procedure here
    UPDATE [MEetAndYou].[UserAccountRecords] 
    SET [Active] = 1
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[InsertLog]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[InsertLog]
	-- Add the parameters for the stored procedure here
	@dateTime datetime,
	@category varchar(15),
	@logLevel varchar(15),
	@userId int,
	@message varchar(255)
AS
    -- Insert statements for procedure here
	INSERT INTO [MEetAndYou].[EventLogs] ([DateTime], [Category], [LogLevel], [UserId], [Message])
	VALUES (@dateTime, @category, @logLevel, @userId, @message)
GO
/****** Object:  StoredProcedure [MEetAndYou].[StoreUserToken]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[StoreUserToken]
    -- Add the parameters for the stored procedure here
    @userID VARCHAR(30),
    @token VARCHAR(25),
    @dateCreated VARCHAR(30)
AS
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    -- Insert statements for procedure here
    INSERT INTO [MEetAndYou].[UserToken] ([UserID], [token], [salt], [dateCreated])
    VALUES (@userID,
            HASHBYTES('SHA2_512', @token+CAST(@salt AS nvarchar(64))),
            @salt,
            @dateCreated)
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateAdminAccountEmail]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateAdminAccountEmail]
    -- Add the parameters for the stored procedure here
    @id INT,
    @email VARCHAR(30)
AS
    -- Update statements for procedure here
    UPDATE [MEetAndYou].[AdminAccountRecords] 
    SET [AdminEmail] = @email
    WHERE [AdminID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateAdminAccountPassword]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateAdminAccountPassword]
    -- Add the parameters for the stored procedure here
    @id INT,
    @password VARCHAR(15)
AS
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    -- Update statements for procedure here
    UPDATE [MEetAndYou].[AdminAccountRecords] 
    SET 
    [AdminPassword] = HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36))),
    [Salt] = @salt
    WHERE [AdminID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateCategory]
    @oldcategoryName varchar(50),
	@newcategoryName varchar(50) 
AS   
	UPDATE MEetAndYou.Category 
	SET categoryName = @newcategoryName
	where categoryName = @oldcategoryName

GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventAddress]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventAddress]
	@eventID int,
    @eventAddress varchar(50)

AS   
	UPDATE MEetAndYou.Events
	SET address = @eventAddress
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventCategory]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventCategory]
    @eventID int, 
	@categoryName varchar(50)

AS   
	UPDATE MEetAndYou.EventCategory
	SET categoryName = @categoryName
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventDate]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventDate]
	@eventID int,
    @eventDate datetime

AS   
	UPDATE MEetAndYou.Events
	SET eventDate = @eventDate
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventDescription]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventDescription]
	@eventID int,
    @eventDescription varchar(350)

AS   
	UPDATE MEetAndYou.Events
	SET description = @eventDescription
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventName]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventName]
	@eventID int,
    @neweventName varchar(35)

AS   
	UPDATE MEetAndYou.Events
	SET eventName = @neweventName
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateEventPrice]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [MEetAndYou].[UpdateEventPrice]
	@eventID int,
    @eventPrice float

AS   
	UPDATE MEetAndYou.Events
	SET price = @eventPrice
	where eventID = @eventID
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateLog]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date,,>
-- Description:    <Description,,>
-- =============================================
CREATE PROCEDURE [MEetAndYou].[UpdateLog]
(
    @logId int
)
AS
BEGIN
    UPDATE MEetAndYou.EventLogs
    SET DateTime = GETUTCDATE()
    WHERE LogId = @logId
END
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateUserAccountEmail]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateUserAccountEmail]
    -- Add the parameters for the stored procedure here
    @id INT,
    @email VARCHAR(30)
AS
    -- Update statements for procedure here
    UPDATE [MEetAndYou].[UserAccountRecords] 
    SET [UserEmail] = @email
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateUserAccountPassword]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateUserAccountPassword]
    -- Add the parameters for the stored procedure here
    @id INT,
    @password VARCHAR(15)
AS
    DECLARE @salt UNIQUEIDENTIFIER = NEWID()

    -- Update statements for procedure here
    UPDATE [MEetAndYou].[UserAccountRecords] 
    SET 
    [UserPassword] = HASHBYTES('SHA2_512', @password+CAST(@salt AS nvarchar(36))),
    [Salt] = @salt
    WHERE [UserID] = @id
GO
/****** Object:  StoredProcedure [MEetAndYou].[UpdateUserAccountPhoneNum]    Script Date: 4/10/2022 2:35:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MEetAndYou].[UpdateUserAccountPhoneNum]
    -- Add the parameters for the stored procedure here
    @id INT,
    @phoneNum VARCHAR(15)
AS
    -- Update statements for procedure here
    UPDATE [MEetAndYou].[UserAccountRecords] 
    SET [UserPhoneNum] = @phoneNum
    WHERE [UserID] = @id
GO
