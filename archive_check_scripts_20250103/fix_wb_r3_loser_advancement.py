from supabase import create_client

client = create_client(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ'
)

tournament_id = '7f0b185e-8d53-4c4b-94da-88d8beb1e62d'

print("🔧 Fixing Group A/B WB R3 loser_advances_to fields...")
print("="*80)

# Group A WB R3 → LB-A R2
# M13 (11301) → loser should go to M19 (12201)
# M14 (11302) → loser should go to M20 (12202)

fixes = [
    {'match_number': 13, 'display_order': 11301, 'loser_advances_to': 12201},
    {'match_number': 14, 'display_order': 11302, 'loser_advances_to': 12202},
    # Group B WB R3 → LB-A R2
    {'match_number': 37, 'display_order': 21301, 'loser_advances_to': 22201},
    {'match_number': 38, 'display_order': 21302, 'loser_advances_to': 22202},
]

for fix in fixes:
    print(f"\n📝 Updating Match {fix['match_number']} (Display: {fix['display_order']})")
    print(f"   Setting loser_advances_to = {fix['loser_advances_to']}")
    
    result = client.table('matches').update({
        'loser_advances_to': fix['loser_advances_to']
    }).eq('tournament_id', tournament_id
    ).eq('match_number', fix['match_number']
    ).execute()
    
    if result.data:
        print(f"   ✅ Updated successfully!")
    else:
        print(f"   ❌ Failed to update")

print("\n" + "="*80)
print("✅ All fixes applied!")
print("\n🔄 Now re-run the service to process these completed matches...")
