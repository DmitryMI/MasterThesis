#! /bin/python3

import json

with open("./Obstacle3dDemo/Obstacle3dDemo.uproject", "r") as proj_file:
    proj_json = json.load(proj_file)
    
plugins = proj_json["Plugins"]

changes_applied = False

for plugin in plugins:
    plugin_name = plugin["Name"]
    print(f"Found plugin: {plugin_name}. ", end="")
    if plugin_name == "VisualStudioTools" && plugin["Enabled"]:
        plugin["Enabled"] = False
        changes_applied = True
        print("Disabled")
    else:
        print("Nothing to do")
        
if changes_applied:
    with open("./Obstacle3dDemo/Obstacle3dDemo.uproject", "w") as proj_file:
        json.dump(proj_json, proj_file, indent=4)
        
    print("Uproject patched: VisualStudioTools plugin disabled.")
else:
    print("Uproject not patched: VisualStudioTools plugin not found or already disabled.")
