### suspend_windows_update.ps1

This script is a tool for temporarily suspending the Windows Update service to
prevent updates from interrupting important or unattended tasks.

#### Motivation

In Windows 10, Microsoft removed the ability to configure Windows Update to
notify the user when new updates were available but not download or install
them until the user takes action to do so. This configuration was ideal for
users who do things where the spontaneous bandwidth usage of update downloads,
the installation prompts that steal window manager focus, or automatic restarts
would spell trouble for an important task.

One can simply disable the Windows Update service while doing one's important
thing, but it's easy to forget to re-enable it and leaving the service disabled
for a long period of time isn't a good idea. You'll end up way behind on
security updates, etc. So you really should make sure you restore the service
to normal once your uninterruptible thing is done.

#### Usage

This script simply disables the update service, pauses for input, then
re-enables the service. This way, you've got a PowerShell window hanging out
waiting for a keystroke while the service is disabled to serve as a reminder,
and you're just one keystroke away from turning it back on.

The script just needs to be run from a PowerShell instance with Administrator
privileges. It takes no arguments.

Stuff that happens while Windows Update service is disabled:
 - No notification of new updates
 - No new updates will be downloaded
 - A scheduled restart for already downloaded updates will not occur
 - The "Check for updates" button in the "Update & Security" > "Windows
   Update" section of the Settings app will report an error and offer a
   "Retry" button that also won't work until the service is enabled again.
