function Get-MacsFromSmsPxeLog {
	
	$content = Get-Content -Path "\\engr-mecmdp-01\logs\SMSPXE.log"
	
	# https://stackoverflow.com/questions/4260467/what-is-a-regular-expression-for-a-mac-address
	$macRegex = "(([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2}))"
	
	# https://stackoverflow.com/questions/33913878/how-to-get-the-captured-groups-from-select-string
	$matches = $content | Select-String $macRegex | Select -ExpandProperty "Matches"
	
	$macs = ($matches | Select -ExpandProperty "Value").ToUpper()
	$macsUnique = $macs | Select -Unique
	
	$data = $macsUnique | ForEach-Object {
		$mac = $_
		[PSCustomObject]@{
			"Mac" = $mac
			"Count" = $macs | Where {$_ -eq $mac} | Measure-Object | Select -ExpandProperty "Count"
		}
	}
	
	$data | Sort -Property @{ Expression = {$_.Count}; Ascending = $false }, Mac
}