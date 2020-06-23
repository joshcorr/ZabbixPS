function Export-ZBXAction
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

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix action.

    .EXAMPLE

    Returns all Zabbix actions.

    Get-ZBXAction

    .EXAMPLE

    Returns Zabbix Action with the Action name of 'myAction'.

    Get-ZBXAction -Name 'myAction'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/action/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
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

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $ActionId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $GroupId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $HostId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $TriggerId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $MediaTypeId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $UserGroupId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $UserID,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string[]]
        $ScriptId,

        [Parameter(ParameterSetName = 'ByCredential')]
        [Parameter(ParameterSetName = 'BySession')]
        [string]
        $ActionName,

        [Parameter(Mandatory,
            ParameterSetName = 'InputObject')]
        [object]
        $InputObject,

        [Parameter(Mandatory)]
        [string]
        $FilePath

    )

    begin
    {
        if ($PSCmdlet.ParameterSetName -in @('BySession','ByCredential'))
        {
            $splatParameters = @{}
            foreach ($param in $PSBoundParameters) {
                if($param.key -ne 'FilePath') {
                    $splatParameters.Add("$($param.key)","$($param.value)")
                }
            }
            $object = Get-ZBXAction @splatParameters
        } else {
            $object = $InputObject
        }

    }

    process
    {
        foreach ($action in $object) {
            $action | ConvertTo-Json -Depth 12 | Out-File -FilePath $Filepath -Append
        }
    }
}