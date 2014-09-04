# Motivation

After having written my [post](http://blog.dornea.nu/2014/08/21/howto-debug-android-apks-with-eclipse-and-ddms/) on debugging with Eclipse and DDMS, I wanted to somehow automate those steps. And this is how
ADUS got born. 

Its basically only a BASH script ment to glue things together and make my life easier. Feel free to adapt it to your needs. Pull requests are highly welcome.

# Run 

ADUS is very easy to use. Have a look at the available options:

~~~ shell

            __   ____  _  _  ____  
           / _\ (    \/ )( \/ ___) 
          /    \ ) D () \/ (\___ \ 
          \_/\_/(____/\____/(____/ 

      [A]ndroid [D]ebug [U]tility [S]uite
    
Usage: ./adus.sh <options>
Available options:
 -h                  Print this message
 -b <app_path>           Build new APK from source directory
 -d <app_path>           Dump APK to ./source
 -s <app_path>           Sign APK using test certificate
 -u <app_path>           Unpack APK to ./unpacked
 -q                  Be quite. Deactivate verbosity.
 -0 <app_path>           Dump (-d) and unpack (-u) APK
 -1 <app_path>           Build (-b) and sign (-s)

~~~

# Examples
tbd