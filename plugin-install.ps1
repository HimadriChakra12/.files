$url = Read-host "Lemme know the URL"
$name = Read-host "Name of the plugin"

git clone $url "$env:LOCALAPPDATA\nvim-data\site\pack\manual\start\$name"
