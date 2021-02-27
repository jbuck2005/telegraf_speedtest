##################################################################################################################
# Last Mofidied: 20210227                                                                                        #
##################################################################################################################
# Install Ookla Seedtest CLI client & configure telegraf to accept input                                         #
#                                                                                                                #
# Requires:                                                                                                      #
#	*super user access (via sudo)                                                                            #
#	*working telegraf service                                                                                #
#	*                                                                                                        #
# Installs:                                                                                                      #
#	*installing packages: gnupg1i, apt-transport-https, dirmngr                                              #
#       *installing speedtest client                                                                             #
#		* https://www.speedtest.net/apps/cli                                                             #
# Modifies:                                                                                                      #
#       *add telegraf configuration file to enable speedtest integration                                         #
#       *create .config directory within telegraf directory for storing Ookla license file                       #
#	*directory & file structure becomes:                                                                     #
#		/etc/telegraf                                                                                    #
#			/.config                                                                                 #
#				/oolka                                                                           #
#					/speedtest-cli.json                                                      #
#                                                                                                                #
##################################################################################################################

##################################################################################################################
# define & initialize script variables                                                                           #
##################################################################################################################
currentuser=$(whoami)
hostname=$(hostname)
wrkdir=$(pwd)
telegraf="/etc/telegraf"			# configuration directory for telegraf ( default: /etc/telegraf )
telegraf_conf="$telegraf/telegraf.d"		# additional configuration files directory for telegraf (the target directory for our new config file)
config_file="input_speedtest.conf"		# speedtest input configuration file ( default: input_speedtest.conf )
package="telegraf_speedtest_setup.sh"		# this installation & configuration script
test_interval="5m"				# default speed test interval - best to keep to 5 minutes and above to avoid being blocked
test_name="speedtest"				# this is the " _measurement " you will be referencing in Influx, Grafana, or what have you ( default: speedtest )

echo -e "##################################################################################################################"
echo -e "#                                                                                                                #"
echo -e "#           Ookla speedtest integration into telegraf                                                            #"
echo -e "#                                                                                                                #"
echo -e "##################################################################################################################"

##################################################################################################################
# install speedtest command line interface                                                                       #
##################################################################################################################
echo -e "Adding ookla repository to /etc/apt/sources.list.d/speedtest.list\n"
export INSTALL_KEY=379CE192D401AB61						# this key may be subject to change; for details, visit https://www.speedtest.net/apps/cli
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY	# add requisite key for Ookla package installation
echo -e "Installing gnupg1 apt-transport-https dirmngr\n"
sudo apt-get install gnupg1 apt-transport-https dirmngr				# install supporting packages via apt
echo "deb https://ookla.bintray.com/debian generic main" | sudo tee  /etc/apt/sources.list.d/speedtest.list	# add ookla repository to an apt sources file
sudo apt-get update								# update apt so that newly added repository can be drawn from
echo -e "Removing conflicting speedtest packagei (if it exists)\n"
sudo apt-get remove speedtest-cli						# as per Ookla instructions, other CLI may interfere with operation of official client
echo -e "Installing Ookla speedtest client\n"
sudo apt-get install speedtest							# install the client package from the Ookla repo

##################################################################################################################
# create .config directory within /etc/telegraf and populate it with the Ookla license for speedtest             #
# this step is critical in having the speedtest client actually run & output meaninful data for telegraf the CLI #
# must have a license file in the home directory of the user which runs it; in this case since we will have      #
# telegraf (and therefore the user "telegraf" run the binary as an "exec input" type, we need to have the        #
# license file in telegraf's home direcory (/etc/telegraf)							 #
##################################################################################################################
sudo chmod 777 $telegraf			# make /etc/telegraf world RWX temporarily
echo -e "Running speedtest as telegraf user. Please be sure to accept the license, otherwise the CLI will NOT work"
sudo -u telegraf /usr/bin/speedtest		# have telegraf user execute speedtest to accept license & store in home directory
sudo chmod 755 $telegraf			# restore permissions for /etc/telegraf

##################################################################################################################
# create new telegraf input configuration file in /etc/telegraf/telegraf.d                                       #
# the output of the configuration file will be displayed to remain transparent to the user                       #
##################################################################################################################
echo -e "Adding speedtest configuration to $telegraf_conf/$config_file\n\n"					# inform user of config file creation
echo -e "# $config_file configuration created by $package on $(date +'%Y%m%d')" | sudo tee -a $telegraf_conf/$config_file
echo -e '[[inputs.exec]]' | sudo tee -a $telegraf_conf/$config_file						# define telegraf input as an exec type
echo -e 'commands = ["/usr/bin/speedtest -f json-pretty"]' | sudo tee -a $telegraf_conf/$config_file		# run executable & output using JSON (pretty = human reable) format for ease of integration
echo -e "name_override = $test_name" | sudo tee -a $telegraf_conf/$config_file					# give this metric a meaninful name (defined at top of script)
echo -e 'timeout = "1m"' | sudo tee -a $telegraf_conf/$config_file						# reasonable timeout before telegraf ignores input value
echo -e "interval = \"$test_interval\"" | sudo tee -a $telegraf_conf/$config_file				# $test_interval is defined at top of script
echo -e 'data_format = "json"' | sudo tee -a $telegraf_conf/$config_file					# telegraf should expect JSON formatted data as input
echo -e 'json_string_fields = [ "interface_externalIp",' | sudo tee -a $telegraf_conf/$config_file		# WAN IP address of interface on which the test was run
echo -e '                       "server_name",' | sudo tee -a $telegraf_conf/$config_file			# Human friendly name of the far-end speed test server
echo -e '                       "server_location",' | sudo tee -a $telegraf_conf/$config_file			# location of far-end server
echo -e '                       "server_host",' | sudo tee -a $telegraf_conf/$config_file			# FQDN of far-end server
echo -e '                       "server_ip",' | sudo tee -a $telegraf_conf/$config_file				# IP address of far-end server
echo -e '                       "result_url" ]' | sudo tee -a $telegraf_conf/$config_file			# result URL for historical referencing
echo -e "speedtest configuration is stored in $telegraf_conf/$config_file" | tee -a $wrkdir/speedtest_readme.txt

##################################################################################################################
# restart telegraf to accept the new configuration file                                                          #
##################################################################################################################
echo -e "Restarting telegraf service to include new configuration ( $telegraf_conf/$config_file )"
sudo service telegraf restart
