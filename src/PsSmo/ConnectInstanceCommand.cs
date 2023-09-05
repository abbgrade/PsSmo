
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;
using System.Management.Automation;
using Microsoft.Data.SqlClient;
using Microsoft.Azure.Services.AppAuthentication;
using System.Security;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED)]
    [OutputType(typeof(Server))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        #region ParameterSets
        private const string PARAMETERSET_CONNECTION_STRING     = "ConnectionString";
        private const string PARAMETERSET_PROPERTIES_INTEGRATED = "Properties_IntegratedSecurity";
        private const string PARAMETERSET_PROPERTIES_CREDENTIAL = "Properties_Credential";
        private const string PARAMETERSET_SQL_CLIENT            = "SqlClient";
        #endregion

        internal static Server Instance { get; set; }

        #region Parameters

        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true,
            ParameterSetName = PARAMETERSET_SQL_CLIENT
        )]
        public SqlConnection Connection { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_CONNECTION_STRING,
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Server", "ServerName", "ServerInstance")]
        public string DataSource { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Database", "DatabaseName")]
        public string InitialCatalog { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SecureString Password { get; set; }

        [Parameter()]
        public int StatementTimeout { get; set; } = 600;
        #endregion

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            switch (ParameterSetName)
            {
                case PARAMETERSET_SQL_CLIENT:
                    WriteVerbose("Connect by existing connection");
                    Instance = new Server(
                        serverConnection: new ServerConnection(
                            sqlConnection: Connection
                        )
                        {
                            StatementTimeout = StatementTimeout
                        }
                    );
                    break;

                    case PARAMETERSET_CONNECTION_STRING:
                    {
                        WriteVerbose("Connect by connection string");
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                        builder.ConnectionString = ConnectionString;
                        Connection = new SqlConnection(connectionString: builder.ConnectionString);
                        Instance = new Server(
                            serverConnection: new ServerConnection(
                                sqlConnection: Connection
                            )
                            {
                                StatementTimeout = StatementTimeout
                            }
                        );
                        break;
                    }

                    case PARAMETERSET_PROPERTIES_INTEGRATED:
                    {
                        WriteVerbose("Connect by Integrated Security");
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                        builder.DataSource = DataSource;
                        if (InitialCatalog != null)
                            builder.InitialCatalog = InitialCatalog;
                        if (DataSource.EndsWith("database.windows.net"))
                        {
                            Connection = new SqlConnection(connectionString: builder.ConnectionString);
                            AccessToken ??= new AzureServiceTokenProvider().GetAccessTokenAsync("https://database.windows.net").Result;
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
                            {
                                StatementTimeout = StatementTimeout
                            }
                        );
                        break;
                    }

                    case PARAMETERSET_PROPERTIES_CREDENTIAL:
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
                            {
                                StatementTimeout = StatementTimeout
                            }
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
