namespace backend.Requests
{
    public class AftercareDateRangeQueryRequest
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int Page { get; set; }
        public int Limit { get; set; }
        public string SortField { get; set; }
        public string SortOrder { get; set; }
    }
}
