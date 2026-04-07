#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  📥 CODEY-V2 MODEL DOWNLOADER
#  Downloads the 7B Coder, 0.5B Planner, and Embed models.
# ============================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📥 Starting Codey-v2 Model Download...${NC}"

# Create directories
mkdir -p ~/models/qwen2.5-coder-7b
mkdir -p ~/models/qwen2.5-0.5b
mkdir -p ~/models/nomic-embed

# 1. nomic-embed-text-v1.5 (Port 8082)
echo -e "\n${YELLOW}[1/3] Downloading nomic-embed-text-v1.5 (80MB)...${NC}"
if [ ! -f ~/models/nomic-embed/nomic-embed-text-v1.5.Q4_K_M.gguf ]; then
    wget -O ~/models/nomic-embed/nomic-embed-text-v1.5.Q4_K_M.gguf \
        https://huggingface.co/nomic-ai/nomic-embed-text-v1.5-GGUF/resolve/main/nomic-embed-text-v1.5.Q4_K_M.gguf?download=true
else
    echo "  ✅ nomic-embed already exists"
fi

# 2. Qwen2.5-0.5B-Instruct (Port 8081 - Planner)
echo -e "\n${YELLOW}[2/3] Downloading Qwen2.5-0.5B-Instruct (400MB)...${NC}"
if [ ! -f ~/models/qwen2.5-0.5b/planner-codey.gguf ]; then
    wget -O ~/models/qwen2.5-0.5b/planner-codey.gguf \
        https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q8_0.gguf?download=true
else
    echo "  ✅ 0.5B Planner already exists"
fi

# 3. Qwen2.5-Coder-7B-Instruct (Port 8080 - Main Agent)
echo -e "\n${YELLOW}[3/3] Downloading Qwen2.5-Coder-7B-Instruct (4.7GB)...${NC}"
echo -e "${YELLOW}⚠️  This is a large file. Ensure you have enough space and a stable connection.${NC}"
if [ ! -f ~/models/qwen2.5-coder-7b/qwen2.5-coder-7b-instruct-q4_k_m.gguf ]; then
    wget -O ~/models/qwen2.5-coder-7b/qwen2.5-coder-7b-instruct-q4_k_m.gguf \
        https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf?download=true
else
    echo "  ✅ 7B Coder already exists"
fi

echo -e "\n${GREEN}══════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ DOWNLOAD COMPLETE!${NC}"
echo -e "${GREEN}  Run 'codeyd2 start' to boot the models.${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
