CREATE OR ALTER PROCEDURE sp_soft_delete_aftercare_onetime
    @OnetimeId INT
AS
BEGIN
    UPDATE aftercare_onetime
    SET rule_state = 0
    WHERE onetime_id = @OnetimeId AND rule_state = 1;
END
