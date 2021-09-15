
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;
using System.Management.Automation;
using System.Data.SqlClient;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    [OutputType(typeof(Server))]
    public class DisconnectInstanceCommand : PSCmdlet
    {
        [Parameter(
            ValueFromPipeline = true
        )]
        public Server Instance { get; set; }

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            if (Instance == null)
                Instance = ConnectInstanceCommand.Instance;
        }

        protected override void ProcessRecord()
        {
            Instance.ConnectionContext.Disconnect();
        }

    }
}
