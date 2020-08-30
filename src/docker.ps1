# Nexss PROGRAMMER 2.x - Docker package
$nxsParameters = @("downloadPathCache", "downloadNocache", "downloadFast")
$input | . "$($env:NEXSS_PACKAGES_PATH)/Nexss/Lib/NexssIn.ps1"

function Json-Merge($source, $extend){
    $merged = Join-Objects $source $extend
    $extended = AddPropertyRecurse $merged $extend
    return $extended
}

if ($PSVersionTable.PSVersion.Major -lt 6) {
    nxsError("Nexss Package Docker needs Powershell at least 6. Run below command in your Powershell")
    nxsError('iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"')
    exit
}


if (!$NexssStdout._params) {
    nxsError("Specify params parameter eg. nexss Docker --_params='run --rm wappalyzer/cli https://nexss.com'")
    exit
}

if (!((Get-Command docker -errorAction SilentlyContinue) -and (docker --version))) {
    nxsError("Docker is not installed. Installing the latest version..`n")
    scoop install docker
}

# We make sure docker machine is running
# docker-machine start default

# https://docs.docker.com/engine/reference/commandline/run/
nxsInfo("It will run: docker $($NexssStdout._params)`n")
# $Result = Invoke-Expression "docker $($NexssStdout._params)" | ConvertFrom-Json -AsHashtable
# $Result = $Result | ConvertFrom-Json

$dockerResult = Invoke-Expression "docker $($NexssStdout._params)`n" 

if($NexssStdout._type -eq 'merge'){
    ($dockerResult | ConvertFrom-Json).psobject.Properties | ForEach-Object {
        $NexssStdout | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
    }
}else{
    $NexssStdout | Add-Member -NotePropertyMembers @{nxsOut = $dockerResult }
}

. "$($env:NEXSS_PACKAGES_PATH)/Nexss/Lib/NexssOut.ps1"
