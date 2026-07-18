# register_all.py
# Register WeatherIntelligenceAppIntents.swift and WeatherIntelligenceWidget.swift in project.pbxproj

import re
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

project_path = "/Users/kaushikirai/Desktop/budding-technocrat/Hyperpure/Hyperpure.xcodeproj/project.pbxproj"

files_to_add = [
    {
        "name": "WeatherIntelligenceAppIntents.swift",
        "path": "Hyperpure/AppIntents/WeatherIntelligenceAppIntents.swift",
        "group_id": "747718436FED4CA4B932A79B", # App
        "file_ref": generate_id(),
        "build_file": generate_id()
    },
    {
        "name": "WeatherIntelligenceWidget.swift",
        "path": "Hyperpure/AppIntents/WeatherIntelligenceWidget.swift",
        "group_id": "747718436FED4CA4B932A79B", # App
        "file_ref": generate_id(),
        "build_file": generate_id()
    }
]

with open(project_path, "r") as f:
    content = f.read()

for f_info in files_to_add:
    if f_info["name"] in content:
        print(f"Skipping {f_info['name']} as it's already registered")
        continue

    # 1. Insert into PBXBuildFile section
    line_bf = f"\t\t{f_info['build_file']} /* {f_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_info['file_ref']} /* {f_info['name']} */; }};"
    content = content.replace("/* Begin PBXBuildFile section */", "/* Begin PBXBuildFile section */\n" + line_bf)

    # 2. Insert into PBXFileReference section
    line_fr = f"\t\t{f_info['file_ref']} /* {f_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {f_info['name']}; path = {f_info['path']}; sourceTree = \"<group>\"; }};"
    content = content.replace("/* Begin PBXFileReference section */", "/* Begin PBXFileReference section */\n" + line_fr)

    # 3. Insert into PBXGroup sections (by group_id)
    group_pattern = rf"({f_info['group_id']} /\* .* \*/ = \{{\s+isa = PBXGroup;\s+children = \()"
    match = re.search(group_pattern, content)
    if match:
        insertion = f"\n\t\t\t\t{f_info['file_ref']} /* {f_info['name']} */,"
        content = content.replace(match.group(1), match.group(1) + insertion)

    # 4. Insert into PBXSourcesBuildPhase section
    sources_pattern = r"(isa = PBXSourcesBuildPhase;\s+buildActionMask = 2147483647;\s+files = \()"
    match = re.search(sources_pattern, content)
    if match:
        insertion = f"\n\t\t\t\t{f_info['build_file']} /* {f_info['name']} in Sources */,"
        content = content.replace(match.group(1), match.group(1) + insertion)

with open(project_path, "w") as f:
    f.write(content)

print("Registered all files successfully")
