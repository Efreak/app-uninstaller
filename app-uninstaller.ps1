function DeProvisionApps {
	"Getting the list of (built-in) apps that were provisioned with windows"
	$prov = Get-AppxProvisionedPackage -online

	"Uninstalling provisioned apps"
	foreach ($app in $prov) {
		$message = "Do you want to deprovision " + $app.DisplayName + "?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Uninstall"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Leaves it alone"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
		switch ($result) {
			0 {
				$app | Remove-AppXProvisionedPackage -Online
			}
			1 {
				"Leaving " + $app.DisplayName + " provisioned."
			}
		}
	}
}

function UninstallApps {
	# Don't uninstall these apps
	$keep = @(
		"Microsoft.BioEnrollment",
		"Microsoft.AAD.BrokerPlugin",
		"Microsoft.Windows.CloudExperienceHost",
		"Microsoft.Windows.ShellExperienceHost",
		"windows.immersivecontrolpanel",
		"Microsoft.Windows.Cortana",
		"Microsoft.AccountsControl",
		"Microsoft.LockApp",
		"Microsoft.MicrosoftEdge",
		"Microsoft.PPIProjection",
		"Microsoft.Windows.Apprep.ChxApp",
		"Microsoft.Windows.AssignedAccessLockApp",
		"Microsoft.Windows.ContentDeliveryManager",
		"Microsoft.Windows.ParentalControls",
		"Microsoft.Windows.SecondaryTileExperience",
		"Microsoft.Windows.SecureAssessmentBrowser",
		"Microsoft.XboxGameCallableUI",
		"Windows.ContactSupport",
		"Windows.MiracastView",
		"Windows.PrintDialog",
		"Microsoft.VCLibs.140.00",
		"Microsoft.VCLibs.140.00",
		"Microsoft.NET.Native.Framework.1.3",
		"Microsoft.NET.Native.Framework.1.3",
		"Microsoft.NET.Native.Runtime.1.3",
		"Microsoft.NET.Native.Runtime.1.3",
		"Microsoft.WindowsStore",
		"Microsoft.WindowsCalculator",
		"Microsoft.Advertising.Xaml",
		"Microsoft.Advertising.Xaml",
		"Microsoft.Appconnector",
		"Microsoft.NET.Native.Runtime.1.1",
		"Microsoft.NET.Native.Runtime.1.1",
		"Microsoft.DesktopAppInstaller",
		"Microsoft.XboxIdentityProvider",
		"Microsoft.WindowsSoundRecorder",
		"Microsoft.StorePurchaseApp",
		"Microsoft.NET.Native.Runtime.1.4",
		"Microsoft.NET.Native.Runtime.1.4"
		"microsoft.windowscommunicationsapps"
	)

	# It's hard to remove items from a powershell array, so just use a new array...
	$apps = @()

	"Removing apps that can't/shouldn't be uninstalled from the list of apps to ask about"
	foreach ($app in Get-AppXPackage) {
		if ($keep -notcontains $app.name) {
			$apps += $app
		}
	}

	"Uninstalling apps that have been installed"
	foreach ($app in $apps) {
		$message = "Do you want to uninstall " + $app.name + "?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Uninstall"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Leaves it alone"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
		switch ($result) {
			0 {
				Get-AppXPackage $app.Name | Remove-AppXPackage
			}
			1 {
				"Leaving " + $app.Name + " installed."
			}
		}
	}
}

"Checking to make sure powershell is elevated (for uninstalling provisioned apps)"
# stolen from https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole)) {
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	Clear-Host
	DeProvisionApps
	Clear-Host
} else {
	$message = "You are not running as an administrator! Do you want to re-run as administrator so you can deprovision apps? (You can still uninstall apps from your account without this"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Elevate so you can deprovision apps from the system image"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Don't elevate. You can still uninstall apps from your user account."
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
	switch ($result) {
		0 {
			$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
			$newProcess.Arguments = $myInvocation.MyCommand.Definition;
			$newProcess.Verb = "runas";
			[System.Diagnostics.Process]::Start($newProcess);
			exit
		}
	}
}
UninstallApps
exit