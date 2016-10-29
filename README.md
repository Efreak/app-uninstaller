# app-uninstaller
Prompt to uninstall individual apps in windows 10

Running this script will automatically prompt for elevation, then prompt you to uninstall installed apps under windows 10.

If you are not elevated, it will prompt you to elevate so you can deprovision apps as well, so they won't be automatically installed into new user accounts; if you don't elevate, it can still uninstall apps installed to your local user account.


To run the script without downloading, use:

    powershell -nop -c "iex(New-Object Net.WebClient).DownloadString("https://github.com/Efreak/app-uninstaller/raw/master/app-uninstaller.ps1")