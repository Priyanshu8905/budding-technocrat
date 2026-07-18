# add_activity.py
# Register DeliveryTrackingActivity.swift in project.pbxproj

import re
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

project_path = "/Users/kaushikirai/Desktop/budding-technocrat/Hyperpure/Hyperpure.xcodeproj/project.pbxproj"

f_info = {
    "name": "DeliveryTrackingActivity.swift",
    "path": "Hyperpure/AppIntents/DeliveryTrackingActivity.swift",
    "group_id": "747718436FED4CA4B932A79B", # App
    "file_ref": generate_id(),
    "build_file": generate_id()
}

with open(project_path, "r") as f:
    content = f.read()

if "DeliveryTrackingActivity.swift" in content:
    print("Already registered")
    exit(0)

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

print("Registered DeliveryTrackingActivity.swift successfully")
