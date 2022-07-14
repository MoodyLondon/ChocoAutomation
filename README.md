# ChocoAutomation
Powershell Scripts for automating chocolatey tasks. These are more centered around internalizing for enterprises and remote upgrading of client packages with PowerShell.

# ChocoUpdate
This script can be run on a local server that has connection to a local repo and community repo. It will pull packages from multiple local repositories. Check the version against the public repo and push any updates, with slack notfications. (This currently doesnt check for dependencies). 

![alt text](https://github.com/MoodyLondon/ChocoAutomation/blob/main/examples/Annotation%202022-07-14%20084254.png)

To run as a task schedule with logging:
 ```
 "powershell.exe C:\temp\chocoupdate\chocoupdate.ps1" > C:\temp\chocoupdate\update.log
 ```

# More coming soon.

# Legal and Licensing
ChocoAutomation is licensed under the [Apache-2.0 license](https://github.com/MoodyLondon/ChocoAutomation/blob/main/LICENSE) use at your own risk.
