#!/bin/bash

# एक ही कमांड से – Node.js सर्वर + cloudflared टनल एक साथ

set -e

echo "🚀 लहेँगा हब कैमरा टूल – Cloudflare Tunnel डिप्लॉय"

# 1. निर्भरताएँ जाँचें (Node.js, npm, cloudflared)
if ! command -v node &> /dev/null; then
    echo "❌ Node.js नहीं मिला। कृपया पहले Node.js इंस्टॉल करें (https://nodejs.org)"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm नहीं मिला।"
    exit 1
fi

if ! command -v cloudflared &> /dev/null; then
    echo "📦 cloudflared नहीं मिला, डाउनलोड हो रहा है..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
fi

# 2. Node.js डिपेंडेंसी इंस्टॉल करें (अगर पहले से नहीं)
if [ ! -d "node_modules" ]; then
    echo "📦 npm इंस्टॉल हो रहा है..."
    npm install
fi

# 3. पुराने Node सर्वर को मारें (अगर चल रहा हो)
pkill -f "node server.js" 2>/dev/null || true

# 4. Node.js सर्वर बैकग्राउंड में चलाएँ
echo "🟢 Node सर्वर start हो रहा है (port 3000)..."
node server.js &
SERVER_PID=$!

# 5. सर्वर के चालू होने का इंतज़ार
sleep 2

# 6. cloudflared टनल – localhost:3000 को सार्वजनिक करें
echo "🌍 Cloudflare Tunnel शुरू..."
cloudflared tunnel --url http://localhost:3000 &
CLOUDFLARED_PID=$!

# 7. CTRL+C दबाने पर सब कुछ साफ़ करें
trap "echo '🛑 बंद किया जा रहा...'; kill $SERVER_PID $CLOUDFLARED_PID 2>/dev/null; exit" INT TERM

# 8. यूज़र को URL दिखाएँ (cloudflared खुद से print करता है)
echo ""
echo "✅ टूल लाइव है! ऊपर दिख रहे ‘https://...trycloudflare.com’ URL को खोलें।"
echo "⚠️  टर्मिनल बंद न करें – टनल चालू रखने के लिए इसे खुला छोड़ें।"
echo ""

# 9. हमेशा चालू रखें (जब तक CTRL+C न दबे)
wait
