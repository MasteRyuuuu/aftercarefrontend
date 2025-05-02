CREATE OR ALTER PROCEDURE sp_create_aftercare_rule
    @StudentName NVARCHAR(100),
    @DayOfWeek INT,
    @EffectiveFrom DATE,
    @EffectiveTo DATE = NULL,
    @PickupTimeType TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- 🔍 冲突检查：是否已有同日不同时间档的 rule
    IF EXISTS (
        SELECT 1
        FROM aftercare_rules
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND day_of_week = @DayOfWeek
          AND pickup_time_type <> @PickupTimeType
          AND (
            -- 时间段有交集
            (@EffectiveFrom <= ISNULL(effective_to, '9999-12-31')) AND
            (ISNULL(@EffectiveTo, '9999-12-31') >= effective_from)
          )
    )
    BEGIN
        RAISERROR('Conflict with another fixed rule of different time slot.', 16, 1);
        RETURN;
    END

    -- 🔍 冲突检查：是否与已有 onetime 冲突
    IF EXISTS (
        SELECT 1
        FROM aftercare_onetime
        WHERE student_name = @StudentName
          AND rule_state = 1
          AND (DATEPART(WEEKDAY, aftercare_date) + @@DATEFIRST - 2) % 7 = @DayOfWeek
          AND pickup_time_type <> @PickupTimeType
          AND aftercare_date BETWEEN @EffectiveFrom AND ISNULL(@EffectiveTo, '9999-12-31')
    )
    BEGIN
        RAISERROR('Conflict with one-time aftercare on same weekday.', 16, 1);
        RETURN;
    END

    -- ✅ 插入数据
    INSERT INTO aftercare_rules (
        student_name, day_of_week, effective_from, effective_to, created_at, rule_state, pickup_time_type
    )
    VALUES (
        @StudentName, @DayOfWeek, @EffectiveFrom, @EffectiveTo, GETDATE(), 1, @PickupTimeType
    );
END
