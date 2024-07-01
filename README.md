# Summary
Reads `SMSPXE.log` from one or more given DFS paths, and pulls out just the MACs, to help identify bootlooping machines.  

This script just pulls all MAC addresses from the current content of `SMSPXE.log`, and returns the list of unique MACs found, along with a count of how many times they each appeared in the log, their first and last seen times, and which server they were seen on. This makes it obvious if there are any machines which are bootlooping and spamming the log.  

# Requirements
- Must be run as a user with permission to the given paths.

# Usage
1. Download `Get-MacsFromSmsPxeLog.psm1` to the appropriate subdirectory of your PowerShell [modules directory](https://github.com/engrit-illinois/how-to-install-a-custom-powershell-module).
2. Run it: `Get-MacsFromSmsPxeLog`  

# Example
In this example, you can infer that the most seen MAC is bootlooping and spamming the log. Each PXE attempt by a machine will generate roughly 2-4 occurrences of the machine's MAC in the log.  
Note: this example image is from before the module accepted multiple paths.  

<img src=".\Get-MacsFromSmsPxeLog_example.png" />

# Parameters

### -Paths \<string[]\>
Required string array unless specifying `-UseDefaultsFor`.  
Specifies the file path(s) to the SMSPXE.log(s) to parse.  
Note: SMSPXE.log is regularly cycled out and an older log with a timestamped filename is kept in the same directory.  

### -UseDefaultsFor \<"ENGR" | "CBTF"\>
Required string unless specifying `-Paths`.  
When `ENGR` is specified, the paths used will be `@("\\engr-mecmpxe-01\logs\SMSPXE.log","\\engr-mecmpxe-02\logs\SMSPXE.log")`.  
When `CBTF` is specified, the paths used will be `@("\\cbtf-dp-01\e$\SMS_DP$\sms\logs\SMSPXE.log","\\cbtf-dp-02\e$\SMS_DP$\sms\logs\SMSPXE.log")`.  

# Notes
By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
