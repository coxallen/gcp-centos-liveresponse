#!/bin/bash

# Set-up
mkdir /tmp/liveresponse

# T1059 - Command-Line Interface
mkdir /tmp/liveresponse/T1059

## Collect secure log
cp /var/log/secure* /tmp/liveresponse/T1059/.

## Collect .bash_history files for all users with home directories
cd /home
for FOLDER in *; do
    if [ -f "$FOLDER/.bash_history" ]; then
        cp $FOLDER/.bash_history /tmp/liveresponse/T1059/history_$FOLDER.txt
    fi
done
if [ -f "/root/.bash_history" ]; then
        cp /root/.bash_history /tmp/liveresponse/T1059/history_root.txt
fi

# T1168 - Local Job Scheduling
mkdir /tmp/liveresponse/T1168

## Collect cron.daily file listing
ls -la /etc/cron.daily > /tmp/liveresponse/T1168/cron.daily_listing.txt

## Get hashes for each of the cron.daily files
touch /tmp/liveresponse/T1168/cron.daily_hashes.txt
for TASK in /etc/cron.daily/*; do
    if [ -f $TASK ]; then
        sha256sum $TASK >> /tmp/liveresponse/T1168/cron.daily_hashes.txt
    fi
done

# T1064 - Scripting
mkdir /tmp/liveresponse/T1064

## Get executable files from writeable directories
find /tmp /var/tmp /home -executable -type f > /tmp/liveresponse/T1064/writeable_executables.txt

# T1156 - .bash_profile and .bashrc
mkdir /tmp/liveresponse/T1156

## Collect .bash_profile and .bashrc files and hashes from all users with home directories
cd /home
touch /tmp/liveresponse/T1156/bash_hashes.txt
for FOLDER in *; do
    echo $FOLDER >> /tmp/liveresponse/T1156/bash_hashes.txt
    if [ -f "$FOLDER/.bash_profile" ]; then
        cp $FOLDER/.bash_profile /tmp/liveresponse/T1156/bash_profile_$FOLDER.txt
        sha256sum $FOLDER/.bash_profile >> /tmp/liveresponse/T1156/bash_hashes.txt
    fi
    if [ -f "$FOLDER/.bashrc" ]; then
        cp $FOLDER/.bashrc /tmp/liveresponse/T1156/bashrc_$FOLDER.txt
        sha256sum $FOLDER/.bashrc >> /tmp/liveresponse/T1156/bash_hashes.txt
    fi
    echo >> /tmp/liveresponse/T1156/bash_hashes.txt
done
echo "root" >> /tmp/liveresponse/T1156/bash_hashes.txt
if [ -f "/root/.bash_profile" ]; then
    cp /root/.bash_profile /tmp/liveresponse/T1156/bash_profile_root.txt
    sha256sum /root/.bash_profile >> /tmp/liveresponse/T1156/bash_hashes.txt
fi
if [ -f "/root/.bashrc" ]; then
    cp /root/.bashrc /tmp/liveresponse/T1156/bashrc_root.txt
    sha256sum /root/.bashrc >> /tmp/liveresponse/T1156/bash_hashes.txt
fi


# T1136 - Create Account
mkdir /tmp/liveresponse/T1136

## Copy /etc/passwd
cp /etc/passwd /tmp/liveresponse/T1136/etc_passwd.txt

## Check for evidence of instance metadata tampering
grep -r "gcloud\.compute\.instances\.add-metadata" /home /root | grep "metadata-from-file" | grep "ssh-keys" > /tmp/liveresponse/T1136/instance_metadata_tamper.txt

# T1501 - Systemd Service
mkdir /tmp/liveresponse/T1501

## Collect a live service listing
systemctl list-units --type=service -all > /tmp/liveresponse/T1501/live_service_list.txt

## Collect MITRE-recommended file listings
ls -la /etc/systemd/system > /tmp/liveresponse/T1501/etc_systemd_listing.txt
ls -la /usr/lib/systemd/system > /tmp/liveresponse/T1501/usr_lib_systemd_listing.txt
cd /home
for FOLDER in *; do
    if [ -d "$FOLDER/.config/systemd/user" ]; then
        ls -la $FOLDER/.config/systemd/user > /tmp/liveresponse/T1501/config_systemd_listing_$FOLDER.txt
    fi
done

# T1018 - Remote System Discovery / T1046 - Network Service Scanning
mkdir /tmp/liveresponse/T1046

## Collect the gcloud logs
cd /home
for FOLDER in *; do
    if [ -d "$FOLDER/.config/gcloud/logs" ]; then
        mkdir /tmp/liveresponse/T1046/gcloud_logs_$FOLDER
        cp -r $FOLDER/.config/gcloud/logs/* /tmp/liveresponse/T1046/gcloud_logs_$FOLDER/.
    fi
done
if [ -d "/root/.config/gcloud/logs" ]; then
    mkdir /tmp/liveresponse/T1046/gcloud_logs_root
    cp -r /root/.config/gcloud/logs/* /tmp/liveresponse/T1046/gcloud_logs_root/.
fi


# T1530 - Data from Cloud Storage Object
mkdir /tmp/liveresponse/T1530

## Check whether each user has a .gsutil folder
cd /home
for FOLDER in *; do
    if [ -d "$FOLDER/.gsutil" ]; then
        ls -al $FOLDER/.gsutil > /tmp/liveresponse/T1530/gsutil_present_$FOLDER.txt
    fi
done
if [ -d "/root/.gsutil" ]; then
    ls -al /root/.gsutil > /tmp/liveresponse/T1530/gsutil_present_root.txt
fi