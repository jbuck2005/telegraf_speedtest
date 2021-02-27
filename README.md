# telegraf_speedtest

This bash script will help you install the <a href="https://www.speedtest.net/apps/cli">Ookla Speedtest CLI executable</a> and integrate automated speed tests into <a href="https://www.influxdata.com/time-series-platform/telegraf/">Telegraf</a> instance in a Debian / Ubuntu environment.<br><br>
I created this script because I fought through making this integration work and was not satisfied with the resources available (some of which are on Git). My hope is that this bash script makes Speedtest integration effortless, as it should be!<br><br>
To be successful, you will need superuser permissions (ie. sudo) which you should already have.<br><br>
Be sure to read through my script before you execute any part of it. <b>Unless you trust the author, you should never blindly run a script from the internet!!</b> Take the time to read through and question anything that does not appear to be related to your intended purpose (i.e. in this case, installing & configuring a speedtest CLI for telegraf). This is a fantastic way to learn new methods and improve your computer literacy skills. This is how I learn, and I am sure you do too!<br>

## clone & run the installation script: (option #1)

From a command prompt, run the following commands:

    git clone https://github.com/jbuck2005/telegraf_speedtest
    cd telegraf_speedtest
    chmod 700 telegraf_speedtest_setup.sh

## download just the script & run it: (option #2)

From a command prompt, run the following commands:

    wget --content-disposition https://raw.githubusercontent.com/jbuck2005/telegraf_speedtest/main/telegraf_speedtest_setup.sh
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
