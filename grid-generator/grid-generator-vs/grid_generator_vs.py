#!/usr/bin/env python3.11

from pathlib import Path
import xml.etree.ElementTree as ET
import sys
import os
import re

class GridGenerator:
    def __init__(self, proj_dir: str, proj_name: str, junctions_count_x: int, junctions_count_y: int, street_length: float):
        self._proj_dir = Path(proj_dir)
        self._proj_name = proj_name
        self._junctions_count_x = junctions_count_x
        self._junctions_count_y = junctions_count_y
        self._street_length = street_length

        pass
    
    def _get_project_filepath(self, file_type):
         p = self._proj_dir / f"{self._proj_name}.{file_type}.xml"
         return p

    def _get_rectangle_coords(self, center_x, center_y, width, height, scale):
        half_width = width / 2
        half_height = height / 2

        top_left = (-half_width * scale + center_x, -half_height * scale + center_y)
        top_right = (half_width * scale + center_x, -half_height * scale + center_y)
        bot_right = (half_width * scale + center_x, half_height * scale + center_y)
        bot_left = (-half_width * scale + center_x, half_height * scale + center_y)

        return [top_left, top_right, bot_right, bot_left]

    def _get_polygon_xml_element(self, poly_id, coords, poly_type="building", color=(128, 128, 128), fill=True, layer=-1.0):
        poly_element = ET.Element("poly")

        poly_element.set("id", poly_id)

        poly_element.set("type", poly_type)

        if fill:
            poly_element.set("fill", "1")
        else:
            poly_element.set("fill", "0")

        poly_element.set("layer", f"{layer:.2}")

        color_str = f"{color[0]},{color[1]},{color[2]}"
        poly_element.set("color", color_str)

        shape_str = ""
        for i, coord in enumerate(coords):
            x = coord[0]
            y = coord[1]
            shape_str += f"{x},{y} "
            
        shape_str += f"{coords[0][0]},{coords[0][1]}"

        poly_element.set("shape", shape_str)

        return poly_element   

    # Generating simple rectangle building that fills the entire cell
    def _generate_simple_building(self, index_x, index_y, cell_width, cell_height):
        scale = 0.9

        cell_center_x = cell_width * index_x + cell_width / 2
        cell_center_y = cell_height * index_y + cell_height / 2

        coords = self._get_rectangle_coords(cell_center_x, cell_center_y, cell_width, cell_height, scale)

        poly_id = f"building-simple-{index_x}_{index_y}";

        return self._get_polygon_xml_element(poly_id, coords)

    def generate_buildings(self):
        polygons_filepath = self._get_project_filepath("poly")

        print(f"Target file: {polygons_filepath}")

        scene_width = self._junctions_count_x * self._street_length
        scene_height = self._junctions_count_y * self._street_length

        print(f"Scene size: ({scene_width}, {scene_height})")

        building_width = scene_width /  self._junctions_count_x
        building_height = scene_height /  self._junctions_count_y

        print(f"Building size: ({building_width}, {building_height})")

        buildings_count_x = self._junctions_count_x - 1
        buildings_count_y = self._junctions_count_y - 1

        assert buildings_count_x > 0
        assert buildings_count_y > 0

        element_additional = ET.Element("additional")
        element_additional.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        element_additional.set("xsi:noNamespaceSchemaLocation", "http://sumo.dlr.de/xsd/additional_file.xsd")

        for xi in range(buildings_count_x):
            for yi in range(buildings_count_y):
                building_xml_element = self._generate_simple_building(xi, yi, building_width, building_height)
                element_additional.append(building_xml_element)

        tree = ET.ElementTree(element_additional)
        ET.indent(tree, space="\t", level=0)
        tree.write(polygons_filepath, xml_declaration=True)
        
    def set_omnetpp_playground_size(self, omnetpp_ini_path):
        factor = 1.05
        playground_width = (self._junctions_count_x - 1) * self._street_length * factor
        playground_height = (self._junctions_count_y - 1) * self._street_length * factor

        with open(omnetpp_ini_path, "r") as omnetpp_ini:
            text = omnetpp_ini.read()
        text = re.sub('\*\.playgroundSizeX.*', f"*.playgroundSizeX = {playground_width:.2f}m", text)
        text = re.sub('\*\.playgroundSizeY.*', f"*.playgroundSizeY = {playground_height:.2f}m", text)
        with open(omnetpp_ini_path, "w") as omnetpp_ini:
            omnetpp_ini.write(text)
        print(f"Playground size updated in file {omnetpp_ini_path}")


if __name__ == "__main__":
    proj_dir = os.getcwd()
    proj_name = sys.argv[1]

    if len(sys.argv) > 2:
        junctions_x = int(sys.argv[2])
    else:
        junctions_x = 5

    if len(sys.argv) > 3:
        junctions_y = int(sys.argv[3])
    else:
        junctions_y = 5

    if len(sys.argv) > 4:
        street_length = float(sys.argv[4])
    else:
        street_length = 100
        
    ini_path = None
    if len(sys.argv) > 5:
    	ini_path = sys.argv[5]

    grid_generator = GridGenerator(proj_dir, proj_name, junctions_x, junctions_y, street_length)
    grid_generator.generate_buildings()
    
    if ini_path is not None:
    	grid_generator.set_omnetpp_playground_size(ini_path)
