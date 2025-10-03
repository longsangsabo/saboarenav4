import re

# Read file
with open('lib/services/hardcoded_double_elimination_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove all lines containing 'bracket_type'
# Pattern matches:     'bracket_type': 'xxx',
lines = content.split('\n')
new_lines = []

for line in lines:
    if "'bracket_type':" not in line:
        new_lines.append(line)
    else:
        print(f"Removing: {line.strip()}")

# Write back
new_content = '\n'.join(new_lines)

with open('lib/services/hardcoded_double_elimination_service.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("\n✅ Removed all bracket_type fields!")
print(f"Original lines: {len(lines)}")
print(f"New lines: {len(new_lines)}")
print(f"Removed: {len(lines) - len(new_lines)} lines")
