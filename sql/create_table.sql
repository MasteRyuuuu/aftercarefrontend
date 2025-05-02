-- 删除表如果已存在
IF OBJECT_ID('aftercare_rules', 'U') IS NOT NULL
    DROP TABLE aftercare_rules;

-- 创建表
CREATE TABLE aftercare_rules (
    rule_id INT IDENTITY(1,1) PRIMARY KEY,          -- 自增主键
    student_name NVARCHAR(100) NOT NULL,            -- 学生名字
    day_of_week INT NOT NULL,                       -- 星期几 (0=周日, 1=周一, ..., 6=周六)
    effective_from DATE NOT NULL,                   -- 生效起始日
    effective_to DATE NULL,                         -- 生效结束日（NULL代表永久）
    created_at DATETIME DEFAULT GETDATE(),          -- 创建时间
    pickup_time_type TINYINT NOT NULL DEFAULT 1,    -- 结束时间 (1=5:00 2=5:30)
    rule_state INT NOT NULL                         -- 规则状态 (0=未生效, 1=生效, 2=已过期)
);

-- 删除表如果已存在
IF OBJECT_ID('aftercare_onetime', 'U') IS NOT NULL
    DROP TABLE aftercare_onetime;

-- 创建表
CREATE TABLE aftercare_onetime (
    onetime_id INT IDENTITY(1,1) PRIMARY KEY,       -- 自增主键
    student_name NVARCHAR(100) NOT NULL,            -- 学生名字
    aftercare_date DATE NOT NULL,                   -- 哪一天需要晚托
    created_at DATETIME DEFAULT GETDATE(),          -- 创建时间
    pickup_time_type TINYINT NOT NULL DEFAULT 1,    -- 结束时间 (1=5:00 2=5:30)
    rule_state INT NOT NULL                         -- 规则状态 (0=未生效, 1=生效, 2=已过期) 
);

CREATE TABLE aftercare_pickup_time_map (
  type_id TINYINT PRIMARY KEY,
  time_value VARCHAR(10) NOT NULL
);

INSERT INTO aftercare_pickup_time_map (type_id, time_value)
VALUES (1, '17:00'), (2, '17:30');
