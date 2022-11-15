function Get-MacsFromSmsPxeLog {
	
	# Log lines look like the following, generally
	<#
		<![LOG[$message]LOG]!><time="$timestamp" date="$date" component="SMSPXE" context="" type="1" thread="$threadId" file="$file:$line">
	#>
	
	# e.g.:
	<#
		<![LOG[============> Received from client:]LOG]!><time="03:53:49.320+360" date="11-14-2022" component="SMSPXE" context="" type="1" thread="3580" file="smspxe.cpp:666">
	#>

	# But $message can have line breaks, e.g.:
	<#
		<![LOG[
		 Operation: BootReply (2)  Addr type: 1 Addr Len: 6 Hop Count: 0 ID: 83885EFB
		 Sec Since Boot: 0 Client IP: 192.017.161.137 Your IP: 000.000.000.000 Server IP: 128.174.010.228 Relay Agent IP: 000.000.000.000
		 Addr: 88:51:fb:5e:88:83:
		 BootFile: smsboot\x64\pxeboot.com
		 Magic Cookie: 63538263
		 Options:
		  Type=53 Msg Type: 5=Ask
		  Type=54 Svr id: 128.174.010.228
		  Type=97 UUID: 0080be7847e0cde211be508851fb5e8883
		  Type=60 ClassId: PXEClient
		  Type=243 024530140000000a000000100000000e6600000000000026a59edc7f9c63c068bcb0acd1530be000000000000000000000000040c9bb799af7e83c986ac9897a7f3653c8d07ac901515c534d5354656d705c323032322e31312e31342e30332e33342e35382e303030312e7b35333931313431452d31303839272
		  Type=252 5c534d5354656d705c323032322e31312e31342e30332e33342e35382e30332e7b35333931313431452d313038392d344138392d414333332d4441434138443944433537387d2e626f6f742e62636400]LOG]!><time="03:53:44.895+360" date="11-14-2022" component="SMSPXE" context="" type="1" thread="4472" file="pxedump.cpp:303">
	#>
	
	# Get the log content
	$content = Get-Content -Path "\\engr-mecmdp-01\logs\SMSPXE.log"
	
	# Define a regex pattern that matches MAC addresses
	# https://stackoverflow.com/questions/4260467/what-is-a-regular-expression-for-a-mac-address
	$macRegex = "(([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2}))"
	
	# Grab all of the matches as "Match" objects
	# https://stackoverflow.com/questions/33913878/how-to-get-the-captured-groups-from-select-string
	$matches = $content | Select-String $macRegex | Select -ExpandProperty "Matches"
	
	# Grab the MAC from each Match, and uppercase it for consistency
	$macs = ($matches | Select -ExpandProperty "Value").ToUpper()
	
	# Generate an array of unique MACs
	$macsUnique = $macs | Select -Unique
	
	# Create an array of new objects representing each unique MAC and it's number of occurrences
	$data = $macsUnique | ForEach-Object {
		$mac = $_
		[PSCustomObject]@{
			"Mac" = $mac
			"Count" = $macs | Where {$_ -eq $mac} | Measure-Object | Select -ExpandProperty "Count"
		}
	}
	
	# Return the munged data
	$data | Sort -Property @{ Expression = {$_.Count}; Ascending = $false }, Mac
}