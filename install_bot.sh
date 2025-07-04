#!/bin/bash
echo "=============================================="
echo "   🛠  WINZZY 🚀   "
echo "=============================================="
echo ""

# Nama folder project
PROJECT_DIR="info_status_bot"

# Token dan Chat ID ditanya saat instalasi
read -p "Masukkan BOT_TOKEN Telegram: " BOT_TOKEN
read -p "Masukkan CHAT_ID Telegram: " CHAT_ID
read -p "Masukkan SERVER_NAME: " SERVER_NAME

# Update dan install python + pip
echo "🔧 Menginstall dependensi..."
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv

# Buat folder
echo "📁 Membuat folder project..."
mkdir -p ~/$PROJECT_DIR
cd ~/$PROJECT_DIR

# Buat virtualenv
echo "🐍 Membuat virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install library
echo "📦 Menginstall library Python..."
pip install python-telegram-bot==20.7 psutil python-dotenv

# Buat file .env
cat <<EOF > .env
BOT_TOKEN=$BOT_TOKEN
CHAT_ID=$CHAT_ID
SERVER_NAME=$SERVER_NAME
EOF

# Buat file bot.py
cat <<'EOF' > bot.py
import os
import psutil
import asyncio
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import (
    ApplicationBuilder, CommandHandler, ContextTypes
)

load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")
CHAT_ID = os.getenv("CHAT_ID")
SERVER_NAME = os.getenv("SERVER_NAME", "Unnamed Server")

if not BOT_TOKEN or not CHAT_ID:
    print("❌ BOT_TOKEN atau CHAT_ID belum diatur di file .env")
    exit(1)

CHAT_ID = int(CHAT_ID)

def get_status():
    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory()
    ram_used = round(mem.used / (1024 ** 3), 2)
    ram_total = round(mem.total / (1024 ** 3), 2)
    ram_percent = mem.percent

    return (
        f"📡 *Server: {SERVER_NAME}*\n"
        f"🖥️ *Server Status*\n"
        f"🔧 CPU Usage: {cpu}%\n"
        f"🧠 RAM Usage: {ram_percent}%\n"
        f"💾 Used: {ram_used} GB / {ram_total} GB"
    )

async def status_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    status = get_status()
    await update.message.reply_text(status, parse_mode="Markdown")

async def send_status_periodically(app):
    while True:
        try:
            status = get_status()
            await app.bot.send_message(chat_id=CHAT_ID, text=status, parse_mode="Markdown")
        except Exception as e:
            print(f"❌ Error sending message: {e}")
        await asyncio.sleep(300)

if __name__ == "__main__":
    app = ApplicationBuilder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("status", status_command))

    asyncio.get_event_loop().create_task(send_status_periodically(app))

    print("✅ Bot sedang berjalan...")
    app.run_polling()
EOF

echo "✅ Instalasi selesai. Jalankan bot dengan:"
echo "-------------------------------------------"
echo "cd ~/$PROJECT_DIR"
echo "source venv/bin/activate"
echo "python bot.py"
echo "-------------------------------------------"
