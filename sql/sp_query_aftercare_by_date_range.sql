CREATE OR ALTER PROCEDURE sp_query_aftercare_by_date_range
    @StartDate DATE,
    @EndDate DATE,
    @Page INT,
    @Limit INT,
    @SortField NVARCHAR(100),
    @SortOrder NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Temp table for raw data
    CREATE TABLE #AftercareResult (
        StudentName NVARCHAR(100),
        TargetDate DATE,
        DayOfWeek NVARCHAR(10),
        DayOfWeekNumber INT,
        SourceType INT,       -- 0=rules, 1=onetime
        SourceId INT,         -- rule_id or onetime_id
        PickupTimeType TINYINT
    );

    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        -- Insert fixed rules
        INSERT INTO #AftercareResult (StudentName, TargetDate, DayOfWeek, DayOfWeekNumber, SourceType, SourceId, PickupTimeType)
        SELECT 
            student_name,
            @CurrentDate,
            DATENAME(WEEKDAY, @CurrentDate),
            (DATEPART(WEEKDAY, @CurrentDate) + @@DATEFIRST - 2) % 7,
            0,  -- SourceType = 0 for rules
            rule_id,
            pickup_time_type
        FROM aftercare_rules
        WHERE rule_state = 1
          AND (effective_from <= @CurrentDate)
          AND (effective_to IS NULL OR effective_to >= @CurrentDate)
          AND day_of_week = (DATEPART(WEEKDAY, @CurrentDate) + @@DATEFIRST - 2) % 7;

        -- Insert one-time care
        INSERT INTO #AftercareResult (StudentName, TargetDate, DayOfWeek, DayOfWeekNumber, SourceType, SourceId, PickupTimeType)
        SELECT 
            student_name,
            aftercare_date,
            DATENAME(WEEKDAY, aftercare_date),
            (DATEPART(WEEKDAY, aftercare_date) + @@DATEFIRST - 2) % 7,
            1,  -- SourceType = 1 for onetime
            onetime_id,
            pickup_time_type
        FROM aftercare_onetime
        WHERE rule_state = 1
          AND aftercare_date = @CurrentDate;

        -- Move to next day
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END

    -- Mapping for sortField
    DECLARE @RealSortField NVARCHAR(100);

    IF @SortField = 'TargetDate'
        SET @RealSortField = 'TargetDate';
    ELSE IF @SortField = 'StudentName'
        SET @RealSortField = 'StudentName';
    ELSE IF @SortField = 'DayOfWeek'
        SET @RealSortField = 'DayOfWeekNumber';
    ELSE
        SET @RealSortField = 'TargetDate'; -- Default fallback

    DECLARE @OrderDirection NVARCHAR(4);
    IF @SortOrder = 'desc'
        SET @OrderDirection = 'DESC';
    ELSE
        SET @OrderDirection = 'ASC';

    -- Paginated and ordered result
    WITH OrderedData AS (
        SELECT
            StudentName,
            TargetDate,
            DayOfWeek,
            SourceType,
            SourceId,
            PickupTimeType,
            ROW_NUMBER() OVER (
                ORDER BY 
                    CASE 
                        WHEN @RealSortField = 'TargetDate' THEN CONVERT(NVARCHAR, TargetDate)
                        WHEN @RealSortField = 'StudentName' THEN StudentName
                        WHEN @RealSortField = 'DayOfWeekNumber' THEN CONVERT(NVARCHAR, DayOfWeekNumber)
                    END
                    COLLATE SQL_Latin1_General_CP1_CI_AS
                    ASC
            ) AS RowNum
        FROM #AftercareResult
    )
    SELECT 
        StudentName, 
        TargetDate, 
        DayOfWeek,
        SourceType,
        SourceId,
        PickupTimeType
    FROM OrderedData
    WHERE RowNum BETWEEN (@Page - 1) * @Limit + 1 AND @Page * @Limit
    ORDER BY RowNum;

    -- Return total count
    SELECT COUNT(*) AS TotalCount FROM #AftercareResult;

    -- Clean up
    DROP TABLE #AftercareResult;
END
