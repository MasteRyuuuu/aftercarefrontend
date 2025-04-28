DECLARE @Today DATE = CAST(GETDATE() AS DATE);
DECLARE @TodayWeekday INT = DATEPART(WEEKDAY, @Today) - 1; -- 注意SQL Server默认周日是1，所以-1修正到0开始

-- 查询固定每周晚托
SELECT student_name
FROM aftercare_rules
WHERE 
    day_of_week = @TodayWeekday
    AND effective_from <= @Today
    AND (effective_to IS NULL OR effective_to >= @Today)

UNION

-- 查询临时加晚托
SELECT student_name
FROM aftercare_onetime
WHERE aftercare_date = @Today;
