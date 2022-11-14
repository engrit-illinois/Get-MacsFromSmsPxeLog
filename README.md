# Summary
Pulls our SMSPXE log from the `\\engr-mecmdp-01\logs` and pulls just the MACs, to help identify bootlooping machines.  

This script just pulls all MAC addresses from the current content of `SMSPXE.log`, and returns the list of unique MACs found, along with a count of how many times they each appeared in the log. This makes it obvious if there are any machines which are bootlooping and spamming the log.  

# Requirements
- Must be run as a user with permission to `\\engr-mecmdp-01\logs`.  

# Usage
`Get-MacsFromSmsPxeLog`  

# Example
<img src=".\Get-MacsFromSmsPxeLog_example.png" />

# Parameters
None.  

# Notes
By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
