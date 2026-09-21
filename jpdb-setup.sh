# !/bin/sh

# Description:
# This script prepares and launches a JsonPowerDB (JPDB) Docker container.
# It checks for the data folder, SSL configuration, sets runtime and main config properties, and finally runs the Docker container with specified memory and swap configurations.

# $1 dockerImageName
# $2 is port to be exposed from docker container.
# $3 is container real memory
# $4 is container swap memory

# Data folder Check
if [ -d "data" ]
then
  echo "data Folder Exists"
  if [ -f "data/jpdbsys/jpdb.on" ]
  then
     echo "Already One Instance is using this Folder. Use another Folder or stop the current JPDB Instance."
     exit
  fi
else
  mkdir "data"
  chmod -R a+rwx "data"
  echo "data Folder Created"
fi

# Checking if ssl.jks file is present
if [ -e "../../jpdb/ssl.jks" ]
then
 cp ../../jpdb/ssl.jks ./data/ssl.jks
else
 echo "SSL not found!"
fi

#PULL Image from Docker Hub, if not available locally
sudo docker pull $1

cd "data"

# Creating runtime-config.properties file
if [ -f "runtime-config.properties" ]
then
echo "runtime-config.properties file exists"
else
touch runtime-config.properties
echo "jpdb.threshold.ram.check=true" >> runtime-config.properties
echo "jpdb.threshold.ram.warning=0.75" >> runtime-config.properties
echo "jpdb.threshold.ram.error=0.85" >> runtime-config.properties
echo "jpdb.ram.check.time=2" >> runtime-config.properties
chmod a+rwx runtime-config.properties
fi

# Creating config.properties file
if [ -f "config.properties" ]
then
echo "config.properties file exists"
else
touch config.properties
echo "jpdb.port=$2" >> config.properties
echo "jpdb.maxThread=128" >> config.properties
echo "jpdb.corsOrigin=*" >> config.properties
echo "jpdb.corsMethods=*" >> config.properties
echo "jpdb.corsHeaders=*" >> config.properties
echo "jpdb.staticFilePath=../bin/public_html" >> config.properties
echo "jpdb.default.gmail.smtp.host=smtp.gmail.com" >> config.properties
echo "jpdb.default.gmail.smtp.port=465" >> config.properties
echo "jpdb.default.gmail.smtp.login=noreply.login2xplore@gmail.com" >> config.properties
echo "jpdb.default.gmail.smtp.appPassword=hgcrpbwwcnbuqafd" >> config.properties
echo "jpdb.keystoreFilePath=./ssl.jks" >> config.properties
echo "jpdb.keystorePassword=pw#l2x05" >> config.properties
echo "jpdb.truststoreFilePath=" >> config.properties
echo "jpdb.truststorePassword=" >> config.properties
chmod a+rwx config.properties
fi

# Creating storage-mode.properties file
if [ -f "storage-mode.properties" ]
then
echo "storage-mode.properties file exists"
else
touch storage-mode.properties
echo "jpdb.storage.type=2" >> storage-mode.properties
echo "jpdb.sxarray.name=sxarr" >> storage-mode.properties
echo "jpdb.sxarray.size=1000000" >> storage-mode.properties
echo "jpdb.sxarray.loadfactor=0.5" >> storage-mode.properties
echo "jpdb.sxarray.recordsPerFile=200000" >> storage-mode.properties
echo "jpdb.sxarray.partitionCache.minCapacity=10" >> storage-mode.properties
echo "jpdb.sxarray.partitionCache.maxCapacity=1000" >> storage-mode.properties
echo "jpdb.sxarray.partitionCache.nodeExpiryTime=36000000" >> storage-mode.properties
echo "jpdb.sxarray.partitionCache.poolCheckTime=600000" >> storage-mode.properties
echo "jpdb.sxarray.rowCache.minCapacity=1000" >> storage-mode.properties
echo "jpdb.sxarray.rowCache.maxCapacity=10000" >> storage-mode.properties
echo "jpdb.sxarray.rowCache.nodeExpiryTime=600000" >> storage-mode.properties
echo "jpdb.sxarray.rowCache.poolCheckTime=90000" >> storage-mode.properties
chmod a+rwx storage-mode.properties
fi

#Running the Container
#sudo docker run --restart=always -p $3:$3 -v $(pwd)/:/home/jpdb/data $1 &d
#sudo docker run -p $3:$3 -v $(pwd):/home/jpdb/data $1 &
# if swap is not enabled in OS then also this command works

# sudo docker run -m 1400m --memory-swap 2800m --restart=on-failure -p $3:$3 -v $(pwd):/home/jpdb/data $1 &

sudo docker run -m $3 --memory-swap $4 --restart=on-failure -p $2:$2 -v $(pwd):/home/jpdb/data $1 &