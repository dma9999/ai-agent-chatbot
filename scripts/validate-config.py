#!/usr/bin/env python3
"""
Validate CX Agent Studio app configuration using scrapi.
"""

import json
import sys
from pathlib import Path

def validate_config():
    """Validate the app configuration."""
    
    app_path = Path("dfs-ai-agent")
    
    # Check required files exist
    required_files = [
        app_path / "app.json",
        app_path / "environment.json",
    ]
    
    for file in required_files:
        if not file.exists():
            print(f"❌ Missing required file: {file}")
            return False
        print(f"✓ Found {file}")
    
    # Validate app.json structure
    try:
        with open(app_path / "app.json") as f:
            app_config = json.load(f)
        
        required_keys = ["displayName", "rootAgent"]
        for key in required_keys:
            if key not in app_config:
                print(f"❌ Missing required key in app.json: {key}")
                return False
        
        print(f"✓ app.json is valid (displayName: {app_config['displayName']})")
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON in app.json: {e}")
        return False
    
    # Validate environment.json structure
    try:
        with open(app_path / "environment.json") as f:
            env_config = json.load(f)
        print("✓ environment.json is valid")
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON in environment.json: {e}")
        return False
    
    # Check agents directory
    agents_dir = app_path / "agents"
    if agents_dir.exists():
        agent_files = list(agents_dir.glob("*.yaml")) + list(agents_dir.glob("*.yml"))
        print(f"✓ Found {len(agent_files)} agent configuration files")
    else:
        print("⚠ agents/ directory not found (optional)")
    
    print("\n✓ All validations passed!")
    return True

if __name__ == "__main__":
    success = validate_config()
    sys.exit(0 if success else 1)
