#!/data/data/com.termux/files/usr/bin/bash

echo "=== Push to GitHub ==="
echo ""
echo "This will help you push the repository to GitHub"
echo ""

# Check if remote exists
if git remote | grep -q origin; then
    echo "Remote 'origin' already exists"
    REMOTE_URL=$(git remote get-url origin)
    echo "Current remote: $REMOTE_URL"
else
    echo "No remote repository configured"
    echo ""
    echo "Steps to create GitHub repository:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: termux-shizuku-tools"
    echo "3. Description: Termux tools with Shizuku/rish integration for Android 16+"
    echo "4. Make it public"
    echo "5. DON'T initialize with README (we already have one)"
    echo ""
    read -p "Enter your GitHub username: " GITHUB_USER
    read -p "Repository name (default: termux-shizuku-tools): " REPO_NAME
    REPO_NAME=${REPO_NAME:-termux-shizuku-tools}
    
    echo ""
    echo "Adding remote..."
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

# Check if we have commits
if ! git rev-parse HEAD >/dev/null 2>&1; then
    echo "No commits found. Please commit your changes first."
    exit 1
fi

# Push to GitHub
echo ""
echo "Pushing to GitHub..."
echo "You may need to enter your GitHub credentials or token"
echo ""

# For GitHub token authentication
echo "If using token authentication:"
echo "Username: your-github-username"
echo "Password: your-personal-access-token"
echo ""

# Push
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "Your repository is now available at:"
    echo "https://github.com/$GITHUB_USER/$REPO_NAME"
    echo ""
    echo "Share the link or clone with:"
    echo "git clone https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    echo ""
    echo "❌ Push failed. Common issues:"
    echo "1. Repository doesn't exist on GitHub"
    echo "2. Authentication failed (use personal access token)"
    echo "3. Network issues"
    echo ""
    echo "To use personal access token:"
    echo "1. Go to GitHub Settings > Developer settings > Personal access tokens"
    echo "2. Generate new token with 'repo' scope"
    echo "3. Use token as password when pushing"
fi