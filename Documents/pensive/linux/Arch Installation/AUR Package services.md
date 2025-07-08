40.	enable services.
sudo systemctl enable --now fwupd.service warp-svc.service asusd.service 

systemctl --user enable --now hyprpolkitagent.service