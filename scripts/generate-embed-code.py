#!/usr/bin/env python3
"""
Generate HTML embed code with chat messenger script tags.
This creates the code snippet your team adds to their website.
"""

import argparse
from pathlib import Path

EMBED_TEMPLATE = '''<!-- DFS AI Agent Chatbot Embed -->
<!-- Add this to your website's <head> section: -->
<link rel="stylesheet" href="https://www.gstatic.com/chat-messenger/sdk/prod/v1.16/themes/chat-messenger-default.css">
<link rel="stylesheet" href="https://www.gstatic.com/chat-messenger/sdk/prod/v1.16/themes/chat-messenger-layout.css">
<script defer src="https://www.gstatic.com/chat-messenger/sdk/prod/v1.16/chat-messenger.js"></script>

<!-- Add this to your website's <body> section: -->
<script>
  window.chatConfig = {{
    environment: "{env}",
    appId: "{app_id}",
    projectId: "project-a23a1d99-6703-4119-9d7"
  }};
  
  // Initialize chat messenger when ready
  window.addEventListener('load', function() {{
    if (window.ChatMessenger) {{
      window.ChatMessenger.init(window.chatConfig);
    }}
  }});
</script>

<!-- UI customizations (optional): -->
<!-- Include this script to apply custom styles and fixes -->
<!-- <script src="path/to/chatbot-ui-fixes.js"></script> -->
'''

def generate_embed_code(env: str, app_id: str, output: str):
    """Generate HTML embed code."""
    
    html_content = EMBED_TEMPLATE.format(
        env=env.upper(),
        app_id=app_id
    )
    
    with open(output, "w") as f:
        f.write(html_content)
    
    print(f"✓ Generated {output} ({len(html_content)} bytes)")
    return True

def main():
    parser = argparse.ArgumentParser(description="Generate HTML embed code")
    parser.add_argument("--env", required=True, choices=["dev", "stage", "prod"])
    parser.add_argument("--app-id", required=True, help="CX Agent Studio app ID")
    parser.add_argument("--output", required=True, help="Output file path")
    
    args = parser.parse_args()
    
    success = generate_embed_code(
        env=args.env,
        app_id=args.app_id,
        output=args.output
    )
    
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
