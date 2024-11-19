<#
.SYNOPSIS
Registers Windows Autopilot devices and adds them to an Intune group.

.DESCRIPTION
This script collects hardware information using the Get-WindowsAutoPilotInfo script,
imports the devices into Windows Autopilot via Microsoft Graph API,
and adds them to a specified Intune group.

.PARAMETER Force
Skips the confirmation prompt and proceeds with execution.

.PARAMETER GroupName
Specifies the name of the Intune group to which the devices will be added (optional).

.EXAMPLE
Register-WindowsAutopilotDevices

.EXAMPLE
Register-WindowsAutopilotDevices -Force -GroupName "My-Autopilot-Devices"

.NOTES
Author: 3aa49ec6bfc910647fa1c5a013e48eef
#>

Function Register-WindowsAutopilotDevices {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [string]$GroupName
    )

    Begin {
        # Warning and confirmation prompt
        if (-not $Force) {
            Write-Warning "This is an untested script and should be used with caution."
            $confirmation = Read-Host "Do you want to continue? (Y/N)"
            if ($confirmation -notin @('Y', 'y')) {
                Write-Host "Operation cancelled by user."
                return
            }
        }

        # Check for Get-WindowsAutoPilotInfo script
        $getAutoPilotInfoCommand = Get-Command -Name Get-WindowsAutoPilotInfo -CommandType ExternalScript -ErrorAction SilentlyContinue

        if (-not $getAutoPilotInfoCommand) {
            Write-Warning "The 'Get-WindowsAutoPilotInfo' script is not installed."

            if (-not $Force) {
                $installPrompt = Read-Host "Do you want to install 'Get-WindowsAutoPilotInfo' now? (Y/N)"
                if ($installPrompt -notin @('Y', 'y')) {
                    Write-Error "Cannot proceed without 'Get-WindowsAutoPilotInfo'. Exiting."
                    return
                }
            }

            Write-Host "Installing 'Get-WindowsAutoPilotInfo' script..."
            try {
                Install-Script -Name Get-WindowsAutoPilotInfo -Scope CurrentUser -Force
                Write-Host "'Get-WindowsAutoPilotInfo' script installed successfully."
            }
            catch {
                Write-Error "Failed to install 'Get-WindowsAutoPilotInfo'. Error: $_"
                return
            }

            # Refresh the command after installation
            $getAutoPilotInfoCommand = Get-Command -Name Get-WindowsAutoPilotInfo -CommandType ExternalScript -ErrorAction SilentlyContinue

            if (-not $getAutoPilotInfoCommand) {
                Write-Error "Unable to find 'Get-WindowsAutoPilotInfo' even after installation. Exiting."
                return
            }
        }
    }

    Process {
        try {
            # Get device information
            Write-Host "Collecting device information..."
            $devices = & $getAutoPilotInfoCommand.Path

            if (-not $devices) {
                Write-Error "No devices found. Ensure that Get-WindowsAutoPilotInfo returns device information."
                return
            }

            # Connect to Microsoft Graph with the required scope
            Write-Host "Connecting to Microsoft Graph..."
            Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All", "Directory.ReadWrite.All"

            # Import each device
            foreach ($device in $devices) {
                # Convert the hardware hash from Base64 string to byte array
                $hardwareIdentifierBytes = [Convert]::FromBase64String($device.'Hardware Hash')

                $deviceIdentity = @{
                    serialNumber       = $device.'Device Serial Number'
                    productKey         = $device.'Windows Product ID'
                    hardwareIdentifier = $hardwareIdentifierBytes
                }

                Write-Host $deviceIdentity

                # Import the device
                Write-Host "Importing device with serial number '$($deviceIdentity.serialNumber)'..."
                $response = New-MgDeviceManagementImportedWindowsAutopilotDeviceIdentity -BodyParameter $deviceIdentity

                # Output the response
                $response | Format-List
            }

            # ... [Rest of the code remains the same] ...

        }
        catch {
            Write-Error "An error occurred: $_"
        }
        finally {
            # Disconnect from Microsoft Graph
            Disconnect-MgGraph
        }
    }

    End {
        Write-Host "Operation completed."
    }
}

# Export the function
Export-ModuleMember -Function Register-WindowsAutopilotDevices