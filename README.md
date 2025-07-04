🚀 Cara Installasi
✅ Fitur:
* Bot dikendalikan dengan perintah Telegram /status
* Mengirim info: CPU usage dan RAM usage
* Siapkan TOKEN BOT & CHAT ID

1. Buat Screen Terlebih Dahulu
```bash
screen -S send-info-bot
```
2. Jalankan Script Installasi
```bash
wget https://raw.githubusercontent.com/winzzy12/BOT-Telegram-Status/main/install_bot.sh && chmod +x install_bot.sh && ./install_bot.sh
```
3. Jika sudah memasukan BOT ID & Chat ID, kamu bisa langsung menjalankan:
```bash
cd ~/info_status_bot
source venv/bin/activate
python bot.py
```
4. Done

✅ Jalankan VIA systemd agar bot otomatis berjalan saar server restart
```bash
sudo nano /etc/systemd/system/telegraminfo.service
```

```bash
[Unit]
Description=Telegram Bot Info
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/info_status_bot
ExecStart=/root/info_status_bot/venv/bin/python bot.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
Reload systemd & aktifkan service:
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable telegraminfo
sudo systemctl start telegraminfo
```

Cek Status
```bash
sudo systemctl status telegraminfo
```
Cek Running
```bash
journalctl -u telegraminfo -f
```
Restart BOT
```bash
sudo systemctl restart telegraminfo
```
