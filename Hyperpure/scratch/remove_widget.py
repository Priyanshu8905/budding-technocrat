# remove_widget.py
import re
import os

project_path = "/Users/kaushikirai/Desktop/budding-technocrat/Hyperpure/Hyperpure.xcodeproj/project.pbxproj"
widget_file = "/Users/kaushikirai/Desktop/budding-technocrat/Hyperpure/Hyperpure/AppIntents/WeatherIntelligenceWidget.swift"

if os.path.exists(widget_file):
    os.remove(widget_file)
    print("Deleted WeatherIntelligenceWidget.swift")

with open(project_path, "r") as f:
    content = f.read()

# Remove build file and file reference lines containing WeatherIntelligenceWidget.swift
lines = content.splitlines()
new_lines = []
for line in lines:
    if "WeatherIntelligenceWidget.swift" in line:
        continue
    new_lines.append(line)

content = "\n".join(new_lines)

with open(project_path, "w") as f:
    f.write(content)

print("Removed pbxproj references for WeatherIntelligenceWidget.swift successfully")
