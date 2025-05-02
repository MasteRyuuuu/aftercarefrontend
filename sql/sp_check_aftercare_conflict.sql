CREATE OR ALTER PROCEDURE sp_check_aftercare_conflict
    @StudentName NVARCHAR(100),
    @TargetDate DATE,
    @PickupTimeType TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DayOfWeek INT = (DATEPART(WEEKDAY, @TargetDate) + @@DATEFIRST - 2) % 7;

    -- 检查 aftercare_rules 中是否有相同学生、同一星期几、但 pickup_time_type 不同的记录
    IF EXISTS (
        SELECT 1
        FROM aftercare_rules
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND day_of_week = @DayOfWeek
          AND (effective_from <= @TargetDate)
          AND (effective_to IS NULL OR effective_to >= @TargetDate)
          AND pickup_time_type <> @PickupTimeType
    )
    BEGIN
        RAISERROR('Conflicting fixed aftercare rule found.', 16, 1);
        RETURN;
    END

    -- 检查 aftercare_onetime 中是否有相同学生、同一天、但 pickup_time_type 不同的记录
    IF EXISTS (
        SELECT 1
        FROM aftercare_onetime
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND aftercare_date = @TargetDate
          AND pickup_time_type <> @PickupTimeType
    )
    BEGIN
        RAISERROR('Conflicting one-time aftercare found.', 16, 1);
        RETURN;
    END
END
