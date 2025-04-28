CREATE OR ALTER PROCEDURE sp_create_aftercare_onetime
    @StudentName NVARCHAR(100),
    @AftercareDate DATE
AS
BEGIN
    INSERT INTO aftercare_onetime (student_name, aftercare_date, created_at, rule_state)
    VALUES (@StudentName, @AftercareDate, GETDATE(), 1);
END
