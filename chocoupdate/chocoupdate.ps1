[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
#Pull Packages
$adminrepo = choco list -r --source="'<REPALCE_ME>'"
$userrepo = choco list -r --source="'<REPALCE_ME>'"
#Repo Info
$RepoURL = "<REPALCE_ME>"
$LocalRepoApiKey = "<REPALCE_ME>"
#slack
$uriSlack = "<REPALCE_ME>"
#List of Packages to exclude
$exclude = Get-Content "C:\temp\chocoupdate\exclude.txt"
#Storage Info
$tempPath = "C:\temp\"
$dfs = "<REPALCE_ME>"

#Get Packages from both repos
    $adminPackages = foreach ($adminPackage in $adminrepo) 
        {
            [PSCustomObject]@{
            Name = $adminPackage.Split('|')[0]
            CurrentVersion = $adminPackage.Split('|')[1]
            PublicVersion = 0
            Repo = "admin"
            }
        }
    $userPackages = foreach ($userPackage in $userrepo) 
        {
            [PSCustomObject]@{
            Name = $userPackage.Split('|')[0]
            CurrentVersion = $userPackage.Split('|')[1]
            PublicVersion = 0
            Repo = "user"
            }
        }

#join repos to one object
$intpackages=$userPackages + $adminPackages

#Skip Exclude packages and pull Public Versions packages from Chocolatey .org
    foreach ($package in $intpackages)
        {
            if ($package.Name -in $exclude)            
                {
                    Write-host $Package.Name"has been Skipped"
                    $package.PublicVersion = $package.PublicVersio
                }
                Else
                {
                $package.PublicVersion = (choco list $Package.name --exact -r --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'").Split('|')[1]
                Write-host $package.name"has a remote version of"$package.PublicVersion
                }
        }

    $intpackages | ForEach-Object{
#If Internal Version is less than public version download (length fixs floating decimal issues)
            if ($_.PublicVersion.length -ne $_.currentversion.length -or ($_.PublicVersion -gt $_.currentversion) -and ($_.Name -notin $exclude))
                {
                    Write-host "Package '$($_.name)' has a remote version of '$($_.PublicVersion)' which is later than the local version '$($_.currentversion)'."
                    Write-host "Internalizing package '$($_.name)' with version '$($_.PublicVersion)'."
                    cd $tempPath
                    choco download $_.name --no-progress --internalize  --ignoredependencies --force --internalize-all-urls --append-use-original-location --output-directory=$tempPath --source="'https://licensedpackages.chocolatey.org/api/v2/;https://community.chocolatey.org/api/v2/'" 

#Copy Packages Recompile and Push then alert slack
                    if ($LASTEXITCODE -eq 0)
                        {
                            Write-host "Copying package '$($_.name)' to '$($_.repo)' FileShare."
                            $localrepo = $RepoURL + $_.Repo + "/"
                            $fileshare = $dfs + $_.Repo
                            $temploc = $temppath + "download\" + $_.name
                            $loc =  $fileshare + "\" + $_.name + "\" + $_.PublicVersion
                            $nuspec = $loc + "\" + $_.name + ".nuspec"
                            $nupkg = $fileshare + "\" + $_.name + "." + $_.PublicVersion + ".nupkg"
                            Move-Item -path $temploc -Destination $loc -force
                            Write-host "Packing '$($_.name)'."
                            choco pack $nuspec --outputdirectory $fileshare
                            Write-host "Pushing package '$($_.name)' to local repository '$($_.repo)'."
                            choco push $nupkg --source $LocalRepo --api-key $LocalRepoApiKey --force
                            Write-host "Package '$($_.name)' pushed to repo. Notifying Choco Bot"
                            $name = $_.name
                            $CurrentVersion = $_.CurrentVersion
                            $PublicVersion = $_.PublicVersion
                            $body = ConvertTo-Json @{
                                pretext = "$name has been Updated ::arrow_up:"
                                text = "The new version has sucessfully been pushed $PublicVersion. Previous version was: $CurrentVersion"
                            }
                            Invoke-RestMethod -uri $uriSlack -Method Post -body $body -ContentType 'application/json' -TimeOut 120 | Out-Null
                        }
#Alert slack if it Fails
                        else
                        {
                            Write-host "Failed to download package '$($_.name)'"
                            $name = $_.name
                            $body = ConvertTo-Json @{
                            pretext = "$name Failed to download :large_red_square:"
                            text = "Please check logs."
                        }
                            Invoke-RestMethod -uri $uriSlack -Method Post -body $body -ContentType 'application/json' -TimeOut 120 | Out-Null
                        }     
                    }
#Write Host for skipped packages
                    else
                    {
                        Write-host "Package '$($_.name)' has a remote version of '$($_.publicversion)' which is not later than the local version '$($_.CurrentVersion)'."
                    }          
        }
Get-ChildItem $tempPath -Include *.nupkg -Recurse| Remove-Item -ErrorAction SilentlyContinue
$tempdown = $temppath + "download\"
Get-ChildItem $tempdown -Recurse | Remove-Item -ErrorAction SilentlyContinue
Get-ChildItem * -Include *.nupkg  -Recurse| Remove-Item -ErrorAction SilentlyContinue
exit
