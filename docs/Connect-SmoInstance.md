---
external help file: PsSmo.dll-Help.xml
Module Name: PsSmo
online version:
schema: 2.0.0
---

# Connect-SmoInstance

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Properties_IntegratedSecurity (Default)
```
Connect-SmoInstance [-DataSource] <String> [[-InitialCatalog] <String>] [-AccessToken <String>]
 [-StatementTimeout <Int32>] [<CommonParameters>]
```

### SqlClient
```
Connect-SmoInstance -Connection <SqlConnection> [-StatementTimeout <Int32>] [<CommonParameters>]
```

### ConnectionString
```
Connect-SmoInstance [-ConnectionString] <String> [-StatementTimeout <Int32>] [<CommonParameters>]
```

### Properties_Credential
```
Connect-SmoInstance [-DataSource] <String> [[-InitialCatalog] <String>] [-UserId] <String>
 [-Password] <SecureString> [-StatementTimeout <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AccessToken
{{ Fill AccessToken Description }}

```yaml
Type: String
Parameter Sets: Properties_IntegratedSecurity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Connection
{{ Fill Connection Description }}

```yaml
Type: SqlConnection
Parameter Sets: SqlClient
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ConnectionString
{{ Fill ConnectionString Description }}

```yaml
Type: String
Parameter Sets: ConnectionString
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DataSource
{{ Fill DataSource Description }}

```yaml
Type: String
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential
Aliases: Server, ServerName, ServerInstance

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InitialCatalog
{{ Fill InitialCatalog Description }}

```yaml
Type: String
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential
Aliases: Database, DatabaseName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
{{ Fill Password Description }}

```yaml
Type: SecureString
Parameter Sets: Properties_Credential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UserId
{{ Fill UserId Description }}

```yaml
Type: String
Parameter Sets: Properties_Credential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -StatementTimeout
This is the number of seconds that a statement is attempted to be sent to the server before it fails.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Data.SqlClient.SqlConnection

### System.String

### System.Security.SecureString

## OUTPUTS

### Microsoft.SqlServer.Management.Smo.Server

## NOTES

## RELATED LINKS
