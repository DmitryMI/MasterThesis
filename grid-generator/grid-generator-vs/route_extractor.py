#!/usr/bin/env python3.11

import argparse
import xml.etree.ElementTree as et
import os.path
from pathlib import Path

def validate_route(route_tag):
    route_edges = route_tag.get("edges")
    route_id = route_tag.get("id")
    print(f"Route {route_id} has {len(route_edges)} edges")

def main():
    parser = argparse.ArgumentParser(
        prog="Route Extractor",
        description="Reads Duarouter output and removes all vehicle ids, leaving routes only.",
        epilog="By Dmitriy",
    )

    parser.add_argument("rou_file")

    args = parser.parse_args()

    rou_file = args.rou_file

    if not os.path.exists(rou_file):
        print(f"File {rou_file} does not exist!")
        quit(1)

    tree = et.parse(rou_file)
    root = tree.getroot()

    route_tags = []
    
    route_counter = 0
    for route in root.iter("route"):
        route_id = None
        if "id" not in route.attrib:
            route_id = f"route-ext-{route_counter}"
            route_counter += 1
            route.set("id", route_id)    
        else:
            route_id = route.get("id")

        validate_route(route)
        route_tags.append(route)
        print(f"Route with ID {route_id} extracted")

    for node in list(root):
        root.remove(node)

    for route in route_tags:
        root.append(route)

    rou_dir = os.path.dirname(rou_file)
    rou_file_base = os.path.basename(rou_file)
    rou_file_name = os.path.splitext(rou_file_base)[0]
    
    # result_tree = et.ElementTree(result_root)
    tree.write(f"{os.path.join(rou_dir, rou_file_name)}.extracted.xml")
    print("Done!")

if __name__ == "__main__":
    main()
