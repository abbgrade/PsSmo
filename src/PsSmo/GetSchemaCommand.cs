using System.Management.Automation;
using System.Linq;
using Microsoft.SqlServer.Management.Smo;
using System.Collections.Generic;

namespace PsSmo
{
    [Cmdlet(VerbsCommon.Get, "Schema")]
    [OutputType(typeof(Schema))]
    public class GetSchemaCommand : ClientCommand
    {
        [Parameter()]
        public string Name { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            foreach (Schema schema in Instance.Databases[Instance.ConnectionContext.CurrentDatabase].Schemas)
            {
                if (string.IsNullOrEmpty(Name) || schema.Name == Name)
                    WriteObject(schema);
            }
        }
    }
}
