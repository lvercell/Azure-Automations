# Set file paths
$csvPath = ".\users.csv"
$logPath = ".\log.txt"
$outputCSV = ".\created_users.csv"

# Clean up previous files if they exist
if (Test-Path $logPath) { Remove-Item $logPath }
if (Test-Path $outputCSV) { Remove-Item $outputCSV }

# Create empty log file with header
"===== Script started: $(Get-Date) =====" | Out-File -FilePath $logPath

# Load users from CSV
$users = Import-Csv -Path $csvPath

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.Read.All"

# Get list of unique groups from CSV
$groups = $users | Select-Object -ExpandProperty Group -Unique

foreach ($group in $groups) {
    $groupExists = $false
    try {
        $existingGroup = Get-MgGroup -Filter "displayName eq '$group'" -ErrorAction Stop
        if ($existingGroup) {
            $groupExists = $true
            Write-Host "[!] Group '$group' already exists." | Tee-Object -FilePath $logPath -Append
            continue
        }
    } catch {
        Write-Host "[>] Group '$group' not found. Attempting to create..." | Tee-Object -FilePath $logPath -Append
    }

    if (-not $groupExists) {
        try {
            $newGroup = New-MgGroup `
                -DisplayName $group `
                -MailEnabled:$false `
                -MailNickname $group `
                -SecurityEnabled:$true `
                -GroupTypes @()

            if ($newGroup) {
                Write-Host "[OK] Group '$group' created successfully." | Tee-Object -FilePath $logPath -Append
            } else {
                Write-Host "[!] Group '$group' creation returned empty response." | Tee-Object -FilePath $logPath -Append
            }
        } catch {
            Write-Host "[ERROR] Failed to create group '$group': $_" | Tee-Object -FilePath $logPath -Append
        }
    }
}

foreach ($user in $users) {
    try {
        $existingUser = Get-MgUser -Filter "userPrincipalName eq '$($user.UserPrincipalName)'" -ErrorAction Stop
        if ($existingUser) {
            Write-Host "[!] User '$($user.UserPrincipalName)' already exists. Skipping." | Tee-Object -FilePath $logPath -Append
            continue
        }
    } catch {
        # User not found
    }

    Write-Host "[>] Creating user: $($user.DisplayName)" | Tee-Object -FilePath $logPath -Append
    try {
        $newUser = New-MgUser `
            -DisplayName $user.DisplayName `
            -MailNickname $user.MailNickname `
            -UserPrincipalName $user.UserPrincipalName `
            -PasswordProfile @{ ForceChangePasswordNextSignIn = $false; Password = $user.Password } `
            -AccountEnabled:$true

        Start-Sleep -Seconds 3

        $group = Get-MgGroup -Filter "displayName eq '$($user.Group)'" -ErrorAction Stop
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $newUser.Id

        Write-Host "[OK] User '$($user.UserPrincipalName)' created and added to group '$($user.Group)'." | Tee-Object -FilePath $logPath -Append

        # Write to CSV immediately
        $record = [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            Group             = $user.Group
        }

        if (-not (Test-Path $outputCSV)) {
            $record | Export-Csv -Path $outputCSV -NoTypeInformation -Encoding UTF8
        } else {
            $record | Export-Csv -Path $outputCSV -NoTypeInformation -Encoding UTF8 -Append
        }

    } catch {
        Write-Host "[ERROR] Failed to create or add user '$($user.UserPrincipalName)': $_" | Tee-Object -FilePath $logPath -Append
    }
}

Write-Host "`n===== Script completed =====" | Tee-Object -FilePath $logPath -Append
