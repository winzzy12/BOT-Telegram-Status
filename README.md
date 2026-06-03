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
screen -r send-info-bot
```
CTRL + C (Untuk menghentikan BOT VIA screen) kemudain exit

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

Update Script bot.py
```bash
cat > bot.py << 'EOF'
import os
import re
import time
import psutil
import asyncio
import socket
import subprocess
import requests

from dotenv import load_dotenv
from telegram import Update
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    ContextTypes
)

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
CHAT_ID = int(os.getenv("CHAT_ID"))
SERVER_NAME = os.getenv("SERVER_NAME", "GPU Server")


def progress_bar(percent, length=10):
    filled = int(percent / 100 * length)
    empty = length - filled
    return "█" * filled + "░" * empty


def status_emoji(percent):
    if percent >= 90:
        return "🔴"
    elif percent >= 70:
        return "🟡"
    return "🟢"


def get_public_ip():
    try:
        return requests.get(
            "https://api.ipify.org",
            timeout=5
        ).text.strip()
    except:
        return "Unknown"


def get_uptime():
    uptime = int(time.time() - psutil.boot_time())

    days = uptime // 86400
    hours = (uptime % 86400) // 3600
    minutes = (uptime % 3600) // 60

    return f"{days}d {hours}h {minutes}m"


def get_amd_gpu_info():
    try:
        output = subprocess.check_output(
            ["rocm-smi"],
            text=True,
            stderr=subprocess.DEVNULL
        )

        gpu_infos = []

        for line in output.splitlines():
            line = line.strip()

            if not re.match(r"^\d+\s+", line):
                continue

            cols = line.split()

            try:
                gpu_id = cols[0]

                temp_match = re.search(r'(\d+\.\d+)°C', line)
                temp = temp_match.group(1) if temp_match else "?"

                power_match = re.search(r'(\d+\.\d+)W', line)
                power = power_match.group(1) if power_match else "?"

                percentages = re.findall(r'(\d+)%', line)

                gpu_percent = 0
                vram_percent = 0

                if len(percentages) >= 2:
                    vram_percent = int(percentages[-2])
                    gpu_percent = int(percentages[-1])

                gpu_infos.append(
                    f"🎮 <b>GPU {gpu_id}</b>\n"
                    f"🌡 Temp : {temp}°C\n"
                    f"⚡ Power : {power}W\n\n"
                    f"{status_emoji(gpu_percent)} GPU\n"
                    f"<code>[{progress_bar(gpu_percent)}] {gpu_percent}%</code>\n\n"
                    f"{status_emoji(vram_percent)} VRAM\n"
                    f"<code>[{progress_bar(vram_percent)}] {vram_percent}%</code>"
                )

            except:
                continue

        return "\n\n".join(gpu_infos)

    except Exception:
        return "GPU AMD tidak terdeteksi"


def get_status():
    cpu = psutil.cpu_percent(interval=1)

    mem = psutil.virtual_memory()
    disk = psutil.disk_usage("/")

    ram_used = round(mem.used / (1024**3), 2)
    ram_total = round(mem.total / (1024**3), 2)

    disk_used = round(disk.used / (1024**3), 2)
    disk_total = round(disk.total / (1024**3), 2)

    hostname = socket.gethostname()

    return f"""
🖥️ <b>{SERVER_NAME}</b>
━━━━━━━━━━━━━━━━━━━━

🌐 <b>Public IP</b>
<code>{get_public_ip()}</code>

🖥️ <b>Hostname</b>
<code>{hostname}</code>

⏱️ <b>Uptime</b>
{get_uptime()}

━━━━━━━━━━━━━━━━━━━━
📊 <b>System Monitor</b>

{status_emoji(cpu)} CPU
<code>[{progress_bar(cpu)}] {cpu:.1f}%</code>

{status_emoji(mem.percent)} RAM
<code>[{progress_bar(mem.percent)}] {mem.percent:.1f}%</code>
{ram_used} GB / {ram_total} GB

{status_emoji(disk.percent)} Disk
<code>[{progress_bar(disk.percent)}] {disk.percent:.1f}%</code>
{disk_used} GB / {disk_total} GB

━━━━━━━━━━━━━━━━━━━━
🎮 <b>GPU Monitor</b>

{get_amd_gpu_info()}
"""


async def status_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        get_status(),
        parse_mode="HTML"
    )


async def ping_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("🏓 Pong!")


async def send_status_periodically(app):
    while True:
        try:
            await app.bot.send_message(
                chat_id=CHAT_ID,
                text=get_status(),
                parse_mode="HTML"
            )
        except Exception as e:
            print("Error:", e)

        await asyncio.sleep(300)


if __name__ == "__main__":
    app = ApplicationBuilder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("status", status_command))
    app.add_handler(CommandHandler("ping", ping_command))

    loop = asyncio.get_event_loop()
    loop.create_task(send_status_periodically(app))

    print("✅ Monitoring Bot Running")

    app.run_polling()
EOF
```
Cek Python yang digunakan
```bash
which python3
python3 --version
```

Install requests:
```bash
pip3 install requests
```


