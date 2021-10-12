
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

            Instance.ConnectionContext.InfoMessage += ConnectionContext_InfoMessage;
            Instance.ConnectionContext.RemoteLoginFailed += ConnectionContext_RemoteLoginFailed;
            Instance.ConnectionContext.ServerMessage += ConnectionContext_ServerMessage;
            Instance.ConnectionContext.StateChange += ConnectionContext_StateChange;
            Instance.ConnectionContext.StatementExecuted += ConnectionContext_StatementExecuted;

            WriteObject(Instance);
        }

        private void ConnectionContext_RemoteLoginFailed(object sender, ServerMessageEventArgs e)
        {
            WriteWarning(e.ToString());
        }

        private void ConnectionContext_StatementExecuted(object sender, StatementEventArgs e)
        {
            WriteInformation(messageData: e.SqlStatement, tags: new string[] { "SqlStatement" });
        }

        private void ConnectionContext_StateChange(object sender, System.Data.StateChangeEventArgs e)
        {
            WriteVerbose($"Database state changed from {e.OriginalState} to {e.CurrentState}.");
        }

        private void ConnectionContext_ServerMessage(object sender, ServerMessageEventArgs e)
        {
            switch(e.Error.Class)
            {
                case 0:
                    break; // handled in ConnectionContext_InfoMessage
                default:
                    WriteWarning($"{e.Error.Class}: {e.Error}");
                    break;
            }
            
        }

        private void ConnectionContext_InfoMessage(object sender, SqlInfoMessageEventArgs e)
        {
            var message = e.Message.Trim();
            if (message.Length > 0)
                WriteVerbose(message);
        }

    }
}
