:global updateVersion;
:global updateProcess;
:global emailBody;
:global deviceName;
:global emailSubject;

:set $deviceName [/system identity get name];

/system package update;

:log info "System Autoupdate: Check system update started";
check-for-updates;

:if ([get installed-version] != [get latest-version]) do={ 

    :set $updateVersion [get latest-version];
    :log info "System Autoupdate: A new software update is available. Starting update...";

    :set $emailBody "RouterOS on $deviceName device is being updated to the latest version: $updateVersion";
    :set $emailSubject "RouterOS $deviceName Update $updateVersion";

    /system script run system-update-email;

    /system schedule add name="upgrade-on-boot" on-event="/system scheduler remove upgrade-on-boot; :global updateProcess true; :global upgradeProcess false; :global updateVersion \"$updateVersion\"; /system script run system-upgrade;" start-time=startup interval=0;

    :delay 5s;

    /system package update install;
 
} else={

    :log info "System Autoupdate: Current version is up to date";
    :set updateVersion;
    :set updateProcess;

}