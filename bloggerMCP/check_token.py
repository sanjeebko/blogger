#!/usr/bin/env python3
"""
Check if token.json has a refresh token and is properly configured
"""

import json
import sys
from pathlib import Path
from datetime import datetime

def check_token(token_path='token.json'):
    """Check token.json for refresh token and validity"""
    
    if not Path(token_path).exists():
        print("❌ token.json NOT FOUND")
        print(f"   Expected location: {Path(token_path).absolute()}")
        print("\n📝 Action Required:")
        print("   1. Run blogger_auth_get_url tool")
        print("   2. Complete OAuth flow")
        print("   3. Run this check again")
        return False
    
    try:
        with open(token_path, 'r') as f:
            token_data = json.load(f)
    except json.JSONDecodeError:
        print("❌ token.json is not valid JSON")
        return False
    
    print("=" * 60)
    print("🔍 TOKEN.JSON ANALYSIS")
    print("=" * 60)
    
    # Check for refresh token
    has_refresh = 'refresh_token' in token_data
    has_access = 'token' in token_data
    has_expiry = 'expiry' in token_data
    
    print(f"\n✅ Access Token:   {'Present' if has_access else '❌ Missing'}")
    print(f"{'✅' if has_refresh else '❌'} Refresh Token:  {'Present' if has_refresh else '❌ MISSING - CRITICAL!'}")
    print(f"✅ Expiry:         {'Present' if has_expiry else '❌ Missing'}")
    
    if has_expiry:
        try:
            expiry_str = token_data['expiry']
            expiry_dt = datetime.fromisoformat(expiry_str.replace('Z', '+00:00'))
            now = datetime.now(expiry_dt.tzinfo)
            
            if expiry_dt > now:
                time_left = expiry_dt - now
                print(f"   Token expires in: {time_left}")
                print(f"   Status: ✅ Valid")
            else:
                print(f"   Token expired: {expiry_dt}")
                print(f"   Status: ⏰ Expired (will auto-refresh if refresh_token exists)")
        except Exception as e:
            print(f"   Could not parse expiry: {e}")
    
    print("\n" + "=" * 60)
    print("📊 AUTHENTICATION STATUS")
    print("=" * 60)
    
    if not has_refresh:
        print("\n❌ CRITICAL ISSUE: No refresh token!")
        print("\n🔧 FIX:")
        print("   1. Delete token.json")
        print("   2. Ensure server.py has the updated blogger_auth_get_url code")
        print("   3. Run blogger_auth_get_url tool")
        print("   4. Complete OAuth flow (you'll see consent screen)")
        print("   5. Run blogger_auth_complete_flow with redirect URL")
        print("   6. Run this check again")
        print("\n⚠️  Without refresh token, you'll need to re-authenticate every hour!")
        return False
    
    if has_refresh and has_access:
        print("\n✅ EXCELLENT! Token is properly configured")
        print("\n🎉 Your MCP server will:")
        print("   • Auto-refresh tokens when they expire")
        print("   • Work without manual intervention")
        print("   • Support automated systems")
        print("\n📝 Next Steps:")
        print("   1. Ensure token.json is mounted in Docker/K8s")
        print("   2. Test by calling any blogger tool")
        print("   3. Check logs for 'Access token refreshed successfully'")
        return True
    
    return False

if __name__ == "__main__":
    token_path = sys.argv[1] if len(sys.argv) > 1 else 'token.json'
    success = check_token(token_path)
    sys.exit(0 if success else 1)
