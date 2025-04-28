using System;

namespace backend.Models
{
    public class AftercareRule
    {
        public int RuleId { get; set; }
        public string StudentName { get; set; }
        public int DayOfWeek { get; set; }
        public DateTime EffectiveFrom { get; set; }
        public DateTime? EffectiveTo { get; set; }
        public DateTime CreatedAt { get; set; }
        public int State { get; set; } = 1;  // 默认有效
    }
}
