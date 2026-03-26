namespace PRM_Backend_Server.ViewModels.Pagination
{
    public class PaginationResponse <T>
    {
        public int TotalItems { get; set; }
        public int TotalPages { get; set; }
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
        public List<T> Items { get; set; }
        public PaginationResponse()
        {
            Items = new List<T>();
        }
    }
}
