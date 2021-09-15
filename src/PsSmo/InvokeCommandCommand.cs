
using System.Data;
using System.Management.Automation;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;

namespace PsSmo
{
    [Cmdlet(VerbsLifecycle.Invoke, "Command")]
    public class InvokeCommandCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = false
        )]
        public Server Instance { get; set; } = ConnectInstanceCommand.Instance;

        [Parameter(
            Mandatory = true
        )]
        public string Command { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            var database = Instance.Databases[Instance.ConnectionContext.CurrentDatabase];
            var dataSet = database.ExecuteWithResults(sqlCommand: Command);

            foreach( DataTable dataTable in dataSet.Tables)
            {
                foreach (DataRow row in dataTable.Rows)
                {
                    var output = new PSObject();
                    foreach (DataColumn column in dataTable.Columns)
                    {
                        output.Members.Add(
                            new PSNoteProperty(
                                name: column.ColumnName,
                                value: row.IsNull(column.ColumnName) ? null : row[column]
                            )
                        );
                    }
                    WriteObject(output);
                }
            }

        }
    }
}
