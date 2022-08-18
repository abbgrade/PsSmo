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

### SqlClient
```
Connect-SmoInstance -Connection <SqlConnection> [<CommonParameters>]
```

### ConnectionString
```
Connect-SmoInstance [-ConnectionString] <String> [<CommonParameters>]
```

### Properties_IntegratedSecurity
```
Connect-SmoInstance [-DataSource] <String> [[-InitialCatalog] <String>] [-AccessToken <String>]
 [<CommonParameters>]
```

### Properties_SQLServerAuthentication
```
Connect-SmoInstance [-DataSource] <String> [[-InitialCatalog] <String>] [-UserId] <String>
 [-Password] <SecureString> [<CommonParameters>]
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
Parameter Sets: Properties_IntegratedSecurity, Properties_SQLServerAuthentication
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
Parameter Sets: Properties_IntegratedSecurity, Properties_SQLServerAuthentication
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
Parameter Sets: Properties_SQLServerAuthentication
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
Parameter Sets: Properties_SQLServerAuthentication
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
