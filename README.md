# ChocoAutomation
Powershell Scripts for automating chocolatey tasks. These are more centered around internalizing for enterprises and remote upgrading of client packages with PowerShell.

# ChocoUpdate
This script can be run on a local server that has connection to a local repo and community repo. It will pull all packages from multiple repos. Check the version and push new packages if it is out of date with slack notfications. (This currently doesnt check for dependencies). 

To run as a task schedule with logging:
 ```
 "powershell.exe C:\temp\chocoupdate\chocoupdate.ps1" > C:\temp\chocoupdate\update.log
 ```

# More coming soon.

# Legal and Licensing
Chocolatier is licensed under the MIT license.
