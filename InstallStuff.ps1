$apps = @(
"Git.Git", 
"Vim.vim",
"7zip.7zip",
"Greenshot.Greenshot",
"JetBrains.Toolbox",
"JetBrains.Rider",
"Spotify.Spotify",
"SlackTechnologies.Slack", 
"Docker.DockerDesktop",
"Logitech.Options",
"VivaldiTechnologies.Vivaldi",
"Microsoft.WindowsTerminal",
"Microsoft.DotNet.SDK.7",
"Microsoft.DotNet.SDK.8",
"Microsoft.VisualstudioCode", 
"Microsoft.AzureDataStudio",
"Microsoft.AzureCLI",
"Microsoft.PowerShell"
"Microsoft.NuGet",
"JanDeDobbeleer.OhMyPosh",
"9NMPJ99VJBWV" # Windows Phone Link
)

$totalApps = $apps.Count
$jobs = @()
For ($i = 0; $i -lt $totalApps; $i++) {
    $app = $apps[$i]
    $progress = 100*$i/$totalApps
    $activity = "Installing $app"
    Write-Progress -Activity "Installing apps..." -Id 999 -Status "Installing $app..." -PercentComplete $progress
    Write-Progress -Activity $activity -Id $i -ParentId 999 -Status  "Checking if $app is already installed..." -PercentComplete 0

    if((winget list | Select-String -Pattern $app -Quiet) -eq $true){
        Write-Progress -Activity $activity -Id $i -ParentId 999  -Status  "Already Present. Skipping." -PercentComplete 100 -Completed
        $jobs += Start-Job -Name $app -ScriptBlock { Write-Information "Already Present. Skipping."}
    }else{
        Write-Progress -Activity $activity -Id $i -ParentId 999  -Status "Installing... " -PercentComplete 10
        $jobs += Start-Job -Name $app -ScriptBlock { winget install $args} -ArgumentList $app, --accept-package-agreements, --silent
    }
}

do {
    $currentJobs = Get-Job
    $completedJobs = ($currentJobs | Where-Object { $_.State -eq "Completed" }).Count
    $progress = 100*$completedJobs/$totalApps
    for ($i = 0; $i -lt $totalApps; $i++) {
        $app = $apps[$i]
        $activity = "Installing $app"
        if ($currentJobs[$i].State -eq "Completed") {
            Write-Progress -Activity $activity -Id $i -ParentId 999 -Status  "Installation Complete." -PercentComplete 100 -Completed
        } else {
            Write-Progress -Activity $activity -Id $i -ParentId 999 -Status  "Installing..." -PercentComplete 50
        }
    }
    Write-Progress -Activity "Installing Apps" -Id 999 -Status  "Waiting for apps to complete..." -PercentComplete $progress
    Start-Sleep -Seconds 2
} while (($currentJobs | Where-Object { $_.State -eq "Completed" }).Count -lt $totalApps)
Write-Progress -Activity "Installing Apps" -Id 999 -Status  "Installed $completedJobs apps" -PercentComplete 100
Get-Job | Format-Table -AutoSize
foreach ($job in $jobs) {
    Receive-Job -Job $job
    Remove-Job -Job $job
}
