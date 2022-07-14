#Require Package name, version, repo
$package = Read-Host -Prompt 'Input your package'
$version = (choco list $Package --exact -r --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'").Split('|')[1]
#Repo
$RepoURL = "<REPALCE_ME>"
$LocalRepoApiKey = "<REPALCE_ME>"
$uriSlack = "<REPALCE_ME>"
#Storage
$dfs = "<REPALCE_ME>"
$tempPath = "C:\temp\"

#Check Repo
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "`What repo would you like to push $package to? type 'a' for admin or 'u' for user:"
    Switch($yn.ToLower())
    {
        "a" {$validAnswer = $true
            $repo = "admin"
        }
        "u" {$validAnswer = $true
             $repo = "user"
        }
        Default {Write-Host "Try entering 'a' for admin or 'u' for user."}
    }
}

#Check Version is the one you want
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "`Newest version is $version would you like to download this y or n:"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
            $version = $version
        }
        "n" {$validAnswer = $true
             $version = Read-Host -Prompt 'Enter the version you would like'
        }
        Default {Write-Host "Try entering 'y' for yes or 'n' for no."}
    }
}

#Download Pacakge
cd $tempPath
Write-host "Internalizing package '$package'."
choco download $package --no-progress --internalize --version=$version --ignoredependencies --force --internalize-all-urls --append-use-original-location --output-directory=$tempPath --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'"

#Copy Packages Recompile and Push then alert slack
if ($LASTEXITCODE -eq 0)
    {
        Write-host "Copying package '$package' to '$repo' FileShare."
        $version = $version
        $localrepo = $RepoURL + $Repo + "/"
        $fileshare = $dfs + $Repo
        $temploc = $temppath + "download\" + $package
        $loc =  $fileshare + "\" + $package + "\" + $version
        $nuspec = $loc + "\" + $package + ".nuspec"
        $nupkg = $fileshare + "\" + $package + "." + $version + ".nupkg"
        Move-Item -path $temploc -Destination $loc
        Write-host "Packing '$package'"
        choco pack $nuspec --outputdirectory $fileshare
        Write-host "Pushing package '$package' to local repository '$repo'."
        choco push $nupkg --source $LocalRepo --api-key $LocalRepoApiKey --force
        Write-host "Package '$package' pushed to repo. Notifying Choco Bot"
        $body = ConvertTo-Json @{
            pretext = "$package has been Internalized :new:"
            text = "$package with Version: $Version has sucessfully been pushed to $repo Repo."
        }
        Invoke-RestMethod -uri $uriSlack -Method Post -body $body -ContentType 'application/json' -TimeOut 120 | Out-Null

    }
#Alert slack if it Fails
    Else
        {
        
        Write-host "Failed to Internalize package '$package'"
        $name = $package
        $body = ConvertTo-Json @{
                            pretext = "$package Failed to Internalize :broken_heart:"
                            text = "Please check logs."
                        }
                            Invoke-RestMethod -uri $uriSlack -Method Post -body $body -ContentType 'application/json' -TimeOut 120 | Out-Null
                        }
Get-ChildItem $tempPath -Include *.nupkg -Recurse| Remove-Item -ErrorAction SilentlyContinue
$tempdown = $temppath + "download\*"
Get-ChildItem $tempdown -Recurse | Remove-Item -ErrorAction SilentlyContinue
Get-ChildItem * -Include *.nupkg  -Recurse| Remove-Item -ErrorAction SilentlyContinue
exit
