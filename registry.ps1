#! This script modifier the Windows Registry, use it when installing a new
#! windows computer to not have to fiddle with the registry manually

# How long a key needs to be held until it begins to repeat
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name AutoRepeatDelay -Value 200

# How long between each keystroke repetition
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name AutoRepeatRate -Value 50

# Enable activating window by hovering over it
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ActiveWndTrk -Value 1

# Time for a window to activate after a cursor hovers over it
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ActiveWndTrkTimeout -Value 0

# When a window is activated via cursor hover, do not bring it to the front
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name ActiveWndTrkZorder -Value 0
