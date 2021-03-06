function Invoke-ZBXRestMethod
{
    <#
    .SYNOPSIS

    Invokes a Zabbix rest method.

    .DESCRIPTION

    Invokes Zabbix rest method.

    .PARAMETER Body

    Specifies the body of the request. The body is the content of the request that follows the headers.

    .PARAMETER Uri

    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. This parameter supports HTTP, HTTPS, FTP, and FILE values.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request. The default is the Personal Access Token if it is defined, otherwise it is the current user.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The directory to output files to.

    .OUTPUTS

    System.Int64, System.String, System.Xml.XmlDocument, The output of the cmdlet depends upon the format of the content that is retrieved.

    .OUTPUTS

    PSObject, If the request returns JSON strings, Invoke-RestMethod returns a PSObject that represents the strings.

    .EXAMPLE

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [psobject]
        $Body,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory)]
        [string]
        $ApiVersion,

        [Parameter()]
        [string]
        $Path
    )

    begin
    {

    }

    process
    {
        $initializeZabbixSessionSplat = @{
            Uri        = $Uri
            Credential = $Credential
            ApiVersion = $ApiVersion
        }
        if ($Proxy)
        {
            $initializeZabbixSessionSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $initializeZabbixSessionSplat.ProxyCredential = $ProxyCredential
            }
        }
        $Body.auth = Initialize-ZBXSession @initializeZabbixSessionSplat
        $bodyJson = $Body | ConvertTo-Json -Depth 20
        $invokeRestMethodSplat = @{
            ContentType     = 'application/json'
            Method          = 'POST'
            UseBasicParsing = $true
            Uri             = $Uri.AbsoluteUri
            Body            = $bodyJson
        }
        if ($Proxy)
        {
            $invokeRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $invokeRestMethodSplat.ProxyCredential = $ProxyCredential
            }
            else
            {
                $invokeRestMethodSplat.ProxyUseDefaultCredentials = $true
            }
        }
        if ($Path)
        {
            $invokeRestMethodSplat.OutFile = $Path
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking Zabbix rest method: [$bodyJson]"
        try
        {
            $results = Invoke-RestMethod @invokeRestMethodSplat
        }
        catch
        {
            If ($PSitem -match 'File not found')
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate the Zabbix api at: [$Uri], is this the correct uri? See: https://www.zabbix.com/documentation/4.2/manual/api for more information." -ErrorAction 'Stop'
            }
            else
            {
                $PSitem | Write-Error
            }
        }
        if ($results.result)
        {
            return $results.result
        }
        elseif ($results.error)
        {
            Write-Error -Exception $results.error.message -Message $results.error.data -ErrorId $results.error.code
        }
    }

    end
    {
    }
}
