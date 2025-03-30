# Installation
$ProgressPreference = 'SilentlyContinue'; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex

# Optimization
choco feature enable --name=allowGlobalConfirmation
choco feature enable --name=useRememberedArgumentsForUpgrades
choco feature enable --name=usePackageExitCodes
choco feature enable --name=useEnhancedExitCodes
choco feature enable --name=showDownloadProgress
choco feature enable --name=useFipsCompliantChecksums
choco feature enable --name=logCommandOutput
choco config set cacheLocation C:\choco-cache
choco config set commandExecutionTimeoutSeconds 9999
choco config set webRequestTimeoutSeconds 999
choco config set virusCheck false

# Execution
choco feature enable --name=usePackageExitCodes
choco feature enable --name=useEnhancedExitCodes

