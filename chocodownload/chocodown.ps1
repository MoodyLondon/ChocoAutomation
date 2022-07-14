#Require Package name, version, repo
$package = Read-Host -Prompt 'Input your package'
$version = Read-Host -Prompt 'Input your Version (Leave Blank if you want latest version)'
$repo = Read-Host -Prompt 'Input repo (admin or user)'
#Repo
$RepoURL = "<REPALCE_ME>'"
$LocalRepoApiKey = "<REPALCE_ME>'"
#Storage
$dfs = "<REPALCE_ME>'"
$tempPath = "C:\temp\"
#If version was not entered find newest version
if ($version -eq $null)
{
Write-host "Looking for latest version of '$package'."
$version = (choco list $Package --exact -r --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'").Split('|')[1]
}

#Download Pacakge
cd $tempPath
Write-host "Internalizing package '$package'."
choco download $package --no-progress --internalize --version=$version --ignoredependencies --force --internalize-all-urls --append-use-original-location --output-directory=$tempPath --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'"

#Copy Packages Recompile and Push then alert slack
if ($LASTEXITCODE -eq 0)
    {
        Write-host "Copying package '$package' to '$repo' FileShare."
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
            text = "$package has sucessfully been pushed to $repo Repo. Version: $Version"
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
$tempdown = $temppath + "download\"
Get-ChildItem $tempdown -Recurse | Remove-Item -ErrorAction SilentlyContinue
Get-ChildItem * -Include *.nupkg  -Recurse| Remove-Item -ErrorAction SilentlyContinue
exit
