<#
.SYNOPSIS
  Sorts files by extension into folders on the users Desktop
.DESCRIPTION
  Sort files on desktop into folders by extension
.PARAMETER
  None
.INPUTS 
  None
.OUTPUTS
  None
.NOTES
  Version:        1.1
  Author:         John Conner john.m.conner@gmail.com  
  Creation Date:  20190113
  Modified Date: 8/11/2020
  Purpose/Change: Completely refactored code
#>
function Optimize-Desktop {
  $userprofilepath = $env:USERPROFILE + '\Desktop'

  $ExtTable = @{
    doc   = '.txt', '.rtf', '.doc', '.docx'
    img   = '.jpg', '.tif', '.png', '.gif'
    pdf   = '.pdf'
    excel = '.xls', '.xlsx', 'xlsb', '.csv'
  }
  $PathTable = @{
    Documents = '\Documents'
    Images    = '\Images'
    Excel     = '\Excel'
    PDFs      = '\PDFs'
  }
  #Check if folder exists, if not, create it
  $pathtable.GetEnumerator() | ForEach-Object ($_.Value) {
    $result = Test-Path -Path $($userprofilepath + $_.Value)
    if (-not($result)) {
      New-Item -path $($userprofilepath + $_.Value) -ItemType 'Directory' 
    }
  }

  #Grab the file objects 
  $files = Get-ChildItem $userprofilepath

  foreach ($file in $files) {

    #Move items into folders
    $filetype = ($ExtTable.GetEnumerator() | Where-Object Value -eq $($file.Extension)).Name
    switch ($filetype) {
      'doc' { Move-Item -path $file.FullName -Destination $($userprofilepath + $PathTable['doc']) }
      'img' { Move-Item -path $file.FullName -Destination $($userprofilepath + $PathTable['img']) }
      'pdf' { Move-Item -path $file.FullName -Destination $($userprofilepath + $PathTable['pdf']) }
      'excel' { Move-Item -path $file.FullName -Destination $($userprofilepath + $PathTable['excel']) }
    }
  }
}
