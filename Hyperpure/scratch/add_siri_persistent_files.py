# add_siri_persistent_files.py
# Helper script to register newly created persistent & intents swift files inside project.pbxproj.

import re
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

project_path = "/Users/kaushikirai/Desktop/budding-technocrat/Hyperpure/Hyperpure.xcodeproj/project.pbxproj"

files_to_add = [
    {
        "name": "Database.swift",
        "path": "Hyperpure/Models/Database.swift",
        "group_id": "D8171C5B05A14D13A625D7C3", # Models
    },
    {
        "name": "SavedListItem.swift",
        "path": "Hyperpure/Models/SavedListItem.swift",
        "group_id": "D8171C5B05A14D13A625D7C3", # Models
    },
    {
        "name": "AccountProfile.swift",
        "path": "Hyperpure/Models/AccountProfile.swift",
        "group_id": "D8171C5B05A14D13A625D7C3", # Models
    },
    {
        "name": "AccountViewModel.swift",
        "path": "Hyperpure/ViewModels/AccountViewModel.swift",
        "group_id": "A9F17AB119D940678E6ABED2", # ViewModels
    },
    {
        "name": "HyperpureAppEntities.swift",
        "path": "Hyperpure/AppIntents/HyperpureAppEntities.swift",
        "group_id": "747718436FED4CA4B932A79B", # App
    },
    {
        "name": "HyperpureAppIntents.swift",
        "path": "Hyperpure/AppIntents/HyperpureAppIntents.swift",
        "group_id": "747718436FED4CA4B932A79B", # App
    },
    {
        "name": "HyperpureAppShortcuts.swift",
        "path": "Hyperpure/AppIntents/HyperpureAppShortcuts.swift",
        "group_id": "747718436FED4CA4B932A79B", # App
    }
]

with open(project_path, "r") as f:
    content = f.read()

# Filter out files that are already added
files_to_add = [f for f in files_to_add if f["name"] not in content]

if not files_to_add:
    print("All files already registered in project.pbxproj")
    exit(0)

# Generate consistent IDs
for f_info in files_to_add:
    f_info["file_ref"] = generate_id()
    f_info["build_file"] = generate_id()

# 1. Insert into PBXBuildFile section
build_file_lines = []
for f_info in files_to_add:
    line = f"\t\t{f_info['build_file']} /* {f_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_info['file_ref']} /* {f_info['name']} */; }};"
    build_file_lines.append(line)

content = content.replace("/* Begin PBXBuildFile section */", "/* Begin PBXBuildFile section */\n" + "\n".join(build_file_lines))

# 2. Insert into PBXFileReference section
file_ref_lines = []
for f_info in files_to_add:
    line = f"\t\t{f_info['file_ref']} /* {f_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {f_info['name']}; path = {f_info['path']}; sourceTree = \"<group>\"; }};"
    file_ref_lines.append(line)

content = content.replace("/* Begin PBXFileReference section */", "/* Begin PBXFileReference section */\n" + "\n".join(file_ref_lines))

# 3. Insert into PBXGroup sections (by group_id)
for f_info in files_to_add:
    group_pattern = rf"({f_info['group_id']} /\* .* \*/ = \{{\s+isa = PBXGroup;\s+children = \()"
    match = re.search(group_pattern, content)
    if match:
        insertion = f"\n\t\t\t\t{f_info['file_ref']} /* {f_info['name']} */,"
        content = content.replace(match.group(1), match.group(1) + insertion)

# 4. Insert into PBXSourcesBuildPhase section
sources_pattern = r"(isa = PBXSourcesBuildPhase;\s+buildActionMask = 2147483647;\s+files = \()"
match = re.search(sources_pattern, content)
if match:
    insertion = ""
    for f_info in files_to_add:
        insertion += f"\n\t\t\t\t{f_info['build_file']} /* {f_info['name']} in Sources */,"
    content = content.replace(match.group(1), match.group(1) + insertion)

with open(project_path, "w") as f:
    f.write(content)

print(f"Successfully injected {len(files_to_add)} file references into project.pbxproj")
