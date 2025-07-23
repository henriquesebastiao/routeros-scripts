:global updateVersion;
:global upgradeVersion;
:global updateProcess;
:global upgradeProcess;
:global emailBody;
:global deviceName;
:global emailSubject;

:set $deviceName [/system identity get name];

:local connected false;

:log info "System Autoupdate: Waiting for internet connection...";

:delay 5s;

:do {
    
    :local status [/interface detect-internet state get [find] value-name=state]
    :if ($status != "internet") do={
        :delay 5s;
    } else={
        :set $connected true;
    }

} while ($connected = false);

:log info "System Autoupdate: Internet connection established. Continue update.";

/system script;

:if ($updateProcess = true) do={ 

    :local installedVersion [/system package update get installed-version]

    :if ($updateVersion != $installedVersion) do={

        :set $emailBody "RouterOS on $deviceName device has not been updated.\nInstalled version: $installedVersion\nUpdate version: $updateVersion";
        :set $emailSubject "RouterOS $deviceName Update $updateVersion";
        run system-update-email;
        :log error "System Autoupdate: Version not updated and remains on version: $installedVersion";
        :error;

    }

    :local currentFw [/system routerboard get current-firmware]
    :local upgradeFw [/system routerboard get upgrade-firmware]

    :if ($currentFw = $upgradeFw) do={
        :set $emailBody "Routerboard firmware on $deviceName device doesn't need upgrade and remains on version: $currentFw.";
        :set $emailSubject "Routerboard $deviceName Firmware Upgrade $upgradeFw";
        run system-update-email;
        :log error "System Autoupdate: RouterOS updated but Routerboard firmware doesn't need upgrade and remains on version: $currentFw"
        :error;
    }
    
    :set $emailBody "RouterOS on $deviceName device has been updated. Executing Routerboard upgrade to version $upgradeFw.";
    :set $emailSubject "Routerboard $deviceName Firmware Upgrade $upgradeFw";
    run system-update-email;
    :log info "System Autoupdate: Routerboard firmware being updated to version: $upgradeFw";

    :set $upgradeVersion $upgradeFw;

    /system schedule add name="upgrade-on-boot" on-event="/system scheduler remove upgrade-on-boot; :global updateProcess false; :global upgradeProcess true; :global updateVersion \"$updateVersion\"; :global upgradeVersion \"$upgradeVersion\"; /system script run system-upgrade;" start-time=startup interval=0;

    /system routerboard upgrade;
    :delay 5s;
    /system reboot;

} else={ :if ($upgradeProcess = true) do={

    :local currentFw [/system routerboard get current-firmware]
    :if ($currentFw != $upgradeVersion) do={
        :set $emailBody "Routerboard firmware on $deviceName device has not been upgraded.\nCurrent firmware: $currentFw\nUpgrade firmware: $upgradeVersion";
        :set $emailSubject "Routerboard $deviceName Firmware Upgrade $upgradeVersion";
        run system-update-email;
        :error "System Autoupdate: Routerboard firmware has not been upgraded to version $upgradeFw and remains on version $currentFw";
    } else={
        :set $emailBody "Routerboard firmware on $deviceName device has been upgraded. System update completed.";
        :set $emailSubject "Routerboard $deviceName Firmware Upgrade $currentFw";
        run system-update-email;
        :log info "System Autoupdate: Routerboard firmware has been upgraded to version: $currentFw.";
    }
}}