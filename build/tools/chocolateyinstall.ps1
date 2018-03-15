$ferret_version = "#FERRET_VERSION#"
$ferret_url = "https://github.com/forthright/ferret_temp"
$ferret_build = "releases/download/$($ferret_version)/ferret-$($ferret_version)-win-x86_64.zip"
$tools_dir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

Install-ChocolateyZipPackage -PackageName 'ferret' `
 -Url "$($ferret_url)/$($ferret_build)" `
 -UnzipLocation "$($tools_dir)\.." `
 -Checksum '#FERRET_SHA#' `
 -ChecksumType 'sha256'

Install-ChocolateyPath -PathToInstall "$($env:ChocolateyPackageFolder)\bin"
