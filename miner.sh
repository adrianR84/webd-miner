#!/bin/bash

#### COLOR SETTINGS ####
black=$(tput setaf 0 && tput bold)
red=$(tput setaf 1 && tput bold)
green=$(tput setaf 2 && tput bold)
yellow=$(tput setaf 3 && tput bold)
blue=$(tput setaf 4 && tput bold)
magenta=$(tput setaf 5 && tput bold)
cyan=$(tput setaf 6 && tput bold)
white=$(tput setaf 7 && tput bold)
blakbg=$(tput setab 0 && tput bold)
redbg=$(tput setab 1 && tput bold)
greenbg=$(tput setab 2 && tput bold)
yellowbg=$(tput setab 3 && tput bold)
bluebg=$(tput setab 4 && tput dim)
magentabg=$(tput setab 5 && tput bold)
cyanbg=$(tput setab 6 && tput bold)
whitebg=$(tput setab 7 && tput bold)
stand=$(tput sgr0)

### System dialog VARS
showinfo="$green[info]$stand"
showerror="$red[error]$stand"
showexecute="$yellow[running]$stand"
showok="$magenta[OK]$stand"
showdone="$blue[DONE]$stand"
showinput="$cyan[input]$stand"
showwarning="$red[warning]$stand"
showremove="$green[removing]$stand"
shownone="$magenta[none]$stand"
redhashtag="$redbg$white#$stand"
abortte="$cyan[abort to Exit]$stand"
showport="$yellow[PORT]$stand"
##

### GENERAL VARS
getgit=$(if cat /etc/*release | grep -q -o -m 1 Ubuntu; then echo "$(apt-cache policy git | grep Installed | grep none | awk '{print$2}' | sed s'/[()]//g')"; elif cat /etc/*release | grep -q -o -m 1 Debian; then echo "$(apt-cache policy git | grep Installed | grep none | awk '{print$2} | sed s'/[()]//g'')"; elif cat /etc/*release | grep -q -o -m 1 centos; then echo "$(if yum list git | grep -q -o "Available Packages"; then echo "none"; else echo "Installed"; fi)"; fi)
###

#### Dependencies START
function deps(){
if [[ "$getgit" == "(none)" ]]; then
	echo "$showinfo We need to install Git"
	if [[ $(cat /etc/*release | grep -q -o -m 1 Ubuntu) ]]; then sudo apt install -y git; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get install -y git; elif cat /etc/*release | grep -q -o -m 1 centos; then yum install -y git; fi
else
	if [[ "$getgit" == Installed ]]; then
		echo "$showok Git is already installed!"
	else
		if [[ "$getgit" == * ]]; then
			echo "$showok Git is already installed!"
		fi
	fi
fi
}
#### Dependencies check END

deps # call deps function

if cat /etc/*release | grep -q -o -m 1 Ubuntu; then sudo apt update -y; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get update -y; elif cat /etc/*release | grep -q -o -m 1 centos; then sudo yum update -y; fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then sudo apt upgrade -y; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get upgrade -y; elif cat /etc/*release | grep -q -o -m 1 centos; then sudo yum upgrade -y; fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then sudo apt install -y linuxbrew-wrapper; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get install -y linuxbrew-wrapper; fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then sudo apt install -y build-essential; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get install -y build-essential; elif cat /etc/*release | grep -q -o -m 1 centos; then sudo yum group install -y "Development Tools"; fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then sudo apt install -y clang; elif cat /etc/*release | grep -q -o -m 1 Debian; then sudo apt-get install -y clang; elif cat /etc/*release | grep -q -o -m 1 centos; then sudo yum install -y clang; fi

# remove npm install

if cat /etc/*release | grep -q -o -m 1 Ubuntu; then npm install -g node-gyp; elif cat /etc/*release | grep -q -o -m 1 Debian; then npm install -g node-gyp; elif cat /etc/*release | grep -q -o -m 1 centos; then npm install -g node-gyp; fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then npm install pm2 -g --unsafe-perm; elif cat /etc/*release | grep -q -o -m 1 Debian; then npm install pm2 -g --unsafe-perm; elif cat /etc/*release | grep -q -o -m 1 centos; then npm install pm2 -g --unsafe-perm ; fi
#echo "$showexecute Running npm install..." && npm install
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then if [[ $(node --version) ]]; then echo "$showok NVM sourced ok..."; else echo "$showinfo ${red}MANDATORY$stand: execute ${yellow}source ~/.profile$stand"; fi elif cat /etc/*release | grep -q -o -m 1 Debian; then if [[ $(node --version) ]]; then echo "$showok NVM sourced ok..."; else echo "$showinfo ${red}MANDATORY$stand: execute ${yellow}source ~/.profile$stand"; fi elif cat /etc/*release | grep -q -o -m 1 centos; then if [[ $(node --version) ]]; then echo "$showok NVM sourced ok..."; else echo "$showinfo ${red}MANDATORY$stand: execute ${yellow}source ~/.bash_profile$stand"; fi fi
if cat /etc/*release | grep -q -o -m 1 Ubuntu; then echo "$showinfo Run ${red}source ~/.profile$stand before stating miner."; elif cat /etc/*release | grep -q -o -m 1 Debian; then echo "$showinfo Run ${red}source ~/.profile$stand before starting miner."; elif cat /etc/*release | grep -q -o -m 1 centos; then echo "$showinfo Run ${red}source ~/.bash_profile$stand before starting miner."; fi


function set_cputhreads() {
    echo -e
    read -r -e -p "$showinput How many CPU_THREADS do you want to use? (your pc has ${green}$(nproc)$stand): " setcputhreads
    echo -e

    if [[ $setcputhreads == [nN] ]]; then
            echo -e "$showinfo OK..."

    elif [[ $setcputhreads =~ [[:digit:]] ]]; then

        if [[ $(grep "CPU_MAX:" $get_const_global | cut -d ',' -f1 | awk '{print $2}') == "$setcputhreads" ]]; then
            echo "$showinfo ${yellow}$(grep "CPU_MAX:" $get_const_global | cut -d ',' -f1)$stand is already set."
        else
            echo "$showexecute Setting terminal CPU_MAX to ${yellow}$setcputhreads$stand" && sed -i -- "s/CPU_MAX: $(grep "CPU_MAX:" $get_const_global | cut -d ',' -f1 | awk '{print $2}')/CPU_MAX: $setcputhreads/g" $get_const_global && echo "$showinfo Result: $(grep "CPU_MAX:" $get_const_global | cut -d ',' -f1)"
        fi

    elif [[ $setcputhreads == * ]]; then
        echo -e "$showerror Possible options are: digits or nN to abort." && set_cputhreads
    fi
}

rm -rf webd-miner && git clone https://github.com/adrianR84/webd-miner.git webd-miner
get_const_global="webd-miner/src/consts/const_global.js"

set_cputhreads
#echo 1 | set_cputhreads

cd webd-miner/dist_bundle/argon2-cpu-miner/ && mkdir ../CPU && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make && cp libargon2.so libargon2.so.1 ../../../ && cp cpu-miner ../../CPU/ && cd ../../../ && rm -rf dist_bundle/argon2-cpu-miner && npm install

echo -e
echo -e "$showinfo Webdollar pool miner installed."
#echo -e "$showinfo Execute the following commands if you want to start the BACM pool miner in screen."
#echo -e "$showinfo Create new screen: cd bacm-miner && screen -S bacm-miner"
echo -e "$showinfo cd webd-miner"
echo -e "$showinfo Start the miner: npm run commands"
echo -e

