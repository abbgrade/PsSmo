
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;
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
            ParameterSetName = "Text",
            Mandatory = true,
            ValueFromPipeline = true
        )]
        [Alias("Command")]
        public string Text { get; set; }

        [Parameter(
            ParameterSetName = "File",
            Mandatory = true,
            ValueFromPipeline = true
        )]
        public FileInfo InputFile { get; set; }

        [Parameter()]
        public Hashtable Variables { get; set; } = new Hashtable();

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            var database = Instance.Databases[Instance.ConnectionContext.CurrentDatabase];
            switch (ParameterSetName)
            {
                case "Text":
                    break;

                case "File":
                    Text = File.ReadAllText(InputFile.FullName);
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }

            database.ExecuteNonQuery(sqlCommand: processSqlCmdText(Text, processVariables(Variables)));
        }

        private Dictionary<string, string> processVariables(Hashtable variables)
        {
            var variableDictionary = new Dictionary<string, string>();

            foreach (string key in variables.Keys)
            {
                variableDictionary.Add(key, (string)variables[key]);
            }

            return variableDictionary;
        }

        private string processSqlCmdText(string text, Dictionary<string, string> variables)
        {
            var result = new List<string>();
            var variableRegex = new Regex(@"\$\((\w*)\)");
            var setVarRegex = new Regex(@":setvar (\w+) (.+)");

            foreach (var line in text.Split(Environment.NewLine))
            {
                if (false) { }
                else if (line.Trim().StartsWith(":on error", StringComparison.CurrentCultureIgnoreCase))
                {
                    WriteWarning(":on error is not implemented");
                }
                else if (line.Trim().StartsWith(":setvar", StringComparison.CurrentCultureIgnoreCase))
                {
                    var match = setVarRegex.Match(line);
                    if (match.Success) {
                        string variable = match.Groups[1].Value;
                        string value = match.Groups[2].Value;
                        variables[variable] = value;
                    }
                }
                else if (line.Trim().StartsWith(":", StringComparison.CurrentCultureIgnoreCase))
                {
                    WriteWarning("Not all SQLCMD commands are implemented");
                }
                else
                {
                    var processedLine = line;
                    foreach(var tuple in variables)
                    {
                        processedLine = processedLine.Replace($"$({tuple.Key})", tuple.Value);
                    }

                    var match = variableRegex.Match(input: processedLine);
                    if (match.Success)
                    {
                        throw new InvalidOperationException($"Value for variable {match.Value} was not given.");
                    }

                    result.Add(processedLine);
                }
            }
            return string.Join(separator: Environment.NewLine, result);
        }
    }
}
