#!/data/data/com.termux/files/usr/bin/bash
# AI-powered system analyzer using rish

source ~/.shizuku_env 2>/dev/null
source ~/.ai_keys 2>/dev/null

if [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$GOOGLE_AI_API_KEY" ]; then
    echo "No AI API keys found. Run: ai setup"
    exit 1
fi

echo "=== AI System Analysis ==="
echo "Gathering system information..."

# Collect data with rish
DATA=""
if command -v rish &> /dev/null; then
    DATA+="=== Installed Apps ===\n"
    DATA+=$(rish -c "pm list packages -3" 2>/dev/null)
    DATA+="\n\n=== System Properties ===\n"
    DATA+=$(rish -c "getprop | grep -E 'version|model|manufacturer'" 2>/dev/null)
    DATA+="\n\n=== Memory Info ===\n"
    DATA+=$(rish -c "dumpsys meminfo | head -20" 2>/dev/null)
    DATA+="\n\n=== Battery Info ===\n"
    DATA+=$(rish -c "dumpsys battery" 2>/dev/null)
else
    DATA="Unable to use rish. Limited data available:\n"
    DATA+=$(getprop 2>/dev/null | head -20)
fi

# Analyze with AI
echo ""
echo "Analyzing with AI..."
echo -e "$DATA" | python ~/claude_cli.py "Analyze this Android system data. Identify any security concerns, unusual apps, or optimization recommendations."
