function Invoke-CIPPStandardEnableHardwareOAuth {
    <#
    .FUNCTIONALITY
        Internal
    .COMPONENT
        (APIName) EnableHardwareOAuth
    .SYNOPSIS
        (Label) Enable Hardware OAuth tokens
    .DESCRIPTION
        (Helptext) Enables the HardwareOath authenticationMethod for the tenant. This allows you to use hardware tokens for generating 6 digit MFA codes.
        (DocsDescription) Enables Hardware OAuth tokens for the tenant. This allows users to use hardware tokens like a Yubikey for authentication.
    .NOTES
        CAT
            Entra (AAD) Standards
        TAG
        ADDEDCOMPONENT
        IMPACT
            Low Impact
        ADDEDDATE
            2023-12-18
        POWERSHELLEQUIVALENT
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration
        RECOMMENDEDBY
        UPDATECOMMENTBLOCK
            Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    .LINK
        https://docs.cipp.app/user-documentation/tenant/standards/list-standards
    #>

    param($Tenant, $Settings)
    ##$Rerun -Type Standard -Tenant $Tenant -Settings $Settings 'EnableHardwareOAuth'

    try {
        $CurrentState = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/policies/authenticationmethodspolicy/authenticationMethodConfigurations/HardwareOath' -tenantid $Tenant
    }
    catch {
        $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
        Write-LogMessage -API 'Standards' -Tenant $Tenant -Message "Could not get the EnableHardwareOAuth state for $Tenant. Error: $ErrorMessage" -Sev Error
        return
    }
    $StateIsCorrect = ($CurrentState.state -eq 'enabled')

    If ($Settings.remediate -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'HardwareOAuth Support is already enabled.' -sev Info
        } else {
            try {
                Set-CIPPAuthenticationPolicy -Tenant $tenant -APIName 'Standards' -AuthenticationMethodId 'HardwareOath' -Enabled $true
            } catch {
            }
        }
    }

    if ($Settings.alert -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'HardwareOAuth Support is enabled' -sev Info
        } else {
            Write-StandardsAlert -message "HardwareOAuth Support is not enabled" -object $CurrentState -tenant $tenant -standardName 'EnableHardwareOAuth' -standardId $Settings.standardId
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'HardwareOAuth Support is not enabled' -sev Info
        }
    }

    if ($Settings.report -eq $true) {
        $state = $StateIsCorrect ? $true : $CurrentState
        Set-CIPPStandardsCompareField -FieldName 'standards.EnableHardwareOAuth' -FieldValue $state -TenantFilter $Tenant
        Add-CIPPBPAField -FieldName 'EnableHardwareOAuth' -FieldValue $StateIsCorrect -StoreAs bool -Tenant $tenant
    }
}
