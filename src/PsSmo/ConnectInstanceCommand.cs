
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;
using System.Management.Automation;
using System.Data.SqlClient;
using Microsoft.Azure.Services.AppAuthentication;
using System.Security;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Connect, "Instance")]
    [OutputType(typeof(Server))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        internal static Server Instance { get; set; }

        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true,
            ParameterSetName = "SqlClient"
        )]
        public SqlConnection Connection { get; set; }

        [Parameter(
            ParameterSetName = "ConnectionString",
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Server", "ServerName", "ServerInstance")]
        public string DataSource { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Database", "DatabaseName")]
        public string InitialCatalog { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }

        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId { get; set; }

        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SecureString Password { get; set; }

        protected override void ProcessRecord()
        {

            switch (ParameterSetName)
            {
                case "SqlClient":
                    WriteVerbose("Connect by existing connection");
                    Instance = new Server(
                        serverConnection: new ServerConnection(
                            sqlConnection: Connection
                        )
                    );
                    break;

                    case "ConnectionString":
                    {
                        WriteVerbose("Connect by connection string");
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                        builder.ConnectionString = ConnectionString;
                        Connection = new SqlConnection(connectionString: builder.ConnectionString);
                        Instance = new Server(
                            serverConnection: new ServerConnection(
                                sqlConnection: Connection
                            )
                        );
                        break;
                    }

                    case "Properties_IntegratedSecurity":
                    {
                        WriteVerbose("Connect by Integrated Security");
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                        builder.DataSource = DataSource;
                        if (InitialCatalog != null)
                            builder.InitialCatalog = InitialCatalog;
                        if (DataSource.EndsWith("database.windows.net"))
                        {
                            Connection = new SqlConnection(connectionString: builder.ConnectionString);
                            if (AccessToken == null)
                                AccessToken = new AzureServiceTokenProvider().GetAccessTokenAsync("https://database.windows.net").Result;
                            Connection.AccessToken = AccessToken;
                        }
                        else
                        {
                            builder.IntegratedSecurity = true;
                            Connection = new SqlConnection(connectionString: builder.ConnectionString);
                        }
                        Instance = new Server(
                            serverConnection: new ServerConnection(
                                sqlConnection: Connection
                            )
                        );
                        break;
                    }

                    case "Properties_SQLServerAuthentication":
                    {
                        WriteVerbose("Connect by SQL Server Authentication");
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                        Password.MakeReadOnly();
                        builder.DataSource = DataSource;
                        if (InitialCatalog != null)
                            builder.InitialCatalog = InitialCatalog;
                        Connection = new SqlConnection(
                            connectionString: builder.ConnectionString,
                            credential: new SqlCredential(userId: UserId, password: Password)
                        );
                        Instance = new Server(
                            serverConnection: new ServerConnection(
                                sqlConnection: Connection
                            )
                        );
                        break;
                    }

                default:
                    Instance = new Server();
                    break;
            }
            WriteObject(Instance);
        }

    }
}
