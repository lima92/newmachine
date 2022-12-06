$apps = @(
"Git.Git", 
"Vim.vim",
"7zip.7zip",
"Greenshot.Greenshot",
"JetBrains.Rider", 
"Spotify.Spotify",
"SlackTechnologies.Slack", 
"Docker.DockerDesktop",
"Logitech.Options",
"VivaldiTechnologies.Vivaldi",
"Microsoft.WindowsTerminal"
"Microsoft.DotNet.SDK.7",
"Microsoft.VisualstudioCode", 
"Microsoft.AzureDataStudio",
"Microsoft.AzureCLI",
"Microsoft.NuGet"
)

$totalApps = $apps.Count
For ($i = 0; $i -lt $totalApps; $i++) {
    $app = $apps[$i]
    $activity = "InstallStuff:"
    $progress = 100*$i/$totalApps
    Write-Progress $activity -Id 0 -Status  "$app : Checking if already installed..." -PercentComplete $progress

    if($(winget list -q $app | Measure-Object -Line).Lines -lt 5){
        Write-Progress $activity -Id 0 -Status "$app : Installing... " -PercentComplete ($progress+1)
        Start-Job -Name $app -ScriptBlock { winget -ArgumentList install $app --accept-package-agreements --silent}
    }else{
        Write-Progress $activity -Id 0 -Status  "$app : Already Present. Skipping." -PercentComplete ($progress+1)
    }
}
Write-Progress $activity -Id 0 -Status  "Waiting for installs to complete..." -PercentComplete (100)
do {
    $jobs = Get-Job | Format-Table -AutoSize
    $jobs
    Start-Sleep 10
} while (
     1 -eq 1
)