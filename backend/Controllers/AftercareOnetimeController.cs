using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using backend.Models;
using System.Data;

namespace backend.Controllers
{
[ApiController]
[Route("api/aftercare_onetime")]
public class AftercareOnetimeController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;

    public AftercareOnetimeController(IConfiguration configuration)
    {
        _configuration = configuration;
        _connectionString = _configuration.GetConnectionString("DefaultConnection");
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AftercareOnetime onetime)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync(
            "sp_create_aftercare_onetime",
            new { onetime.StudentName, onetime.AftercareDate },
            commandType: CommandType.StoredProcedure);
        return Ok();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> SoftDelete(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        var rows = await connection.ExecuteAsync(
            "sp_soft_delete_aftercare_onetime",
            new { OnetimeId = id },
            commandType: CommandType.StoredProcedure);
        return rows > 0 ? Ok() : NotFound();
    }
}

}
