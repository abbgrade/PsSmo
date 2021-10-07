﻿
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
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
            Instance.ConnectionContext.ExecuteNonQuery(sqlCommand: processSqlCmdText(Text, processVariables(Variables)));
        }

        private Dictionary<string, string> processVariables(Hashtable variables)
        {
            var variableDictionary = new Dictionary<string, string>();

            foreach (DictionaryEntry variable in variables)
            {
                variableDictionary.Add(
                    variable.Key.ToString(), 
                    variable.Value.ToString()
                );
            }

            return variableDictionary;
        }

        private string processSqlCmdText(string text, Dictionary<string, string> variables)
        {
            var result = new List<string>();
            var variableRegex = new Regex(@"\$\((\w*)\)");
            var setVarRegex = new Regex(@":setvar (\w+) ?""(.+)?""");
            var commentRegex = new Regex(@"/\*(.|\n)*?\*/");

            var processedText = commentRegex.Replace(text, replacement: "");

            foreach (var line in processedText.Split(Environment.NewLine))
            {
                if (line.Trim().StartsWith(":on error", StringComparison.CurrentCultureIgnoreCase))
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
                    foreach(var variable in variables)
                    {
                        processedLine = processedLine.Replace($"$({variable.Key})", variable.Value);
                    }

                    var match = variableRegex.Match(input: processedLine);
                    if (match.Success)
                    {
                        foreach(var variable in variables)
                        {
                            WriteWarning($"$({variable.Key}) = '{variable.Value}'");
                        }
                        throw new InvalidOperationException($"Value for variable {match.Value} was not given.");
                    }

                    result.Add(processedLine);
                }
            }
            return string.Join(separator: Environment.NewLine, result);
        }
    }
}
