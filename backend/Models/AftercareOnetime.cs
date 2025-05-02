namespace backend.Models
{
    public class AftercareOnetime
    {
        public int OnetimeId { get; set; }
        public string StudentName { get; set; }
        public DateTime AftercareDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public int State { get; set; } = 1;  // 默认1有效
        public int PickupTimeType { get; set; } = 1;
    }
}
