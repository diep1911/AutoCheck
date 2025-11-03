# -*- coding: utf-8 -*-
#!/usr/bin/env python3
import os
import sys
import logging
from telegram import Update, InputFile, ReplyKeyboardMarkup
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, ContextTypes, filters
from datetime import datetime, date
from io import BytesIO
import pandas as pd
import sqlite3  # Có sẵn trong Python, không cần cài
import pytz
from flask import Flask
import threading

# ====== Cấu hình logging ======
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

# ====== Flask app để giữ service alive ======
app = Flask(__name__)

@app.route('/')
def home():
    return "🤖 Bot Quản Lý Ca Làm Việc đang chạy 24/7!"

@app.route('/health')
def health():
    return "✅ Bot healthy - " + datetime.now(pytz.timezone("Asia/Ho_Chi_Minh")).strftime("%Y-%m-%d %H:%M:%S")

@app.route('/ping')
def ping():
    return "pong"

# ====== Cấu hình cơ bản ======
BOT_TOKEN = os.environ.get('BOT_TOKEN', "8283660799:AAGlezM-cifmyKHkFdIwDZp4pSCRDzgmd-0")
DB_PATH = "shifts.db"
LOCAL_TZ = pytz.timezone("Asia/Ho_Chi_Minh")

# ====== Khởi tạo database ======
def init_db():
    try:
        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE IF NOT EXISTS shifts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER,
                    shift_date TEXT,
                    start_ts TEXT,
                    end_ts TEXT,
                    duration REAL
                )
            """)
            conn.commit()
            logging.info("✅ Database initialized successfully")
    except Exception as e:
        logging.error(f"❌ Database initialization failed: {e}")

# ====== Tạo bàn phím nhanh ======
def main_keyboard():
    keyboard = [
        ["🕐 Vào ca", "🕛 Ra ca"],
        ["📋 Trạng thái", "📤 Xuất Excel"]
    ]
    return ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

# ====== Các hàm xử lý command ======
async def batdau(update: Update, context: ContextTypes.DEFAULT_TYPE):
    txt = (
        "Xin chào! Tôi là bot ghi nhận ca làm.\n"
        "Chọn thao tác bằng nút bên dưới hoặc gõ lệnh:\n"
        "/vao - vào ca\n"
        "/ra - ra ca\n"
        "/trangthai - xem hôm nay\n"
        "/xuatexcel YYYY-MM - xuất file Excel\n"
        "/baocao YYYY-MM - báo cáo tháng\n"
    )
    await update.message.reply_text(txt, reply_markup=main_keyboard())

async def vao(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        user_id = update.effective_user.id
        now = datetime.now(LOCAL_TZ)
        shift_date = now.date().isoformat()

        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("SELECT id FROM shifts WHERE user_id=? AND end_ts IS NULL", (user_id,))
            if cur.fetchone():
                await update.message.reply_text("❌ Bạn đã vào ca rồi, hãy kết thúc ca trước khi vào ca mới.")
                return
            cur.execute("INSERT INTO shifts (user_id, shift_date, start_ts) VALUES (?,?,?)",
                        (user_id, shift_date, now.isoformat()))
            conn.commit()
        await update.message.reply_text(f"✅ Đã ghi giờ vào: {now.strftime('%H:%M:%S')}", reply_markup=main_keyboard())
    except Exception as e:
        logging.error(f"Error in vao: {e}")
        await update.message.reply_text("❌ Có lỗi xảy ra, vui lòng thử lại.")

async def ra(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        user_id = update.effective_user.id
        now = datetime.now(LOCAL_TZ)

        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("SELECT id, start_ts FROM shifts WHERE user_id=? AND end_ts IS NULL ORDER BY id DESC LIMIT 1", (user_id,))
            row = cur.fetchone()
            if not row:
                await update.message.reply_text("❌ Bạn chưa có ca nào đang mở.")
                return
            shift_id, start_ts = row
            start_dt = datetime.fromisoformat(start_ts)
            duration = (now - start_dt).total_seconds() / 3600
            cur.execute("UPDATE shifts SET end_ts=?, duration=? WHERE id=?",
                        (now.isoformat(), round(duration, 2), shift_id))
            conn.commit()
        await update.message.reply_text(f"🏁 Đã kết thúc ca. Tổng thời gian: {duration:.2f} giờ.", reply_markup=main_keyboard())
    except Exception as e:
        logging.error(f"Error in ra: {e}")
        await update.message.reply_text("❌ Có lỗi xảy ra, vui lòng thử lại.")

async def trangthai(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        user_id = update.effective_user.id
        today = date.today().isoformat()

        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("SELECT start_ts, end_ts, duration FROM shifts WHERE user_id=? AND shift_date=? ORDER BY id", (user_id, today))
            rows = cur.fetchall()

        if not rows:
            await update.message.reply_text("📅 Hôm nay bạn chưa có ca nào.", reply_markup=main_keyboard())
            return

        lines = [f"📋 Ca làm ngày {today}:"]
        for i, (st, ed, du) in enumerate(rows, start=1):
            st_str = datetime.fromisoformat(st).strftime("%H:%M") if st else "-"
            ed_str = datetime.fromisoformat(ed).strftime("%H:%M") if ed else "-"
            du_str = f"{du:.2f} giờ" if du else "-"
            lines.append(f"{i}. {st_str} - {ed_str} ({du_str})")

        await update.message.reply_text("\n".join(lines), reply_markup=main_keyboard())
    except Exception as e:
        logging.error(f"Error in trangthai: {e}")
        await update.message.reply_text("❌ Có lỗi xảy ra, vui lòng thử lại.")

async def xuatexcel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        user_id = update.effective_user.id
        args = context.args
        if not args:
            await update.message.reply_text("⚠️ Dùng: /xuatexcel YYYY-MM (ví dụ: /xuatexcel 2025-11)", reply_markup=main_keyboard())
            return

        try:
            year, month = map(int, args[0].split('-'))
        except Exception:
            await update.message.reply_text("⚠️ Sai định dạng, ví dụ: /xuatexcel 2025-11", reply_markup=main_keyboard())
            return

        ym_prefix = f"{year:04d}-{month:02d}"
        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("SELECT shift_date, start_ts, end_ts, duration FROM shifts WHERE user_id=? AND shift_date LIKE ? ORDER BY shift_date", (user_id, ym_prefix + "%"))
            rows = cur.fetchall()

        if not rows:
            await update.message.reply_text("📭 Không có dữ liệu trong tháng này.", reply_markup=main_keyboard())
            return

        data = []
        for shift_date, st, ed, du in rows:
            data.append({
                "Ngày": shift_date,
                "Giờ vào": datetime.fromisoformat(st).strftime("%H:%M") if st else "",
                "Giờ ra": datetime.fromisoformat(ed).strftime("%H:%M") if ed else "",
                "Tổng giờ": du or 0
            })

        df = pd.DataFrame(data)
        total_hours = df["Tổng giờ"].sum()
        df.loc[len(df.index)] = {"Ngày": "TỔNG CỘNG", "Tổng giờ": total_hours}

        output = BytesIO()
        with pd.ExcelWriter(output, engine="openpyxl") as writer:
            df.to_excel(writer, index=False)
        output.seek(0)

        filename = f"Ca_lam_{year}-{month:02d}.xlsx"
        await update.message.reply_document(InputFile(output, filename=filename),
            caption=f"📄 Đã xuất file {filename}\nTổng giờ làm: {total_hours:.2f} giờ",
            reply_markup=main_keyboard())
    except Exception as e:
        logging.error(f"Error in xuatexcel: {e}")
        await update.message.reply_text("❌ Có lỗi khi xuất Excel, vui lòng thử lại.")

async def baocao(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        user_id = update.effective_user.id
        args = context.args
        if not args:
            await update.message.reply_text("⚠️ Dùng: /baocao YYYY-MM (ví dụ: /baocao 2025-11)", reply_markup=main_keyboard())
            return

        try:
            year, month = map(int, args[0].split("-"))
        except:
            await update.message.reply_text("⚠️ Định dạng sai, ví dụ: /baocao 2025-11", reply_markup=main_keyboard())
            return

        ym_prefix = f"{year:04d}-{month:02d}"
        with sqlite3.connect(DB_PATH) as conn:
            cur = conn.cursor()
            cur.execute("SELECT shift_date, duration FROM shifts WHERE user_id=? AND shift_date LIKE ?", (user_id, ym_prefix + "%"))
            rows = cur.fetchall()

        if not rows:
            await update.message.reply_text("📭 Không có dữ liệu tháng này.", reply_markup=main_keyboard())
            return

        total = sum(d or 0 for _, d in rows)
        lines = [f"📅 Báo cáo tháng {year}-{month:02d}:"]
        for shift_date, dur in rows:
            lines.append(f"  • {shift_date}: {dur or 0:.2f} giờ")
        lines.append(f"\n🕒 Tổng cộng: {total:.2f} giờ")

        await update.message.reply_text("\n".join(lines), reply_markup=main_keyboard())
    except Exception as e:
        logging.error(f"Error in baocao: {e}")
        await update.message.reply_text("❌ Có lỗi xảy ra, vui lòng thử lại.")

async def on_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        text = update.message.text.strip()

        if text == "🕐 Vào ca":
            await vao(update, context)
        elif text == "🕛 Ra ca":
            await ra(update, context)
        elif text == "📋 Trạng thái":
            await trangthai(update, context)
        elif text == "📤 Xuất Excel":
            now = datetime.now()
            context.args = [f"{now.year}-{now.month:02d}"]
            await xuatexcel(update, context)
        else:
            user = update.effective_user.first_name or "bạn"
            await update.message.reply_text(
                f"Xin chào {user}! Hãy chọn thao tác bằng các nút bên dưới.",
                reply_markup=main_keyboard()
            )
    except Exception as e:
        logging.error(f"Error in on_message: {e}")

# ====== Chạy Flask server ======
def run_flask():
    try:
        port = int(os.environ.get('PORT', 8080))
        app.run(host='0.0.0.0', port=port, debug=False)
    except Exception as e:
        logging.error(f"Flask server error: {e}")

# ====== Main ======
def main():
    logging.info("🚀 Đang khởi động Bot Quản Lý Ca Làm...")
    
    try:
        init_db()
        
        # Chạy Flask trong thread riêng
        flask_thread = threading.Thread(target=run_flask)
        flask_thread.daemon = True
        flask_thread.start()
        
        # Khởi tạo và chạy bot Telegram
        application = ApplicationBuilder().token(BOT_TOKEN).build()

        application.add_handler(CommandHandler("batdau", batdau))
        application.add_handler(CommandHandler("vao", vao))
        application.add_handler(CommandHandler("ra", ra))
        application.add_handler(CommandHandler("trangthai", trangthai))
        application.add_handler(CommandHandler("xuatexcel", xuatexcel))
        application.add_handler(CommandHandler("baocao", baocao))
        application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, on_message))

        logging.info("🤖 Bot đang chạy...")
        application.run_polling()
        
    except Exception as e:
        logging.error(f"❌ Bot failed to start: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
