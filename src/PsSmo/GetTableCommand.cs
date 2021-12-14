using System.Management.Automation;
using System.Linq;
using Microsoft.SqlServer.Management.Smo;
using System.Collections.Generic;

namespace PsSmo
{
    [Cmdlet(VerbsCommon.Get, "Table")]
    [OutputType(typeof(Table))]
    public class GetTableCommand : ClientCommand
    {
        [Parameter()]
        public string Name { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            foreach (Table table in Instance.Databases[Instance.ConnectionContext.CurrentDatabase].Tables)
            {
                if (string.IsNullOrEmpty(Name) || table.Name == Name)
                    WriteObject(table);
            }
        }
    }
}
