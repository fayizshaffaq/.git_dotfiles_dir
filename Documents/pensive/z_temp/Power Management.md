POWER MANAGERMENT
	downlaod and install powertop
sudo pacman -S powertop
	go to the tunable tab to see the bad ones, hogging energy and toggle them to good if they are bad
sudo powertop	enter and up down arrow 
	to make these changes persistant across reboots
powertop --auto-tune
	install tlp and tlp-rdw for wifi and radio like bliuetoth and stuff
sudo pacman -S tlp tlp-rdw
	enable the servcie and restart
sudo systemctl enable tlp.service
	check teh status of the service
sudo systemctl status tlp.service

