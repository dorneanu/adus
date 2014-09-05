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
 -h                      Print this message
 -b <app_path>           Build new APK from source directory
 -d <app_path>           Dump APK to ./source
 -s <app_path>           Sign APK using test certificate
 -u <app_path>           Unpack APK to ./unpacked
 -q                      Be quite. Deactivate verbosity.
 -0 <app_path>           Dump (-d) and unpack (-u) APK
 -1 <app_path>           Build (-b) and sign (-s)

~~~

# Examples

### Unpack and dump APK

Given an APK ADUS will dump the contents to `./source` using `apktool`. Afterwards it will unpack the APK (=ZIP file) to `./unpacked` using `unzip`. The `-0` command is actually a combo of `-d` and `-u`.

~~~ shell
# ./adus.sh -0 FakeBanker.apk 
[2014-09-04 20:48:35] INFO: Dumping FakeBanker.apk to ./source ... 
I: Using Apktool 2.0.0-dirty on FakeBanker.apk
I: Loading resource table...
I: Loading resource table...
I: Decoding AndroidManifest.xml with resources...
I: Loading resource table from file: /home/victor/apktool/framework/1.apk
I: Regular manifest package...
I: Decoding file-resources...
I: Decoding values */* XMLs...
I: Baksmaling classes.dex...
I: Copying assets and libs...
I: Copying unknown files...
I: Copying original files...
[2014-09-04 20:48:39] INFO: Success!
[2014-09-04 20:48:39] INFO: Unpacking FakeBanker.apk to ./unpacked ... 
Archive:  FakeBanker.apk
signed by SignApk
  inflating: ./unpacked/META-INF/MANIFEST.MF  
  inflating: ./unpacked/META-INF/CERT.SF  
  inflating: ./unpacked/META-INF/CERT.RSA  
  inflating: ./unpacked/AndroidManifest.xml  
  inflating: ./unpacked/classes.dex  
 extracting: ./unpacked/res/drawable-hdpi/ic_launcher1.png  
 extracting: ./unpacked/res/drawable-hdpi/logo.png  
 extracting: ./unpacked/res/drawable-ldpi/ic_launcher1.png  
 extracting: ./unpacked/res/drawable-mdpi/ic_launcher1.png  
 extracting: ./unpacked/res/drawable-xhdpi/ic_launcher1.png  
  inflating: ./unpacked/res/layout/actup.xml  
  inflating: ./unpacked/res/layout/main.xml  
  inflating: ./unpacked/res/layout/main2.xml  
  inflating: ./unpacked/res/menu/main.xml  
 extracting: ./unpacked/res/raw/blfs.key  
  inflating: ./unpacked/res/raw/config.cfg  
  inflating: ./unpacked/resources.arsc  
[2014-09-04 20:48:39] INFO: Success!
~~~


### Build and sign new APK

ADUS will build a new APK from `./source` and sign it using `signapk`. The `-1` command consists of `-b` and `-s`.

~~~ shell
./adus.sh -1 FakeBanker-NEW.apk
[2014-09-04 20:52:01] INFO: Building APK from ./source ... 

I: Using Apktool 2.0.0-dirty on source
I: Checking whether sources has changed...
I: Smaling smali folder into classes.dex...
I: Checking whether resources has changed...
I: Building resources...
Warning: AndroidManifest.xml already defines debuggable (in http://schemas.android.com/apk/res/android); using existing value in manifest.
I: Building apk file...
[2014-09-04 20:52:06] INFO: Success! FakeBanker-NEW.apk is your new APK.
[2014-09-04 20:52:06] INFO: Signing FakeBanker-NEW.apk ...
[2014-09-04 20:52:06] INFO: Success! FakeBanker-NEW.SIGNED.apk is your signed APK.
~~~

# License

Released under the MIT License. 