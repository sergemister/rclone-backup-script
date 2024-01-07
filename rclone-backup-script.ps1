# Script for creating file backups locally using rclone.
# Serge Mister, Version 1.0, 2024-01-06

param (
    [Parameter(Mandatory=$true)][string]$Mode
)

$ErrorActionPreference='Stop'

#### START OF CONFIGURATION ####

# The folder to which backup data is written; cannot be empty.
$backupPath='c:\temp\backups\'

# The base path for source files; this part of the path is not part of the naming in the backup folder.
# At a minimum, this must be a drive letter, such as c:, or . for the current directory.
$sourceBasePath='c:'

# An array of paths, relative to the sourceBasePath, to be backed up.
$foldersToBackup=@(
    'temp\test1\',
    'temp\test2\'
)

# The command needed to invoke rclone
$rclone='c:\software\rclone\rclone.exe'

#### END OF CONFIGURATION SECTION ####

# The name of the file that will contain a list of timestamps of when backups were completed successfully.
# This file also serves as a marker for valid backup output directories.
$backupLogFileName='backupLog.txt'

# Message - Outputs the specified message and displays a window to the user showing the same message.
function Message {
    param (
        $MessageText
    )
    Write-Output $MessageText
    $wshell=New-Object -ComObject Wscript.Shell
    $result=$wshell.Popup($MessageText,0,'Backup Script Message',0)
}

try {

    if ($sourceBasePath -eq '') {
        Write-Error -ErrorAction Stop 'sourceBasePath must not be empty'
    }

    if ($backupPath -eq '') {
        Write-Error -ErrorAction Stop 'backupPath must not be empty'
    }

    # The code assumes no trailing \ on directory paths, so adjust the config variables if necessary
    if ($sourceBasePath -match '\\$') {
        $sourceBasePath=$sourceBasePath.Substring(0,$sourceBasePath.length-1)
    }

    if ($backupPath -match '\\$') {
        $backupPath=$backupPath.Substring(0,$backupPath.length-1)
    }

    # Append the host name to the backup path
    $backupPath="$backupPath\$env:COMPUTERNAME"

    $backupLogFileFullPath="$backupPath\$backupLogFileName"

    if (! (Test-Path $backupLogFileFullPath)) {
        Write-Error -ErrorAction Stop "$backupLogFileFullPath does not exist.  Create an empty file at this location to use it as a backup directory."
    }

    Write-Output "Source base path: $sourceBasePath"
    Write-Output "Backup file location: $backupPath"

    # Iterate through the directories to be backed up, running rclone on each
    $foldersToBackup | ForEach-Object {
        Write-Output "**** Backing up: $PSItem ****"
        $sourcePath="$sourceBasePath\$PSItem"
        $outputPath="$backupPath\$PSItem"
        if (! (Test-Path "$sourcePath")) {
            Write-Error -ErrorAction Stop "Backup source directory $sourcePath does not exist"
        }

        Write-Output "Backing up '$sourcePath' into '$outputPath'"
        if ($Mode -eq 'backup') {
            # Add --verbose flags for more detail
            & $rclone copy --checksum $sourcePath $outputPath
        } elseif ($Mode -eq 'check') {
            # --one-way to avoid reporting files that have been deleted from the source
            & $rclone check --one-way $sourcePath $outputPath
        } else {
            Write-Error -ErrorAction Stop "Unrecognized mode: '$Mode' (backup or check expected)"
        }
        if  ($LastExitCode -ne 0) {
            Write-Error -ErrorAction Stop "ERROR DURING RCLONE OPERATION: $LastExitCode"
        }
    }
    if ($Mode -eq 'backup') {
        Add-Content -Path $backupLogFileFullPath -Value (Get-Date)
        Message 'Backup completed successfully'
    } elseif ($Mode -eq 'check') {
        Message 'Checksum verification completed successfully'
    } else {
        Write-Error -ErrorAction Stop 'This should never occur'
    }
} catch {
    Write-Error -ErrorAction Continue $_
    $wshell=New-Object -ComObject Wscript.Shell
    $result=$wshell.Popup($_,0,'BACKUP SCRIPT ERROR',16)
    Exit 1
}
