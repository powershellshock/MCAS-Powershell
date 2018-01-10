<#
.Synopsis
   Retrieves MCAS configuration settings. 
.DESCRIPTION
   Get-MCASConfiguration lists the general configuration settings or mail configuration settings of the MCAS tenant.

.EXAMPLE
    C:\>Get-MCASConfiguration

    environmentName            : Contoso
    omsWorkspaces              :
    quarantineSite             :
    ssoNewSPEntityId           : https://contoso.portal.cloudappsecurity.com/saml/consumer
    ssoSPEntityId              : https://contoso.portal.cloudappsecurity.com/saml/consumer
    emailMaskPolicyOptions     : @{FULL_CONTENT=CONSOLE_GENERAL_SETTINGS_EMAIL_MASK_POLICIES_NAME_FULL_CONTENT;
                                MASKED_SUBJECT=CONSOLE_GENERAL_SETTINGS_EMAIL_MASK_POLICIES_NAME_MASKED_SUBJECT;
                                ONLY_ID=CONSOLE_GENERAL_SETTINGS_EMAIL_MASK_POLICIES_NAME_ONLY_ID}
    ssoEntityId                :
    ssoCertificate             :
    ssoHasMetadata             : True
    ssoEnabled                 : False
    allowAzIP                  : True
    ssoSignInPageUrl           :
    canChangeAllowAzIP         : True
    quarantineUserNotification : This file was quarantined because it might conflict with your organization's security and
                                compliance policies. Contact your IT administrator for more information.
    ssoSignOutPageUrl          :
    languageData               : @{tenantLanguage=default; availableLanguages=System.Object[]}
    discoveryMasterTimeZone    : Etc/GMT
    ssoOldSPEntityId           : https://us.portal.cloudappsecurity.com/saml/consumer?tenant_id=26034820
    ssoByDomain                : True
    ignoreExternalAzIP         : False
    ssoLockdown                : False
    ssoSPLogoutId              : https://contoso.portal.cloudappsecurity.com/saml/logout
    ssoSignAssertion           : False
    showAllowAzIP              : True
    emailMaskPolicy            : MASKED_SUBJECT
    orgDisplayName             : Contoso
    domains                    : {contoso.onmicrosoft.com}
    showSuffixDisclaimer       : True
    logoFilePath               :

.EXAMPLE
    C:\>Get-MCASConfiguration -Settings MailSettings

    tenantEmail
    -----------
    @{fromDisplayName=Contoso}

.FUNCTIONALITY
   Get-MCASConfiguration is intended to return the configuration settings of an MCAS tenant.
#>
function Get-MCASConfiguration {
    [CmdletBinding()]
    param (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        # Specifies whether to retrieve the General setting (default), or the Mail settings (via -Settings MailSettings)
        [Parameter(Mandatory=$false)]
        [ValidateSet('GeneralSettings','MailSettings')]
        [string]$Settings = 'GeneralSettings'
    )

    $returnResponseDataProperty = $false

    switch ($Settings) {
        'GeneralSettings'   {$path = '/cas/api/settings/get/'}
        'MailSettings'      {$path = '/cas/api/mail_settings/get/'}  
    }

    try {
        $response = Invoke-MCASRestMethod -Credential $Credential -Path $path -Method Get
    }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }

    $response
}