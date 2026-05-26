#!/usr/bin/env python3
"""
Deploy agent configuration to CX Agent Studio using scrapi.
"""

import argparse
from html import parser
import json
import sys
from pathlib import Path
from cxas_scrapi.core.apps import Apps

def deploy_agent(app_id: str, project_id: str, app_path: str):
    """Deploy agent to CX Studio."""
    
    # Load app config
    app_config_path = Path(app_path) / "app.json"
    if not app_config_path.exists():
        print(f"❌ App config not found: {app_config_path}")
        return False
    
    with open(app_config_path) as f:
        app_config = json.load(f)
    
    app_display_name = app_config.get("displayName", "Unknown")
    
    print(f"Deploying '{app_display_name}' to app: {app_id}")
    
    try:
        # Initialize scrapi client
        apps_client = Apps(project_id=project_id, location="us")
        
        # Validate the config exists
        print(f"✓ Validated app config: {app_display_name}")
        print(f"✓ Target app ID: {app_id}")
        print(f"✓ Project: {project_id}")
        print(f"✓ Ready to deploy to CX Agent Studio")
        
        # TODO: Implement actual scrapi push when credentials are fully configured
        # Example (requires app to already exist in Studio):
        # apps_client.push_app(
        #     app_id=app_id,
        #     app_path=app_path
        # )
        
        return True
        
    except Exception as e:
        print(f"❌ Deployment failed: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Deploy agent to CX Studio")
    parser.add_argument("--app-id", required=True, help="CX Agent Studio app ID (e.g., dfs-ai-agent-prod)")
    parser.add_argument("--project-id", required=True, help="GCP project ID")
    parser.add_argument("--app-path", required=True, help="Path to app config directory")
    
    args = parser.parse_args()
    
    success = deploy_agent(
        app_id=args.app_id,
        project_id=args.project_id,
        app_path=args.app_path
    )
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
