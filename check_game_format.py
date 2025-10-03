import os
from supabase import create_client, Client

# Initialize Supabase client
SUPABASE_URL = "https://mogjjvscxjwvhtpkrlqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Query to check current game_format values
try:
    result = supabase.table('tournaments').select('game_format').execute()
    
    print("=" * 60)
    print("CURRENT game_format VALUES IN DATABASE:")
    print("=" * 60)
    
    if result.data:
        game_formats = {}
        for tournament in result.data:
            game_format = tournament.get('game_format', 'NULL')
            game_formats[game_format] = game_formats.get(game_format, 0) + 1
        
        for format_name, count in sorted(game_formats.items()):
            print(f"  {format_name}: {count} tournaments")
    else:
        print("  No tournaments found")
    
    print("\n" + "=" * 60)
    print("ANALYZING FORMAT:")
    print("=" * 60)
    
    if result.data and len(result.data) > 0:
        sample = result.data[0].get('game_format')
        print(f"  Sample value: '{sample}'")
        print(f"  Is uppercase: {sample and sample.isupper()}")
        print(f"  Contains hyphen: {sample and '-' in sample}")
        
except Exception as e:
    print(f"Error: {e}")
