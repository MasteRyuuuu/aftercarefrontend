-- 插入固定规则
INSERT INTO aftercare_rules (student_name, day_of_week, effective_from, rule_state)
VALUES 
('xiaoming', 1, '2025-04-01',1),  -- 每周一
('xiaoming', 3, '2025-04-01',1),  -- 每周三
('xiaoming', 5, '2025-04-01',1);  -- 每周五

-- 插入临时加晚托
INSERT INTO aftercare_onetime (student_name, aftercare_date,  rule_state)
VALUES 
('xiaohong', '2025-05-10',1);  -- 5月10日临时晚托
