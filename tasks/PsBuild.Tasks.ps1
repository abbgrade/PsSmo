#region InvokeBuild

task UpdateBuildTasks {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/DotNet/Build.Tasks.ps1' `
        -OutFile "$PSScriptRoot\Build.Tasks.ps1"
}

#endregion
#region GitHub Actions

task UpdateValidationWorkflow {
    [System.IO.FileInfo] $file = "$PSScriptRoot/../.github/workflows/build-validation.yml"
    New-Item -Type Directory $file.Directory -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/build-validation-matrix.yml' `
        -OutFile $file
}

task UpdatePreReleaseWorkflow {
    requires ModuleName
    [System.IO.FileInfo] $file = "$PSScriptRoot\..\.github\workflows\pre-release.yml"
    New-Item -Type Directory $file.Directory -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/pre-release-windows.yml' |
    ForEach-Object { $_ -replace 'MyModuleName', $ModuleName } |
    Out-File $file -NoNewline
}

task UpdateReleaseWorkflow {
    requires ModuleName
    [System.IO.FileInfo] $file = "$PSScriptRoot\..\.github\workflows\release.yml"
    New-Item -Type Directory $file.Directory -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/release-windows.yml' |
    ForEach-Object { $_ -replace 'MyModuleName', $ModuleName } |
    Out-File $file -NoNewline
}

#endregion
#region GitHub Pages

task UpdateIndexPage {
    New-Item -Type Directory "$PSScriptRoot\..\docs" -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/docs/index.md' `
        -OutFile "$PSScriptRoot\..\docs\index.md"
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/docs/_config.yml' `
        -OutFile "$PSScriptRoot\..\docs\_config.yml"
}

#endregion
#region GitHub Dependabot

task UpdateDependabotConfig {
    requires ModuleName
    [System.IO.FileInfo] $file = "$PSScriptRoot\..\.github\dependabot.yml"
    New-Item -Type Directory $file.Directory -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/dependabot/dependabot.yml' |
    ForEach-Object { $_ -replace 'MyModuleName', $ModuleName } |
    Out-File $file -NoNewline
}

#endregion
#region VsCode

task UpdateVsCodeTasks {
    [System.IO.FileInfo] $file = "$PSScriptRoot\..\.vscode\tasks.json"
    New-Item -Type Directory $file.Directory -ErrorAction SilentlyContinue
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/VsCode/tasks.json' `
        -OutFile $file
}

#endregion
#region PsBuildTasks

task UpdatePsBuildTasksTasks {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/tasks/Dotnet-Matrix.Tasks.ps1' `
        -OutFile "$PSScriptRoot\PsBuild.Tasks.ps1"
}

#endregion

task UpdatePsBuildTasks -Jobs UpdateBuildTasks, UpdateValidationWorkflow, UpdatePreReleaseWorkflow, UpdateReleaseWorkflow, UpdateIndexPage, UpdateDependabotConfig, UpdateVsCodeTasks, UpdatePsBuildTasksTasks
