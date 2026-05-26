#!/usr/bin/env python3
"""
Generate chatbot embedding code for staging/production environments.
"""

import argparse
import json
from pathlib import Path

CHATBOT_JS_TEMPLATE = """
// Auto-generated chatbot embed script
// Environment: {env}
// Generated for CX Agent Studio

(function() {{
  const ENV = "{env}";
  const STUDIO_URL = "{studio_url}";
  const PROJECT_ID = "{project_id}";
  
  console.log(`[Chatbot] Loading from ${{ENV}} environment`);
  
  // Initialize CX Agent Studio widget
  window.CXAgentConfig = {{
    projectId: PROJECT_ID,
    environment: ENV,
    studioUrl: STUDIO_URL,
    enableLogging: true,
    theme: {{
      primaryColor: "#1f2937",
      accentColor: "#3b82f6"
    }}
  }};
  
  // Load the CX Agent Studio embed script
  const script = document.createElement("script");
  script.src = `${{STUDIO_URL}}/embed.js`;
  script.async = true;
  document.head.appendChild(script);
  
  // Send initial greeting after widget loads
  script.onload = function() {{
    setTimeout(() => {{
      if (window.CXAgentWidget) {{
        window.CXAgentWidget.sendInitialMessage("Hi! How can I help you today?");
      }}
    }}, 1000);
  }};
}})();
""".strip()

def generate_chatbot_js(env: str, output: str, studio_url: str, project_id: str = "project-a23a1d99-6703-4119-9d7"):
    """Generate chatbot JS file for given environment."""
    
    js_content = CHATBOT_JS_TEMPLATE.format(
        env=env.upper(),
        studio_url=studio_url,
        project_id=project_id
    )
    
    with open(output, "w") as f:
        f.write(js_content)
    
    print(f"✓ Generated {output} ({len(js_content)} bytes)")
    return True

def main():
    parser = argparse.ArgumentParser(description="Generate chatbot embedding code")
    parser.add_argument("--env", required=True, choices=["staging", "production"])
    parser.add_argument("--output", required=True)
    parser.add_argument("--studio-url", required=True)
    parser.add_argument("--project-id", default="project-a23a1d99-6703-4119-9d7")
    
    args = parser.parse_args()
    
    success = generate_chatbot_js(
        env=args.env,
        output=args.output,
        studio_url=args.studio_url,
        project_id=args.project_id
    )
    
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
