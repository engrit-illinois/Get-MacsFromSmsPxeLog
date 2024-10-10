# Summary
Reads `SMSPXE.log` from one or more given DFS paths, and pulls out just the MACs, to help identify bootlooping machines.  

This script just pulls all MAC addresses from the current content of `SMSPXE.log`, and returns the list of unique MACs found, along with a count of how many times they each appeared in the log, their first and last seen times, and which server they were seen on. This makes it obvious if there are any machines which are bootlooping and spamming the log.  

# Requirements
- Must be run as a user with permission to the given paths.

# Usage
1. Download `Get-MacsFromSmsPxeLog.psm1` to the appropriate subdirectory of your PowerShell [modules directory](https://github.com/engrit-illinois/how-to-install-a-custom-powershell-module).
2. Run it: `Get-MacsFromSmsPxeLog `  

# Example
The default sorting groups identical MACs seen across multiple logs (i.e. servers), and sorts those groups by their highest count value:  
<br />
<img src=".\Get-MacsFromSmsPxeLog_example1b.png" />
<br />
<br />

This is an older screenshot with different sorting, but in this example, you can infer that the most seen MAC is bootlooping and spamming the log. Each PXE attempt by a machine will generate roughly 2-4 occurrences of the machine's MAC in the log.  
<br />
<img src=".\Get-MacsFromSmsPxeLog_example2b.png" />
<br />
<br />

# Parameters

### -Paths \<string[]\>
Optional string array.  
Specifies the file path(s) to the SMSPXE.log(s) to parse.  
Note: SMSPXE.log is regularly cycled out and an older log with a timestamped filename is kept in the same directory.  

### -UseDefaultsFor \<"ENGR" | "CBTF"\>
Optional string.  
Ignored if `-Paths` is specified.  
When `ENGR` is specified, the paths used will be `@("\\engr-mecmpxe-01.ad.uillinois.edu\logs\SMSPXE.log","\\engr-mecmpxe-02.ad.uillinois.edu\logs\SMSPXE.log")`.  
When `CBTF` is specified, the paths used will be `@("\\cbtf-dp-01.ad.uillinois.edu\logs\SMSPXE.log","\\cbtf-dp-02.ad.uillinois.edu\logs\SMSPXE.log")`.  
Default is `ENGR`.  

### -SortStyle \<"MacGroupHighestCount" | "ServerCount" | "MacServer"\>
Optional string.  
The output of the module can always be sorted however you wish by piping it to PowerShell's `Sort-Object` cmdlet. However the default sorting option allows for more complex sorting without a lot of extra code.  
The default value is `MacGroupHighestCount`.  
When `MacGroupHighestCount` is specified, the results will first group identical MACs (across multiple logs/servers), and then sort those groups such that the group with containing the highest count (on any server) is at the top. This sorting method makes it easy to identify MACs of machines which are spamming the SMSPXE.log file and thus are likely bootlooping.  
When `ServerCount` is specified, the results will not be grouped, but will be sorted by server and then by count. Equivalent to `Get-MacsFromSmsPxeLog | Sort Server,Count`.  
When `MacServer` is specified, the results will not be grouped, but will be sorted by MAC and then by server. Equivalent to `Get-MacsFromSmsPxeLog | Sort Mac,Server`.  

# Notes
By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
