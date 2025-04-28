CREATE OR ALTER PROCEDURE sp_query_aftercare_by_date
    @TargetDate DATE
AS
BEGIN
    -- 查询 aftercare_rules 生效的当天规则
    SELECT student_name
    FROM aftercare_rules
    WHERE rule_state = 1
      AND (effective_from <= @TargetDate)
      AND (effective_to IS NULL OR effective_to >= @TargetDate)
      AND day_of_week = DATEPART(WEEKDAY, @TargetDate) - 1

    UNION

    -- 查询 aftercare_onetime 临时晚托当天
    SELECT student_name
    FROM aftercare_onetime
    WHERE rule_state = 1
      AND aftercare_date = @TargetDate;
END
