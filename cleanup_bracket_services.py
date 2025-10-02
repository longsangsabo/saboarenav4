#!/usr/bin/env python3
"""Move old bracket services to archive to clean up the mess"""

import os
import shutil

def move_to_archive():
    """Move old bracket services to archive folder"""
    
    # Create archive folder if not exists
    archive_dir = "archive_services"
    if not os.path.exists(archive_dir):
        os.makedirs(archive_dir)
        print(f"📁 Created {archive_dir} directory")
    
    # List of old bracket services to archive
    old_services = [
        "lib/services/bracket_integration_service.dart",
        "lib/services/bracket_generator_service.dart", 
        "lib/services/bracket_generation_service.dart",
        "lib/services/bracket_export_service.dart",
        "lib/services/bracket_progression_service.dart",
        "lib/services/advanced_bracket_visualization_service.dart",
        "lib/services/bracket_visualization_service.dart",
        "lib/services/bracket_service.dart",
        "lib/services/realtime_bracket_service.dart",
        "lib/services/proper_bracket_service.dart",
        "lib/services/production_bracket_service.dart",
        # Keep correct_bracket_logic_service.dart for now - it's being used
    ]
    
    moved_count = 0
    for service_path in old_services:
        if os.path.exists(service_path):
            filename = os.path.basename(service_path)
            dest_path = os.path.join(archive_dir, filename)
            
            try:
                shutil.move(service_path, dest_path)
                print(f"🗂️ Moved {filename} to archive")
                moved_count += 1
            except Exception as e:
                print(f"❌ Failed to move {filename}: {e}")
        else:
            print(f"⚠️ {service_path} not found")
    
    print(f"\n✅ Archived {moved_count} old bracket services")
    print("📋 Now only CorrectBracketLogicService and TournamentService handle brackets")

if __name__ == "__main__":
    move_to_archive()