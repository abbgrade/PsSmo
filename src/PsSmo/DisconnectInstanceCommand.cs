
using Microsoft.SqlServer.Management.Smo;
using System.Management.Automation;

namespace PsSmo
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    [OutputType(typeof(Server))]
    public class DisconnectInstanceCommand : ClientCommand
    {

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            Instance.ConnectionContext.Disconnect();
        }

    }
}
