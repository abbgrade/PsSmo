using System.Management.Automation;

namespace PsSmo
{
    [Cmdlet(VerbsCommon.Get, "Table")]
    [OutputType(typeof(Microsoft.SqlServer.Management.Smo.Table))]
    public class GetTableCommand : ClientCommand
    {
        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            foreach(var table in Instance.Databases[Instance.ConnectionContext.CurrentDatabase].Tables)
            {
                WriteObject(table);
            }
        }
    }
}
