
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Management.Automation;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Management.Smo;

namespace PsSmo
{
    [Cmdlet(VerbsLifecycle.Invoke, "Command")]
    public class InvokeCommandCommand : ClientCommand
    {
        #region Parameters

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

        #endregion

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            switch (ParameterSetName)
            {
                case "Text":
                    WriteVerbose("Execute SQL script from text.");
                    break;

                case "File":
                    WriteVerbose($"Execute SQL script from file '{InputFile.FullName}'.");
                    Text = File.ReadAllText(InputFile.FullName);
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }

            foreach (var sqlCommand in ProcessSqlCmdText(Text, ProcessVariables(Variables)))
            {
                try
                {
                    Instance.ConnectionContext.ExecuteNonQuery(
                        sqlCommand: sqlCommand
                    );
                }
                catch (PipelineStoppedException)
                {
                    throw;
                }
                catch (Exception ex)
                {
                    WriteError(new ErrorRecord(ex, ex.GetType().Name, ErrorCategory.NotSpecified, Text));
                }
            }
        }

        private static Dictionary<string, string> ProcessVariables(Hashtable variables)
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

        private StringCollection ProcessSqlCmdText(string text, Dictionary<string, string> variables)
        {
            variables ??= new Dictionary<string, string>();

            var result = new List<string>();
            var resultCollection = new List<List<string>>() { result };
            var variableRegex = new Regex(@"\$\((\w*)\)");
            var setVarRegex = new Regex(@":setvar (\w+) ?""(.+)?""");
            var blockCommentRegex = new Regex(@"/\*(.|\n)*?\*/");
            var lineCommentRegex = new Regex(@"(--.*)");

            var processedText = text;

            processedText = blockCommentRegex.Replace(processedText, replacement: "");
            processedText = lineCommentRegex.Replace(processedText, replacement: "");


            foreach (var line in processedText.Split(Environment.NewLine))
            {
                if (line.Trim().StartsWith("GO", StringComparison.CurrentCultureIgnoreCase))
                {
                    result = new List<string>();
                    resultCollection.Add(result);
                }
                else if (line.Trim().StartsWith(":on error", StringComparison.CurrentCultureIgnoreCase))
                {
                    WriteWarning(":on error is not implemented");
                }
                else if (line.Trim().StartsWith(":setvar", StringComparison.CurrentCultureIgnoreCase))
                {
                    var match = setVarRegex.Match(line);
                    if (match.Success)
                    {
                        var variable = match.Groups[1].Value;
                        var value = match.Groups[2].Value;
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
                    foreach (var variable in variables)
                    {
                        processedLine = processedLine.Replace($"$({variable.Key})", variable.Value);
                    }

                    var match = variableRegex.Match(input: processedLine);
                    if (match.Success)
                    {
                        foreach (var variable in variables)
                        {
                            WriteWarning($"$({variable.Key}) = '{variable.Value}'");
                        }
                        throw new InvalidOperationException($"Value for variable {match.Value} was not given.");
                    }

                    result.Add(processedLine);
                }
            }
            var batchCollection = new StringCollection();
            foreach (var batch in resultCollection)
                batchCollection.Add(string.Join(separator: Environment.NewLine, batch));
            return batchCollection;
        }
    }
}
