USE [MEetAndYou-DB]
GO
/****** Object:  UserDefinedFunction [MEetAndYou].[GetEvent]    Script Date: 3/6/2022 9:06:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [MEetAndYou].[GetEvent](@eventID int)
RETURNS TABLE 
AS
RETURN
(
	SELECT * from MEetAndYou.Event 
	WHERE MEetAndYou.Event.eventID = @eventID

);
