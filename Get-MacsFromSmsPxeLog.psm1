function Get-MacsFromSmsPxeLog {
	
	param(
		[string[]]$Paths,
		
		[ValidateSet('ENGR', 'CBTF')]
		[string]$UseDefaultsFor,
		
		[string[]]$EngrPaths = @("\\engr-mecmpxe-01\logs\SMSPXE.log","\\engr-mecmpxe-02\logs\SMSPXE.log"),
		
		[string[]]$CbtfPaths = @("\\cbtf-dp-01\e$\SMS_DP$\sms\logs\SMSPXE.log","\\cbtf-dp-02\e$\SMS_DP$\sms\logs\SMSPXE.log")
	)
	
	if(-not $Paths) {
		if($UseDefaultsFor) {
			$UseDefaultsFor = $UseDefaultsFor.ToUpper()
			switch($UseDefaultsFor) {
				"ENGR" { $Paths = $EngrPaths }
				"CBTF" { $Paths = $CbtfPaths }
				Default { Throw "Neither -Paths nor -UseDefaultsFor were specified!" }
			}
		}
		else {
			Throw "Neither -Paths nor -UseDefaultsFor were specified!"
		}
	}
	
	
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
	
	function Get-Data($path) {
		
		# Get the log content
		$content = Get-Content -Path $path
		
		# Replace newlines with spaces to make the regex much simpler
		# https://powershell-guru.com/powershell-tip-117-remove-whitespaces-from-a-string/
		$content = $content -replace "`n"," "
		
		# Define a regex pattern that matches log lines
		$lineRegex = '(<!\[LOG\[(.*)\]LOG]!><time="(.*)" date="(.*)" component.*>)'
		$lineMatches = $content | Select-String $lineRegex | Select -ExpandProperty "Matches"
		
		# Define a regex pattern that matches MAC addresses
		# https://stackoverflow.com/questions/4260467/what-is-a-regular-expression-for-a-mac-address
		$macRegex = '(([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2}))'
		
		$lines = $lineMatches | ForEach-Object {
			$line = $_
			
			$msg = $line.Groups[2].Value
			$line | Add-Member -NotePropertyName "Message" -NotePropertyValue $msg
			
			$timestamp = $line.Groups[3].Value
			$line | Add-Member -NotePropertyName "Timestamp" -NotePropertyValue $timestamp
			
			$date = $line.Groups[4].Value
			$line | Add-Member -NotePropertyName "Date" -NotePropertyValue $date
			
			# Deal with weird time offset
			$offsetIndex = $timestamp.IndexOf("+")
			if($offsetIndex -lt 0) {
				$offsetIndex = $timestamp.IndexOf("-")
			}
			
			if($offsetIndex -ge 0) {
				$offset = $timestamp.Substring($offsetIndex)
				$time = $timestamp.Replace($offset,"")
			}
					
			$dateTime = Get-Date "$time $date"
			
			$line | Add-Member -NotePropertyName "DateTime" -NotePropertyValue $dateTime
			
			# This could return an array of MAC strings instead of a single MAC string, if more than one MAC is present in the $msg.
			$macs = $msg.ToUpper() | Select-String $macRegex | Select -ExpandProperty "Matches" | Select -ExpandProperty "Value"
			$line | Add-Member -NotePropertyName "Macs" -NotePropertyValue $macs
			
			$line
		}
		
		# The following will break if more than one MAC was present in the $msg.
		# Not sure how I would handle that, but so far I haven't seen this happen.
		# I'd probably loop through the lines which have MACs, loop through the _potentially_ multiple MACs, join all MACs into a single string, and then regex that.
		# But in the interest of avoiding another loop I'll ignore that for now, unless it becomes an issue.
		$macs = $lines | Where { $_.Macs } | Select -ExpandProperty "Macs"
		
		# Generate an array of unique MACs
		$macsUnique = $macs | Select -Unique
		
		# Pull server out of $path
		$pathParts = $path -split "\",0,'SimpleMatch'
		$server = $pathParts[2]
				
		# Create an array of new objects representing each unique MAC and it's statistics
		$data = $macsUnique | ForEach-Object {
			$mac = $_
			
			# Get all lines where $mac occurs
			$occurrences = $lines | Where {$_.Macs -eq $mac}
			
			[PSCustomObject]@{
				"Server" = $server
				"Mac" = $mac
				"Count" = $occurrences | Measure-Object | Select -ExpandProperty "Count"
				"FirstSeen" = $occurrences | Measure-Object -Property DateTime -Minimum | Select -ExpandProperty "Minimum"
				"LastSeen" = $occurrences | Measure-Object -Property DateTime -Maximum | Select -ExpandProperty "Maximum"
			}
		}
		
		# Return the munged data
		$data | Sort -Property Server, @{ Expression = {$_.Count}; Ascending = $false }, Mac
	}
	
	function Do-Stuff {
		
		$Paths | ForEach-Object {
			$path = $_
			Get-Data $path
		} | Format-Table
		
	}
	
	Do-Stuff
}