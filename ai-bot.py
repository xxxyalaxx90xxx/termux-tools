#!/data/data/com.termux/files/usr/bin/python
"""
🤖 AI BOT - Terminal AI Chatbot
Schneller AI-Chat direkt im Terminal!
"""

import os
import sys
import json
import urllib.request
import urllib.error
from datetime import datetime

# Colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
MAGENTA = '\033[0;35m'
RED = '\033[0;31m'
NC = '\033[0m'

def print_banner():
    print(f"{CYAN}╔══════════════════════════════════════════════════════╗{NC}")
    print(f"{CYAN}║          🤖  AI TERMINAL CHATBOT  🤖               ║{NC}")
    print(f"{CYAN}║   Powered by Free AI APIs                            ║{NC}")
    print(f"{CYAN}╚══════════════════════════════════════════════════════╝{NC}")
    print()

def chat_with_groq(message, history=None):
    """Chat with Groq's free API (Llama, Mixtral, etc.)"""
    api_key = os.environ.get("GROQ_API_KEY", "")
    if not api_key:
        print(f"\n{YELLOW}⚠️  GROQ_API_KEY nicht gesetzt!{NC}")
        print(f"{YELLOW}📝 Hol dir einen kostenlosen Key: https://console.groq.com/keys{NC}")
        print(f"{YELLOW}🔧 Dann: export GROQ_API_KEY='dein-key-hier'{NC}")
        return None

    messages = history or []
    messages.append({"role": "user", "content": message})

    payload = json.dumps({
        "model": "llama-3.3-70b-versatile",
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 2048
    }).encode('utf-8')

    req = urllib.request.Request(
        "https://api.groq.com/openai/v1/chat/completions",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            data = json.loads(response.read().decode())
            reply = data["choices"][0]["message"]["content"]
            messages.append({"role": "assistant", "content": reply})
            return reply, messages
    except urllib.error.URLError as e:
        print(f"\n{RED}❌ Netzwerkfehler: {e}{NC}")
        return None
    except Exception as e:
        print(f"\n{RED}❌ Fehler: {e}{NC}")
        return None

def chat_with_openrouter(message, history=None):
    """Chat with OpenRouter (multiple free models)"""
    api_key = os.environ.get("OPENROUTER_API_KEY", "")
    if not api_key:
        print(f"\n{YELLOW}⚠️  OPENROUTER_API_KEY nicht gesetzt!{NC}")
        print(f"{YELLOW}📝 Hol dir einen Key: https://openrouter.ai/keys{NC}")
        return None

    messages = history or []
    messages.append({"role": "user", "content": message})

    payload = json.dumps({
        "model": "meta-llama/llama-3.3-70b-instruct",
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 2048
    }).encode('utf-8')

    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/chat/completions",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
            "HTTP-Referer": "https://termux.ai",
            "X-Title": "AI Terminal Bot"
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            data = json.loads(response.read().decode())
            reply = data["choices"][0]["message"]["content"]
            messages.append({"role": "assistant", "content": reply})
            return reply, messages
    except Exception as e:
        print(f"\n{RED}❌ Fehler: {e}{NC}")
        return None

def save_chat_history(history, filename="ai-chat-history.json"):
    """Save chat history"""
    with open(os.path.expanduser(f"~/{filename}"), 'w') as f:
        json.dump(history, f)

def load_chat_history(filename="ai-chat-history.json"):
    """Load chat history"""
    try:
        with open(os.path.expanduser(f"~/{filename}"), 'r') as f:
            return json.load(f)
    except:
        return []

def main():
    print_banner()

    # Select AI provider
    print(f"{GREEN}Wähle dein AI-Modell:{NC}")
    print(f"  [1] 🔥 Groq (Llama 3.3 70B) - Schnell")
    print(f"  [2] 🌐 OpenRouter (Llama 70B) - Stabil")
    print(f"  [3] ❌ Beenden")
    print()

    choice = input("👉 Wahl: ").strip()

    if choice == "3":
        print(f"\n{CYAN}👋 AI Chat beendet!{NC}")
        return

    # Load history
    history = load_chat_history()
    print(f"\n{GREEN}💬 Chat gestartet! (Tippe '/exit' zum Beenden, '/clear' zum Löschen){NC}")
    print(f"{'─' * 50}")

    while True:
        try:
            user_input = input(f"\n{MAGENTA}Du{NC}: ").strip()
        except (KeyboardInterrupt, EOFError):
            print(f"\n\n{CYAN}👋 Bis später!{NC}")
            break

        if user_input.lower() in ('/exit', '/quit', '/bye'):
            print(f"\n{CYAN}👋 AI Chat beendet!{NC}")
            break

        if user_input.lower() == '/clear':
            history = []
            save_chat_history([], "ai-chat-history.json")
            print(f"\n{GREEN}💬 Chat-Verlauf gelöscht!{NC}")
            continue

        if user_input.lower() == '/history':
            print(f"\n{GREEN}📜 Letzte Nachrichten:{NC}")
            for msg in history[-6:]:
                role = "🤖 AI" if msg["role"] == "assistant" else "👤 Du"
                print(f"  {role}: {msg['content'][:100]}...")
            continue

        if not user_input:
            continue

        # Get AI response
        print(f"\n{YELLOW}🤖 Denkt nach...{NC}")

        if choice == "1":
            result = chat_with_groq(user_input, history)
        elif choice == "2":
            result = chat_with_openrouter(user_input, history)
        else:
            print(f"{RED}❌ Ungültige Wahl!{NC}")
            break

        if result:
            reply, history = result
            save_chat_history(history, "ai-chat-history.json")
            print(f"\n{CYAN}🤖 AI{NC}: {reply}")
        else:
            print(f"{RED}❌ Keine Antwort erhalten. Prüfe deinen API-Key!{NC}")

if __name__ == "__main__":
    main()
