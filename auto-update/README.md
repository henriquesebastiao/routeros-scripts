# MikroTik RouterOS Autoupdate

This folder contains scripts that allow MikroTik RouterOS devices to keep their operating system, packages, and firmware up to date. Email notifications are sent about all updates and bugs.

This script is based on [timba/routeos-autoupdate](https://github.com/timba/routeros-autoupdate), containing some minor modifications.

## Description

These scripts perform these operations:

- Check if package updates available (same as `System -> Packages` and `Check For Updates`)
- If updates available, send start update notification email
- Initialize packages update
- After updates the device reboots
- On start check if RouterOS updated, and notify this by email
- Initialize firmware upgrade (same as `System -> Routerboard` and `Upgrade`)
- Wait firmware installed and reboot 
- After rebooted, send email notification about update completion

## Prerequisites

Email sending requires valid POP server configuration. You can configure it once using Email Settings of WinBox or WebFig by opening:

`Tools -> Email`

Or use terminal and `/tool email` commands.

## Configuration

### WAN connection

Update process requires reboots after RouterOS and firmware updates. Email notification requires internet connection to send notifications. That's why WAN status check exists in `system-upgrade.rsc` script. The current version of the script detects whether the internet is available through [Detect Internet](https://help.mikrotik.com/docs/spaces/ROS/pages/8323187/Detect+Internet): 

`:local status [/interface detect-internet state get [find] value-name=state]`

### Notification Email Recipient

Script `system-email.rsc` contains email of updates email recipient. Update it it with your email:

`:local to "notification.email@example.com"`

### Upload Scripts

Add scripts using `System -> Scripts` window. Give them names of script files without extensions:

- system-update
- system-upgrade
- system-update-email

### Configure Scheduler

In order to run updates periodically, create one scheduler entry using `System -> Scheduler` window. Give it any name, and set `On Event` property to this command:

`/system script run system-update`

Please note that during RouterOS updates the device will be down and rebooted two times, so take this into consideration when configuring scheduler trigger time. Normal downtime is up to 5 minutes, including waiting for internet connections after reboots. Updates happen only when there are new packages available, otherwise the device stays up without interruptions.