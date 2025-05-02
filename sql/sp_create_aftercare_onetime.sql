CREATE OR ALTER PROCEDURE sp_create_aftercare_onetime
    @StudentName NVARCHAR(100),
    @AftercareDate DATE,
    @PickupTimeType TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DayOfWeek INT = (DATEPART(WEEKDAY, @AftercareDate) + @@DATEFIRST - 2) % 7;

    -- 🔍 冲突检查：固定规则冲突
    IF EXISTS (
        SELECT 1
        FROM aftercare_rules
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND day_of_week = @DayOfWeek
          AND (effective_from <= @AftercareDate)
          AND (effective_to IS NULL OR effective_to >= @AftercareDate)
          AND pickup_time_type <> @PickupTimeType
    )
    BEGIN
        RAISERROR('Conflict with existing fixed aftercare rule.', 16, 1);
        RETURN;
    END

    -- 🔍 冲突检查：临时记录冲突
    IF EXISTS (
        SELECT 1
        FROM aftercare_onetime
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND aftercare_date = @AftercareDate
          AND pickup_time_type <> @PickupTimeType
    )
    BEGIN
        RAISERROR('Conflict with existing one-time aftercare.', 16, 1);
        RETURN;
    END

    -- ✅ 插入数据
    INSERT INTO aftercare_onetime (
        student_name, aftercare_date, created_at, rule_state, pickup_time_type
    )
    VALUES (
        @StudentName, @AftercareDate, GETDATE(), 1, @PickupTimeType
    );
END
