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
        DayOfWeekNumber INT
    );

    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO #AftercareResult (StudentName, TargetDate, DayOfWeek, DayOfWeekNumber)
        SELECT student_name,
               @CurrentDate,
               DATENAME(WEEKDAY, @CurrentDate),
               (DATEPART(WEEKDAY, @CurrentDate) + @@DATEFIRST - 2) % 7
        FROM aftercare_rules
        WHERE rule_state = 1
          AND (effective_from <= @CurrentDate)
          AND (effective_to IS NULL OR effective_to >= @CurrentDate)
          AND day_of_week = (DATEPART(WEEKDAY, @CurrentDate) + @@DATEFIRST - 2) % 7;

        INSERT INTO #AftercareResult (StudentName, TargetDate, DayOfWeek, DayOfWeekNumber)
        SELECT student_name,
               aftercare_date,
               DATENAME(WEEKDAY, aftercare_date),
               (DATEPART(WEEKDAY, aftercare_date) + @@DATEFIRST - 2) % 7
        FROM aftercare_onetime
        WHERE rule_state = 1
          AND aftercare_date = @CurrentDate;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END

    -- Safe mapping of sortField
    DECLARE @RealSortField NVARCHAR(100);

    IF @SortField = 'TargetDate'
        SET @RealSortField = 'TargetDate';
    ELSE IF @SortField = 'StudentName'
        SET @RealSortField = 'StudentName';
    ELSE IF @SortField = 'DayOfWeek'
        SET @RealSortField = 'DayOfWeekNumber';  -- Internal switch
    ELSE
        SET @RealSortField = 'TargetDate'; -- Default

    DECLARE @OrderDirection NVARCHAR(4);
    IF @SortOrder = 'desc'
        SET @OrderDirection = 'DESC';
    ELSE
        SET @OrderDirection = 'ASC';

    -- Use ROW_NUMBER() for pagination
    WITH OrderedData AS (
        SELECT
            StudentName,
            TargetDate,
            DayOfWeek,
            ROW_NUMBER() OVER (ORDER BY 
                CASE WHEN @OrderDirection = 'ASC' THEN
                    CASE @RealSortField
                        WHEN 'TargetDate' THEN CAST(TargetDate AS NVARCHAR)
                        WHEN 'StudentName' THEN StudentName
                        WHEN 'DayOfWeekNumber' THEN CAST(DayOfWeekNumber AS NVARCHAR)
                    END
                END ASC,
                CASE WHEN @OrderDirection = 'DESC' THEN
                    CASE @RealSortField
                        WHEN 'TargetDate' THEN CAST(TargetDate AS NVARCHAR)
                        WHEN 'StudentName' THEN StudentName
                        WHEN 'DayOfWeekNumber' THEN CAST(DayOfWeekNumber AS NVARCHAR)
                    END
                END DESC
            ) AS RowNum
        FROM #AftercareResult
    )
    SELECT StudentName, TargetDate, DayOfWeek
    FROM OrderedData
    WHERE RowNum BETWEEN (@Page - 1) * @Limit + 1 AND @Page * @Limit
    ORDER BY RowNum;

    -- Return total count separately
    SELECT COUNT(*) AS TotalCount FROM #AftercareResult;

    DROP TABLE #AftercareResult;
END
