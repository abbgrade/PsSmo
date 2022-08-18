using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace PsSmo
{
    public abstract class ClientCommand : PSCmdlet
    {
        [Parameter()]
        [Alias("Connection")]
        public Server Instance { get; set; } = ConnectInstanceCommand.Instance;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            Instance.ConnectionContext.InfoMessage += ConnectionContext_InfoMessage;
            Instance.ConnectionContext.RemoteLoginFailed += ConnectionContext_RemoteLoginFailed;
            Instance.ConnectionContext.ServerMessage += ConnectionContext_ServerMessage;
            Instance.ConnectionContext.StateChange += ConnectionContext_StateChange;
            Instance.ConnectionContext.StatementExecuted += ConnectionContext_StatementExecuted;
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();

            Instance.ConnectionContext.InfoMessage -= ConnectionContext_InfoMessage;
            Instance.ConnectionContext.RemoteLoginFailed -= ConnectionContext_RemoteLoginFailed;
            Instance.ConnectionContext.ServerMessage -= ConnectionContext_ServerMessage;
            Instance.ConnectionContext.StateChange -= ConnectionContext_StateChange;
            Instance.ConnectionContext.StatementExecuted -= ConnectionContext_StatementExecuted;
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if (Instance == null)
                throw new PSArgumentNullException(nameof(Instance), $"run Connect-SmoInstance");
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
            switch (e.Error.Class)
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
