JOURNALCTL
	to see all the erros on your current boot by priority
journalctl -b -p err..warning
	logs around a certain time frame / timestamp
journalctl -b --since "07:16:40" --until "07:16:45"

