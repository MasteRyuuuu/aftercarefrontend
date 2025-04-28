CREATE OR ALTER PROCEDURE sp_soft_delete_aftercare_rule
    @RuleId INT
AS
BEGIN
    UPDATE aftercare_rules
    SET rule_state = 0
    WHERE rule_id = @RuleId AND rule_state = 1;
END
