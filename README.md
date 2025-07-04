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
[Unit]
Description=Telegram Bot VPS
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/BOT-Telegram-Akses-VPS
ExecStart=/root/BOT-Telegram-Akses-VPS/venv/bin/python bot.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
Reload systemd & aktifkan service:
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable telegrambot
sudo systemctl start telegrambot
```

Cek Status
```bash
sudo systemctl status telegrambot
```
Cek Running
```bash
journalctl -u telegrambot -f
```
Restart BOT
```bash
sudo systemctl restart telegrambot
```
