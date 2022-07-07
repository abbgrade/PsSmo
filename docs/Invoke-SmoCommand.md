---
external help file: PsSmo.dll-Help.xml
Module Name: PsSmo
online version:
schema: 2.0.0
---

# Invoke-SmoCommand

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Text
```
Invoke-SmoCommand -Text <String> [-Variables <Hashtable>] [-Instance <Server>] [<CommonParameters>]
```

### File
```
Invoke-SmoCommand -InputFile <FileInfo> [-Variables <Hashtable>] [-Instance <Server>] [<CommonParameters>]
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

### -InputFile
{{ Fill InputFile Description }}

```yaml
Type: FileInfo
Parameter Sets: File
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Instance
{{ Fill Instance Description }}

```yaml
Type: Server
Parameter Sets: (All)
Aliases: Connection

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text
{{ Fill Text Description }}

```yaml
Type: String
Parameter Sets: Text
Aliases: Command

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Variables
{{ Fill Variables Description }}

```yaml
Type: Hashtable
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

### System.String

### System.IO.FileInfo

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
