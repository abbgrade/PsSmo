
using Microsoft.SqlServer.Management.Smo;
using System.Management.Automation;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    [OutputType(typeof(Server))]
    public class DisconnectInstanceCommand : ClientCommand
    {

        [Parameter(
            Position = 0,
            ValueFromPipeline = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Connection")]
        public Server Instance { get; set; } = ConnectInstanceCommand.Instance;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            Instance.ConnectionContext.Disconnect();
        }

    }
}
