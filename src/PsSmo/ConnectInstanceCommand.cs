
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;
using System.Management.Automation;
using System.Data.SqlClient;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Connect, "Instance")]
    [OutputType(typeof(Server))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        internal static Server Instance { get; set; }


        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true
        )]
        public SqlConnection Connection { get; set; }

        protected override void ProcessRecord()
        {
            if (Connection != null)
                Instance = new Server(
                    serverConnection: new ServerConnection(
                        sqlConnection: Connection
                    )
                );
            else
                Instance = new Server();
            WriteObject(Instance);
        }

    }
}
