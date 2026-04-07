#!/data/data/com.termux/files/usr/bin/python
import os
import sys
import google.generativeai as genai

def main():
    api_key = os.environ.get('GOOGLE_AI_API_KEY')
    if not api_key:
        print("Error: Please set GOOGLE_AI_API_KEY environment variable")
        print("export GOOGLE_AI_API_KEY='your-key-here'")
        sys.exit(1)
    
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-pro')
    
    if len(sys.argv) > 1:
        prompt = ' '.join(sys.argv[1:])
    else:
        print("Enter your prompt (Ctrl+D to finish):")
        prompt = sys.stdin.read().strip()
    
    try:
        response = model.generate_content(prompt)
        print(response.text)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
