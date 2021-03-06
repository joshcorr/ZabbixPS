function Get-ZBXMaintenance
{
    <#
    .SYNOPSIS

    Gets a Zabbix maintenance period.

    .DESCRIPTION

    Gets a Zabbix maintenance period.

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

    .PARAMETER Name

    The maintenance name.

	.PARAMETER Id

	The maintenance id.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    None, does not support output.

    .EXAMPLE

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/maintenance/delete
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gzm")]
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
        [string]
        $Name,

        [Parameter()]
        [string]
        $Id
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
    }

    process
    {
        $body = @{
            method  = 'maintenance.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output            = "extend"
                selectGroups      = "extend"
                selectHosts       = "extend"
                selectTimeperiods = "extend"
            }
        }
        if ($Name)
        {
            $body.params.filter = @{
                name = $Name
            }
        }
        if ($Id)
        {
            $body.params.maintenanceids = $Id
        }
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
        return Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

    end
    {
    }
}