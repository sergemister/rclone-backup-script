# rclone-backup-script

## Introduction

rclone-backup-script is a simple PowerShell script built around the
rclone command line tool.  It is intended for making simple backup
copies of files.  It does not support incremental backups or other
advanced features.

## Configuration

1. Copy the script `rclone-backup-script.ps1` to your local system.

2. Modify the configuration section of the script to point to the
   files to be backed up and the backup destination.

3. Modify the configuration section of the script to point to the
   rclone binary.

## Performing a backup

To backup the configured files, run:

    powershell rclone-backup-script.ps1 backup

If PowerShell scripts are disabled on your system, you will need to use:

    powershell -ExecutionPolicy Unrestricted rclone-backup-script.ps1 backup

## Checking an existing backup

To verify that the files in the backup match those found in the backup
source, run:

    powershell rclone-backup-script.ps1 check

# Alternatives

This script's functionality could be implemented with a single
rclone invocation.  This script backs up folders with separate
invocations of rclone, which has the following advantages:

  * The script can check that the source folders exist.

  * Invocations of rclone are simpler.
