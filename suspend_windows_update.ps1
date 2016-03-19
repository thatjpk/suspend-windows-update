# suspend_windows_update.ps1
#
# ### WARNING ################################################################
# ### Disabling Windows Update for a long period of time is a pretty dumb idea.
# ### If you do, you'll end up way behind on security updates and you're Gonna
# ### Have A Bad Time™. This script is intended for users who need to
# ### occasionally, and temporarily, disable updates to ensure a specific task
# ### doesn't get interrupted by updates. When that task is complete, the user
# ### should return the update service to normal. This script is designed
# ### around this use case.
# ############################################################################
#
# Usage: suspend_windows_update.ps1
#
# Temporarily disables the Windows Update service by stopping and setting its
# startup type to disabled. Then waits indefinitely for a keystroke, after
# which the service is re-enabled.
#
# When toggling the service off, it stops the service if it's running, and
# sets its startup type to disabled.
#
# Stuff that happens when Windows Update service is disabled:
#  - No notification of new updates
#  - No new updates will be downloaded
#  - A scheduled restart for already downloaded updates will not occur
#  - The "Check for updates" button in the "Update & Security" > "Windows
#    Update" section of the Settings app will report an error and offer a
#    "Retry" button that also won't work until the service is enabled again.
#
# When toggling the service back on, the script sets the service's startup
# type to it's default: manual, but doesn't start the service (it will start
# on it's own as needed).

# Check to be sure we're running as admin, and bail if we're not.
if ( `
    -NOT `
    ( `
        [Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole( `
        [Security.Principal.WindowsBuiltInRole] "Administrator" `
    ) `
) {
    Write-Warning "Pro Tip: This script requires Administrator privileges."
    Break
}

# Windows Update service name
$service = 'wuauserv'
$fields = "Name,StartMode,State"

# Function for getting service status information
function get_service_status {
    return $(
        Get-WmiObject `
            -Query `
            "Select $fields From Win32_Service where Name='$service'" `
        | Select $fields.split(',')
    )
}

# Function for idempotent enable
function enable_service {
    $status = get_service_status
    if ($status.StartMode -eq 'Disabled') {
        Write-Host "    The service is disabled, so enabling it."
        Set-Service $service -StartupType manual
        sleep 2
    }
    Write-Host "    $(get_service_status)"
}

# Function for idempotent disable
function disable_service {
    $status = get_service_status
    if ($status.StartMode -ne 'Disabled') {
        Write-Host "    The service is enabled, disabling it."
        if ($status.State -eq 'Running') {
            Write-Host "    The service is running, stopping it."
            Stop-Service $service
        }
        Set-Service $service -StartupType disabled
        sleep 2
    }
    Write-Host "    $(get_service_status)"
}


# Do The Thing
Write-Host "Disabling..."
disable_service
Write-Host "Service disabled. Press enter when ready to re-enable."

pause

Write-Host "Enabling..."
enable_service
Write-Host "Service enabled."
