function Get-ZBXAction
{
    <#
    .SYNOPSIS

    Returns a Zabbix action.

    .DESCRIPTION

    Returns a Zabbix action.

    .PARAMETER Uri

    The Zabbix instance uri.

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    ZabbixPS session, created by New-ZBXSession.

    .PARAMETER ActionId

    Return only actions with the given IDs.

    .PARAMETER GroupId

    Return only actions that use the given host groups in action conditions.

    .PARAMETER HostId

    Return only actions that use the given hosts in action conditions.

    .PARAMETER TriggerId

    Return only actions that use the given triggers in action conditions.

    .PARAMETER MediaTypeId

    Return only actions that use the given media types to send messages.

    .PARAMETER UserGroupId

    Return only actions that are configured to send messages to the given user groups.

    .PARAMETER UserID

    Return only actions that are configured to send messages to the given users.

    .PARAMETER ScriptId

    Return only actions that are configured to run the given scripts.

    .PARAMETER ActionName

    Return only actions that have a specific name. Wildcard filter.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix action.

    .EXAMPLE

    Returns all Zabbix actions.

    Get-ZBXAction

    .EXAMPLE

    Returns Zabbix Action with the Action name of 'myAction'.

    Get-ZBXAction -ActionName 'myAction'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/action/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gzac")]
    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [uri]
        $Uri,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [Alias('actionids')]
        [string[]]
        $ActionId,

        [Parameter()]
        [Alias('grouids')]
        [string[]]
        $GroupId,

        [Parameter()]
        [Alias('hostids')]
        [string[]]
        $HostId,

        [Parameter()]
        [Alias('triggerids')]
        [string[]]
        $TriggerId,

        [Parameter()]
        [Alias('mediatypeids')]
        [string[]]
        $MediaTypeId,

        [Parameter()]
        [Alias('usrgrpids')]
        [string[]]
        $UserGroupId,

        [Parameter()]
        [Alias('userids')]
        [string[]]
        $UserID,

        [Parameter()]
        [Alias('scriptids')]
        [string[]]
        $ScriptId,

        [Parameter()]
        [string]
        $ActionName
    )

    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-ZBXSession -ErrorAction 'Stop' | Select-Object -First 1
            if ($currentSession)
            {
                $Uri = $currentSession.Uri
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                $ApiVersion = $currentSession.ApiVersion
            }
        }

        $NonAPIParameters = @('Uri','Credential','Proxy','ProxyCredential','Session','ActionName')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters,[System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object {$PSItem})
    }

    process
    {

        $params  = @{
            output                   = 'extend'
            selectOperations         = 'extend'
            selectRecoveryOperations = 'extend'
            selectFilter             = 'extend'
        }

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()){
            if ($Parameter.key -notin $NonAPIParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                $params[$apiParam] = $Parameter.Value
            }
        }

        $body = New-ZBXRestBody -Method 'action.get' -API $ApiVersion -Params $params

        $invokeZabbixRestMethodSplat = @{
            Body        = $body
            Uri         = $Uri
            Credential  = $Credential
            ApiVersion  = $ApiVersion
            ErrorAction = 'Stop'
        }
        if ($Proxy)
        {
            $invokeZabbixRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $invokeZabbixRestMethodSplat.ProxyCredential = $ProxyCredential
            }
        }
        if ($ActionName) {
            Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat | Where-Object {$PSItem.Name -like "*$ActionName*"}
        } Else {
            Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
        }
    }
}