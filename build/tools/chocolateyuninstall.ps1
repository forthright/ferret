SETX PATH $env:Path.Replace(";$($env:ChocolateyPackageFolder)\bin", "")
