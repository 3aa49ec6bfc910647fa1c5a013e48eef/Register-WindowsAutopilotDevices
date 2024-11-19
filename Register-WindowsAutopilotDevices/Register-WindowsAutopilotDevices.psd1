@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'Register-WindowsAutopilotDevices.psm1'

    # Version number of this module.
    ModuleVersion     = '0.1.0'

    # ID used to uniquely identify this module
    GUID              = '042a1497-2979-4ad4-afd2-314939ef8067' # Replace with a new GUID if necessary

    # Author of this module
    Author            = '3aa49ec6bfc910647fa1c5a013e48eef'

    # Company or vendor of this module
    CompanyName       = ''

    # Description of the functionality provided by this module
    Description       = 'Registers Windows Autopilot devices and optionally adds them to an Intune group.'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        @{ ModuleName = 'Microsoft.Graph.Authentication'; ModuleVersion = '1.0.0' },
        @{ ModuleName = 'Microsoft.Graph.DeviceManagement.Enrollment'; ModuleVersion = '1.0.0' },
        @{ ModuleName = 'Microsoft.Graph.Identity.DirectoryManagement'; ModuleVersion = '1.0.0' },
        @{ ModuleName = 'Microsoft.Graph.Groups'; ModuleVersion = '1.0.0' }
    )

}