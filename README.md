# ChocoAutomation
Powershell Scripts for automating chocolatey tasks. These are more centered around internalizing for enterprises and remote upgrading of client packages with PowerShell.
### Layout
Feel Free to configure to your enviroment but currently the setup is asuming your repo and storage location ends with wether its a admin or user repo. So
https://nexusrepo/repository/choco- (admin or user) and \\\dfs\Chocolatey\\(admin or user)\\
The Nupkgs are then directly under the repo folder and packages are saved under name and version for example: 

Nupkg location = \\\dfs\Chocolatey\user\\*.nupkg

Package files = \\\dfs\Chocolatey\user\packagename\version\\*

The Slack notfications are just done using a webhook and json invoke comand.

# ChocoUpdate
This script can be run on a local workstation that has connection to a local repo and community repo. It will pull packages from multiple local repositories. Check the version against the public repo and push any updates, with slack notfications. (This currently doesnt check for dependencies). 

![alt text](https://github.com/MoodyLondon/ChocoAutomation/blob/main/examples/Annotation%202022-07-14%20084254.png)

To run as a task schedule with logging:
 ```
 "powershell.exe C:\temp\chocoupdate\chocoupdate.ps1" > C:\temp\chocoupdate\update.log
 ```

# ChocoDownload
This script can be run on a local workstation that has connection to a local repo and community repo. It will ask for input for package, check the latest version and ask if this is what you want, If not it will ask the version you want. It will also check what repo you would like to install this to admin or user. Then download package from public repo and push to your internal repo, with slack notfications. (This currently doesnt check for dependencies). 

 ```
PS C:\temp> C:\temp\chocodown.ps1
Input your package: chocolatey-vscode
What repo would you like to push chocolatey-vscode to? type 'a' for admin or 'u' for user:: a
Newest version is 0.7.2 would you like to download this y or n:: y
Internalizing package 'chocolatey-vscode'.
Chocolatey v0.12.1 Business
Downloading existing package(s) to C:\temp\download

chocolatey-vscode v0.7.2 (forced) [Approved]
Found internalizable Chocolatey functions. Inspecting values for remote resources.
Recompiling package.
Recompiled package files available at 'C:\temp\download\chocolatey-vscode'
Recompiled nupkg available in 'C:\temp\'
Copying package 'chocolatey-vscode' to 'admin' FileShare.
Packing 'chocolatey-vscode'
Chocolatey v0.12.1 Business
Attempting to build package from 'chocolatey-vscode.nuspec'.
Successfully created package '\\dfs\Chocolatey\admin\chocolatey-vscode.0.7.2.nupkg'
Pushing package 'chocolatey-vscode' to local repository 'admin'.
Chocolatey v0.12.1 Business
Attempting to push chocolatey-vscode.0.7.2.nupkg to https://nexusrepo/repository/choco-admin/
chocolatey-vscode 0.7.2 was pushed successfully to https://nexusrepo/repository/choco-admin/
Package 'chocolatey-vscode' pushed to repo. Notifying Choco Bot
 ```
![alt text](https://github.com/MoodyLondon/ChocoAutomation/blob/main/examples/Annotation%202022-07-14%20114658.png)

# More coming soon.

# Legal and Licensing
ChocoAutomation is licensed under the [Apache-2.0 license](https://github.com/MoodyLondon/ChocoAutomation/blob/main/LICENSE) use at your own risk.
