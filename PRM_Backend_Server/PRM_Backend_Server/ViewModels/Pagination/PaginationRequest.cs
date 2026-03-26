namespace PRM_Backend_Server.ViewModels.Pagination
{
    public class PaginationRequest
    {
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string SortBy { get; set; } = "default";
        public int SortOrder { get; set; }= 1; // 1 for ascending, -1 for descending
        public string? SearchTerm { get; set; }
        public string FilterBy { get; set; } = "default";
    }
}
