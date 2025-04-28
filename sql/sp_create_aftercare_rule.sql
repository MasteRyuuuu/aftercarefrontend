CREATE OR ALTER PROCEDURE sp_create_aftercare_rule
    @StudentName NVARCHAR(100),
    @DayOfWeek INT,
    @EffectiveFrom DATE,
    @EffectiveTo DATE = NULL
AS
BEGIN
    INSERT INTO aftercare_rules (student_name, day_of_week, effective_from, effective_to, created_at, rule_state)
    VALUES (@StudentName, @DayOfWeek, @EffectiveFrom, @EffectiveTo, GETDATE(), 1);
END
