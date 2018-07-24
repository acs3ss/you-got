#!/bin/sh

#Test in Firefox 5.0
 $sessionStoreFile = "$env:APPDATA\Mozilla\Firefox\Profiles\*.default\sessionstore-backups\recovery.js"
 $sessionStoreFileExists = Test-Path $sessionStoreFile
 If($sessionStoreFileExists -eq $False) {
     #Test in Firefox 2.0, 3.0 and 4.0
     $sessionStoreFile = "$env:APPDATA\Mozilla\Firefox\Profiles\*.default\sessionstore.js"
 }
 (Get-Content -Encoding UTF8 -Raw -Path $sessionStoreFile).Trim('()') | ConvertFrom-Json |
 Select -Expand Windows | Select -Expand Tabs |
 Where { !$_.hidden } | ForEach { @($_.Entries)[-1] } |
 Select Url, Title | Export-Txt -Path $CsvFile  -Encoding UTF8  -NoTypeInformation
