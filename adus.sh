#!/bin/bash


## Prints info log message
## Forked from http://swaeku.github.io/blog/2013/09/14/format-and-print-logs-in-bash-shell-scripts/
##      @1: log level
##      @2: Message
function log() {
    local level=${1?}
    shift
    local code= line="[$(date '+%F %T')] $level: $*"
    if [ -t 2 ]
    then
        case "$level" in
            INFO)   code=36 ;;
            DEBUG)  code=30 ;;
            WARN)   code=33 ;;
            ERROR)  code=31 ;;
            *)      code=37 ;;
         esac
         echo -e "\e[${code}m${line}\e[0m"
     else
         echo "$line"
     fi >&2
}


## Check if command exists
##      @1: command to be checked
##      @return: command path if found, exit if not found
function check_command {
    local cmd_path=`command -v $1`
    if [ "$cmd_path" = "" ]; then
        log ERROR "Couldn't find $1"
        exit 1
    else
        echo $cmd_path
    fi
}

## Configuration stuff

# Dirctories
CWD=$( cd "$( dirname $( readlink "${BASH_SOURCE[0]}" ))" && pwd )
DIR_TOOLS=$CWD/tools
DIR_UNPACK=./unpacked
DIR_SOURCE=./source
DIR_SIGNAPK=$DIR_TOOLS/signapk

# Binaries
BIN_GIT=$(check_command git)
BIN_JAVA=$(check_command java)
BIN_UNZIP=$(check_command unzip)


BIN_APKTOOL=$DIR_TOOLS/apktool/apktool-cli.jar
BIN_SIGNAPK=$DIR_TOOLS/signapk/signapk.jar
BIN_DEX2JAR=$DIR_TOOLS/dex2jar/current/d2j-dex2jar.sh

verbose=1

# -----------------------------------------------------------------------------
## Creates necessary directories
##      @1: Director name
function create_dir {
    if [ ! -d $1 ]
    then
        echo -ne "[INFO] Creating $1 ... \t"
        mkdir $1
        echo -ne "DONE\n"
    fi
}



## Check if file exists
##      @1: file to be checked
##      @return: 0 if true, 1 if false
function check_file {
    if [ -f $1 ]
    then
        return 0
    else
        return 1
    fi
}



# Downloads signing tool from https://github.com/appium/sign
function download_sign_tool {
    log INFO "Downloading APK signing tool ..."
    cmd="git clone https://github.com/appium/sign $DIR_SIGNAPK"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't download APK signing tool."
    else
        log INFO "Success!"
    fi
}


## Signs a APK using a test certificate
##      @1: APK file to be signed
function apk_sign {
    # Create directorie
    create_dir $DIR_TOOLS

    # Check if signapk utility exists
    if ! check_file $BIN_SIGNAPK; then
        download_sign_tool
    fi

    # Sign APK
    signed_apk=`basename $1 .apk`.SIGNED.apk
    log INFO "Signing $1 ..."
    cmd="$BIN_JAVA -jar $BIN_SIGNAPK \
              $DIR_SIGNAPK/testkey.x509.pem \
              $DIR_SIGNAPK/testkey.pk8 \
              $1 \
              $signed_apk"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't sign APK."
    else
        log INFO "Success! $signed_apk is your signed APK."
    fi
}


## Dumps APK usign apktool
##      @1: APK file to be dumped
function apk_dump {
     # Create directorie
    create_dir $DIR_SOURCE

    # Dump APK
    log INFO "Dumping $1 to $DIR_SOURCE ... "
    cmd="java -jar $BIN_APKTOOL d -d -f $1 -o $DIR_SOURCE"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't dump APK."
    else
        log INFO "Success!"
    fi
}

## Builds APK usign apktool
##      @1: New APK file name
function apk_build {
    # Build APK
    log INFO "Building APK from $DIR_SOURCE ... "
    cmd="java -jar $BIN_APKTOOL b -d $DIR_SOURCE -o $1"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't build APK."
    else
        log INFO "Success! $1 is your new APK."
    fi
}


## Unpacks a APK to specified folder
##      @1: APK to unpack
function apk_unpack {
    # Create directory
    create_dir $DIR_UNPACK

    # Unzip APK
    log INFO "Unpacking $1 to $DIR_UNPACK ... "
    cmd="unzip -o -d $DIR_UNPACK $1"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't unpack APK."
    else
        log INFO "Success!"
    fi
}

## Converts classes.dex to jar file
##      @1: dex file
function apk_dex2jar {
    output_file=$DIR_UNPACK/classes-dex2jar.jar
    log INFO "Converting $1 to JAR ... "
    cmd="$BIN_DEX2JAR --force $1 -o $output_file"

    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd

    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't convert DEX file."
    else
        log INFO "Success! Converted file is at $output_file"
    fi
}

## Clean directories
function clean {
    log INFO "Cleaning directories (unpack/source) ..."
    cmd="rm -rf $DIR_UNPACK $DIR_SOURCE"
    
    # Check for verbosity
    if (( ! verbose )); then
        cmd="$cmd > /dev/null 2>&1"
    fi

    eval $cmd
    
    # Check for errors
    if [ $? -ne 0 ]; then
        log ERROR "Couldn't delete directories."
    else
        log INFO "Success! Deleted directories."
    fi
    
}

## Prints this script help description message
function adus_usage {
    echo ""
    echo -ne "            __   ____  _  _  ____  \n\
           / _\ (    \/ )( \/ ___) \n\
          /    \ ) D () \/ (\___ \ \n\
          \_/\_/(____/\____/(____/ \n\

      [A]ndroid [D]ebug [U]tility [S]uite
    "
    echo ""
    echo "Usage: $0 <options>"
    echo "Available options:"
    echo -ne " -h \t\t\t\t Print this message\n"
    echo -ne " -b <app_path> \t\t\t Build new APK from source directory\n"
    echo -ne " -c \t\t\t\t Clean: Delete $DIR_UNPACK and $DIR_SOURCE\n"
    echo -ne " -d <app_path> \t\t\t Dump APK to $DIR_SOURCE\n"
    echo -ne " -s <app_path> \t\t\t Sign APK using test certificate\n"
    echo -ne " -u <app_path> \t\t\t Unpack APK to $DIR_UNPACK\n"
    echo -ne " -x <dex_path> \t\t\t Convert DEX to JAR\n"
    echo -ne " -q \t\t\t\t Be quite. Deactivate verbosity.\n"
    echo -ne " -0 <app_path> \t\t\t Dump (-d) and unpack (-u) APK\n"
    echo -ne " -1 <app_path> \t\t\t Build (-b) and sign (-s)\n"
    exit 1
}
# -----------------------------------------------------------------------------


# Check for arguments
while getopts ":b:d:s:u:x:0:1:q:c" o; do
    case "${o}" in
        h|\?)
            adus_usage
            exit 0
            ;;
        b)
            b=${OPTARG}
            apk_build $b
            ;;
        c)
            clean
            ;;
        d)
            d=${OPTARG}
            apk_dump $d
            ;;
        s)
            s=${OPTARG}
            apk_sign $s
            ;;
        u)
            u=${OPTARG}
            apk_unpack $u
            ;;
        x)
            dex=${OPTARG}
            apk_dex2jar $dex
            ;;
        q)
            verbose=0
            ;;
        0)
            apk=${OPTARG}
            apk_dump $apk
            apk_unpack $apk
            ;;
        1)
            apk_path=${OPTARG}
            apk_build $apk_path
            apk_sign $apk_path
            ;;
        *)
            adus_usage
            ;;
    esac
done

shift $((OPTIND-1))

# EOF
