#Virtual Env: https://docs.computecanada.ca/wiki/Python

#Can define parallelism in code.

## CENTRAL MANAGER ##
curl -fsSL https://get.htcondor.org | sudo /bin/bash -s -- --no-dry-run --password "PASSWORD_HERE" --central-manager "172.31.3.228"

## SUBMIT ##
curl -fsSL https://get.htcondor.org | sudo /bin/bash -s -- --no-dry-run --password "PASSWORD_HERE" --submit "172.31.3.228"

## EXECUTE ##
curl -fsSL https://get.htcondor.org | sudo /bin/bash -s -- --no-dry-run --password "PASSWORD_HERE" --execute "172.31.3.228"

# Files for Modeling #
cd /mnt/efs/modeling/
sudo mkdir heart-disease
cd heart-disease
sudo wget http://zahirsher.com/wqd7008/file.csv

# Installing Python to Executors #
sudo yum install -y python3
sudo yum install python-pip
sudo yum update -y

# Change default python to 3.7 #
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2
sudo update-alternatives --config python

# Add Python Environment #
vim ~/.bashrc
export PYTHONPATH="${PYTHONPATH}:/usr/local/bin"

# Install packages #

vim requirements.sh
# requirements.sh
#!/bin/bash
sudo python3 -m pip install pandas
sudo python3 -m pip install xgboost
sudo python3 -m pip install catboost
sudo python3 -m pip install sklearn
sudo python3 -m pip install imblearn
sudo python3 -m pip install seaborn
sudo python3 -m pip install plotly
sudo python3 -m pip install psutil
sudo python3 -m pip install -U kaleido

# set permission to execute #
chmod u+x requirements.sh

# run the script #
./requirements.sh

# to allow writing to, reading from, executing from the EFS
# locate to /mnt then run:
sudo chmod -R 777 efs

#For problems with yum
sudo vi /usr/bin/yum
sudo vi /usr/libexec/urlgrabber-ext-down

# Mounting EFS - persistent
sudo yum install -y amazon-efs-utils
sudo yum install -y nfs-utils
file_system_id_1=fs-0322cd31ddbc67f70
efs_mount_point_1=/mnt/efs/modeling
mkdir -p "${efs_mount_point_1}"
sudo chmod 777 /etc/fstab
test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.us-east-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab

-----------------

sudo systemctl status condor

cd /etc/condor/
cd config.d
cat 01-central-manager.config

#LOGS: cat /var/log/condor/MasterLog

## EXECUTING FIRST JOB

IN THE SUBMIT:
touch sleep.sh #job itself
vim sleep.sh
chmod u+x sleep.sh

touch sleep.sub # submit description
vim sleep.sub

condor_submit sleep.sub #submit job

condor_q #see running jobs - only run in submit node

condor_status #to see status of cpus


## FILE SYSTEM ##

Server Machine:
--------------
mkdir people
cd people
touch zahir
touch jalal
touch jc
echo "smart" > new
echo "lets go" > alex
echo "ey ey ey" > jc
sudo systemctl start nfs-server.service
sudo systemctl status nfs-server.service
sudo vim /etc/exports
/home/ec2-user/Ktry *(rw,sync)
sudo exportfs -arv


Client Machine:
--------------
mkdir students
showmount -e 172.31.81.3
sudo mount -t nfs 172.31.81.3:/home/ec2-user/Ktry kTutorial/
for persistent: echo "172.31.28.186:/home/ec2-user/people     students/  nfs     defaults 0 0">>/etc/fstab

--------

wget http://montage.ipac.caltech.edu/download/Montage_v6.0.tar.gz
tar -zxvf Montage_v6.0.tar.gz
sudo yum install gcc
make
export PATH=$PATH:/home/ec2-user/montage/Montage/bin

 vim .bash_profile ;to make it persistent.

 #cloud-config
package_update: true
package_upgrade: true
runcmd:
- yum install -y amazon-efs-utils
- yum install -y nfs-utils
- file_system_id_1=fs-0322cd31ddbc67f70
- efs_mount_point_1=/mnt/efs/modeling
- mkdir -p "${efs_mount_point_1}"
- test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.us-east-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
- test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
- retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
