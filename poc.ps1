$targetServer = 'SCSBENSQLDEV01'
$targetDB = 'ATOReporting_UAT'
$schemaName = 'cognos'
$author = 'David Leyden'
$authorEmail = 'david.leyden@serco-ap.com.au'
$docVersion = '0.1'
$outputFile = 'cognos.adoc'


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
$SMO = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $targetServer
$Database = $SMO.Databases.Item($targetDB)

$Schema = $Database.Schemas.Item($schemaName)

$Tables = $Database.Tables | Where-Object {$_.Schema -eq $schemaName}
$Views = $Database.Views | Where-Object {$_.Schema -eq $schemaName}
$Procs = $Database.StoredProcedures | Where-Object {$_.Schema -eq $schemaName}


function underline
{
    param([string]$text, [string]$char)
@"
$text
$($char * $text.Length)
"@
}


$TableText = $Tables | % {
"`n[[$($_.Name -replace '\s','_')_def]] $($_.Name)::`n`t$($_.ExtendedProperties.Item('adoc_Definition').value)`n"
}

$ViewText = $Views | % {
"`n[[$($_.Name -replace '\s','_')_def]] $($_.Name)::`n`t$($_.ExtendedProperties.Item('adoc_Definition').value)`n"
}

$ProcText = $Procs | % {
"`n[[$($_.Name -replace '\s','_')_def]] $($_.Name)::`n`t$($_.ExtendedProperties.Item('adoc_Definition').value)`n"
}


$adoc = @"

$(underline "$($schemaName) Schema" '=')
:Author:    $author
:Email:     $authorEmail
:Date:      $(Date)
:Revision:  $docVersion

$(underline 'Introduction' '~')

$($Schema.ExtendedProperties.Item('adoc_Intro').value)

$(underline 'Overview' '~')

$($Schema.ExtendedProperties.Item('adoc_Overview').value)

$(underline 'Tables' '~')

$TableText

$(underline 'Views' '~')

$ViewText

$(underline 'Procedures' '~')

$ProcText

"@

Set-Content $outputFile $adoc


