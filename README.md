# telegraf_speedtest

This bash script will help you install the Ookla Speedtest CLI executable and integrate automated speed tests into Telegraf.<br>
In order to be successful, you will need superuser permissions (ie. sudo) which you should already have.<br>
<b>Be sure to read through my script before you execute any part of it - never run a script from the internet unless you trust the source!!</b><br>

## clone & run the installation script:

From a command prompt, run the following commands:

    git clone https://github.com/jbuck2005/telegraf_speedtest
    cd telegraf_speedtest
    chmod 700 telegraf_speedtest_setup.sh
    
If you want to make any changes to the configuration, be sure to edit the variables (top of script) by running:

    vi telegraf_speedtest_setup.sh

Of particular interest may be:
````
    config_file="input_speedtest.conf"    # speedtest input configuration file ( default: input_speedtest.conf )
    package="telegraf_speedtest_setup.sh" # this installation & configuration script
    test_interval="5m"                    # default speed test interval - best to keep to 5 minutes and above to avoid being blocked
    test_name="speedtest"                 # this is the " _measurement " you will be referencing in Influx, Grafana, or what have you ( default: speedtest )
````

Once you are content with the configuration, and you have read through the script to ensure that I have not coded anything nefarious into the shell script, execute it  as follows:

    ./telegraf_speedtest_setup.sh
    
