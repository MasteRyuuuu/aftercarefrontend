using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using backend.Requests;
using System.Data;

namespace backend.Controllers
{
    [ApiController]
    [Route("api/aftercare_query")]
    public class AftercareQueryController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public AftercareQueryController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("DefaultConnection");
        }

        [HttpPost("by-date")]
        /* public async Task<IActionResult> QueryByDate([FromBody] AftercareDateQueryRequest request)
        {
            using var connection = new SqlConnection(_connectionString);

            var parameters = new DynamicParameters();
            parameters.Add("TargetDate", request.Date);

            var result = await connection.QueryAsync<string>(
                "sp_query_aftercare_by_date",
                parameters,
                commandType: CommandType.StoredProcedure);

            return Ok(result);
        }
 */
        [HttpPost("by-range")]
        public async Task<IActionResult> QueryByDateRange([FromBody] AftercareDateRangeQueryRequest request)
        {
            using var connection = new SqlConnection(_connectionString);

            var parameters = new DynamicParameters();
            parameters.Add("StartDate", request.StartDate);
            parameters.Add("EndDate", request.EndDate);
            parameters.Add("Page", request.Page);
            parameters.Add("Limit", request.Limit);
            parameters.Add("SortField", request.SortField);
            parameters.Add("SortOrder", request.SortOrder);

            using var multi = await connection.QueryMultipleAsync(
                "sp_query_aftercare_by_date_range",
                parameters,
                commandType: CommandType.StoredProcedure);

            var records = (await multi.ReadAsync<dynamic>()).ToList();
            var total = await multi.ReadFirstAsync<int>();

            return Ok(new {
                totalRecords = total,
                students = records
            });
        }
    }
}
