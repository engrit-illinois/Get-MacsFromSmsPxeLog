# Summary
Pulls our SMSPXE log from the `\\engr-mecmdp-01\logs` share and pulls just the MACs, to help identify bootlooping machines.  

This script just pulls all MAC addresses from the current content of `SMSPXE.log`, and returns the list of unique MACs found, along with a count of how many times they each appeared in the log, and their first and last seen times. This makes it obvious if there are any machines which are bootlooping and spamming the log.  

# Requirements
- Must be run as a user with permission to `\\engr-mecmdp-01\logs`.  

# Usage
1. Download `Get-MacsFromSmsPxeLog.psm1` to the following path (create the path if needed):
    - [Windows PowerShell 5.1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-5.1#how-to-install-a-module): `$HOME\Documents\WindowsPowerShell\Modules\Get-MacsFromSmsPxeLog\Get-MacsFromSmsPxeLog.psm1`
    - [PowerShell 6+](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.3#how-to-install-a-module): `$HOME\Documents\PowerShell\Modules\Get-MacsFromSmsPxeLog\Get-MacsFromSmsPxeLog.psm1`
3. Run it: `Get-MacsFromSmsPxeLog`  

# Example
<img src=".\Get-MacsFromSmsPxeLog_example.png" />

# Parameters

### -Path \<string\>
Optional string.  
Specifies the file path to the SMSPXE.log to parse.  
Default is `\\engr-mecmdp-01\logs\SMSPXE.log`.  
Note: this log is cycled out and an older log with a timestamp in the name is kept in the same directory.  

### -TimezoneModifier \<string\>
Optional string.  
Specifies the timezone offset used by timestamps in the SMSPXE.log file.  
Default is `+360`.  
Note: This could be revisited, and either ignored with some fancy regex, or actually interpreted correctly, which I wasn't sure how to do.  

# Notes
By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
