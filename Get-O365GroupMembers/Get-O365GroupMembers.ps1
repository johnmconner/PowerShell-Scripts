<#
.SYNOPSIS
  Example script to get Office 365 Groups with Members and Owners 
.DESCRIPTION
  This is an example script from Practical365.com modified by John Conner to export O365 group members
.INPUTS
  None
.OUTPUTS
  Custom Object
.NOTES
  Version:        1.2
  Author:         Steve Goodman
  Modified by:    John Conner - John.m.conner@gmail.com
  Creation Date:  20190113
  Purpose/Change: Removed Export-CSV functionality to provide more Output flexibility,
                  Refactored 'get members' code -> increased performance
.EXAMPLE
#>
function Get-O365GroupMembers {
    Write-Verbose "Loading all Groups"
    $Groups = Get-distributiongroup -ResultSize Unlimited

    #Process Groups
    Write-Verbose "Processing Groups"
    foreach ($Group in $Groups) {
        #Get members
        $Members = Get-distributiongroupmember -Identity $Group.Identity -ResultSize Unlimited | Select-Object -ExpandProperty Name
        
        #Create object
        [pscustomobject]@{
            GroupSMTPAddress = $Group.PrimarySmtpAddress
            GroupIdentity    = $Group.Identity
            GroupDisplayName = $Group.DisplayName
            Members          = $Members -join ", "
        }
    }
}