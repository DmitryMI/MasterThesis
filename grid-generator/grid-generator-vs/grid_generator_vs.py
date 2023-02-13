#!/usr/bin/env python3.11

from pathlib import Path
import random
import xml.etree.ElementTree as ET
import sys
import os
import re
import argparse


class BlockConfig:
    def __init__(self, block_size: int, block_margin: float, block_padding: float):
        self.block_size = block_size
        self.block_margin = block_margin
        self.block_padding = block_padding


class GridGenerator:
    def __init__(
        self,
        proj_dir: str,
        proj_name: str,
        junctions_count_x: int,
        junctions_count_y: int,
        street_length: float,
        building_height_min: float,
        building_height_max: float,
        block_config: BlockConfig,
    ):
        self._proj_dir = Path(proj_dir)
        self._proj_name = proj_name
        self._junctions_count_x = junctions_count_x
        self._junctions_count_y = junctions_count_y
        self._street_length = street_length
        self._block_config = block_config
        self._building_height_min = building_height_min
        self._building_height_max = building_height_max

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

    def _get_polygon_xml_element(
        self,
        poly_id,
        coords,
        poly_type="building",
        color=(128, 128, 128),
        fill=True,
        layer=-1.0,
        height=None,
    ):
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

        if height is not None:
            poly_element.set("height", f"{height:.3f}")

        return poly_element

    # Generating simple rectangle building that fills the entire cell
    def _generate_simple_building(
        self, index_x, index_y, cell_width, cell_height, scale=1
    ):
        cell_center_x = cell_width * index_x + cell_width / 2
        cell_center_y = cell_height * index_y + cell_height / 2

        coords = self._get_rectangle_coords(
            cell_center_x, cell_center_y, cell_width, cell_height, scale
        )

        poly_id = f"building-simple-{index_x}_{index_y}"

        return self._get_polygon_xml_element(poly_id, coords)

    def _generate_building(self, center_x, center_y, width, height, poly_id=None):
        coords = self._get_rectangle_coords(center_x, center_y, width, height, 1)

        if poly_id is None:
            poly_id = f"building-simple-{int(center_x)}_{int(center_y)}"

        height = random.uniform(self._building_height_min, self._building_height_max)
        return self._get_polygon_xml_element(poly_id, coords, height=height)

    def generate_buildings_in_cell(
        self, cell_x, cell_y, cell_width, cell_height, element_additional
    ):
        # cell_center_x = cell_width * cell_x + cell_width / 2
        # cell_center_y = cell_height * cell_y + cell_height / 2
        cell_start_x = cell_width * cell_x + self._block_config.block_margin
        cell_start_y = cell_height * cell_y + self._block_config.block_margin

        cell_width_mod = cell_width - self._block_config.block_margin * 2
        cell_height_mod = cell_height - self._block_config.block_margin * 2

        total_padding_space = (
            self._block_config.block_size - 1
        ) * self._block_config.block_padding
        size_reduction = total_padding_space / self._block_config.block_size
        building_size_x = (
            cell_width_mod / self._block_config.block_size - size_reduction
        )
        building_size_y = (
            cell_height_mod / self._block_config.block_size - size_reduction
        )

        for i in range(self._block_config.block_size):
            for j in range(self._block_config.block_size):
                building_right = (
                    building_size_x + self._block_config.block_padding
                ) * i + cell_start_x
                building_bot = (
                    building_size_y + self._block_config.block_padding
                ) * j + cell_start_y
                building_center_x = building_right + building_size_x / 2
                building_center_y = building_bot + building_size_y / 2

                poly_id = f"building-{int(cell_x)}_{i}-{int(cell_y)}_{j}"

                building_xml_element = self._generate_building(
                    building_center_x,
                    building_center_y,
                    building_size_x,
                    building_size_y,
                    poly_id
                )
                element_additional.append(building_xml_element)

    def generate_buildings(self):
        polygons_filepath = self._get_project_filepath("poly")

        print(f"Target file: {polygons_filepath}")

        scene_width = self._junctions_count_x * self._street_length
        scene_height = self._junctions_count_y * self._street_length

        print(f"Scene size: ({scene_width}, {scene_height})")

        cell_width = scene_width / self._junctions_count_x
        cell_height = scene_height / self._junctions_count_y

        print(f"Cell size: ({cell_width}, {cell_height})")

        cells_count_x = self._junctions_count_x - 1
        cells_count_y = self._junctions_count_y - 1

        assert cells_count_x > 0
        assert cells_count_y > 0

        element_additional = ET.Element("additional")
        element_additional.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        element_additional.set(
            "xsi:noNamespaceSchemaLocation",
            "http://sumo.dlr.de/xsd/additional_file.xsd",
        )

        for xi in range(cells_count_x):
            for yi in range(cells_count_y):
                self.generate_buildings_in_cell(
                    xi, yi, cell_width, cell_height, element_additional
                )

        tree = ET.ElementTree(element_additional)
        ET.indent(tree, space="\t", level=0)
        tree.write(polygons_filepath, xml_declaration=True)

    def set_omnetpp_playground_size(self, omnetpp_ini_path):
        factor = 1.05
        playground_width = (self._junctions_count_x - 1) * self._street_length * factor
        playground_height = (self._junctions_count_y - 1) * self._street_length * factor

        with open(omnetpp_ini_path, "r") as omnetpp_ini:
            text = omnetpp_ini.read()
        text = re.sub(
            "\*\.playgroundSizeX.*",
            f"*.playgroundSizeX = {playground_width:.2f}m",
            text,
        )
        text = re.sub(
            "\*\.playgroundSizeY.*",
            f"*.playgroundSizeY = {playground_height:.2f}m",
            text,
        )
        with open(omnetpp_ini_path, "w") as omnetpp_ini:
            omnetpp_ini.write(text)
        print(f"Playground size updated in file {omnetpp_ini_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="Grid Generator",
        description="Generates buildings for the Manhatten Grid roadnet from SUMO",
        epilog="By Dmitriy",
    )

    parser.add_argument("proj_name")
    parser.add_argument("--proj_dir", default=os.getcwd())
    parser.add_argument("--grid.x-number", default=5, dest="junctions_x", type=int)
    parser.add_argument("--grid.y-number", default=5, dest="junctions_y", type=int)
    parser.add_argument("--grid.length", default=100, dest="street_length", type=float)
    parser.add_argument(
        "--building_height_min", default=10, dest="building_height_min", type=float
    )
    parser.add_argument(
        "--building_height_max", default=20, dest="building_height_max", type=float
    )
    parser.add_argument("--block_size", default=4, type=int)
    parser.add_argument("--block_margin", default=10, type=float)
    parser.add_argument("--block_padding", default=10, type=float)

    parser.add_argument("--ini_path", default=None)

    args = parser.parse_args()

    proj_dir = args.proj_dir
    proj_name = args.proj_name
    junctions_x = args.junctions_x
    junctions_y = args.junctions_y
    street_length = args.street_length
    building_height_min = args.building_height_min
    building_height_max = args.building_height_max
    block_size = args.block_size
    block_margin = args.block_margin
    block_padding = args.block_padding

    ini_path = args.ini_path

    blockConfig = BlockConfig(block_size, block_margin, block_padding)
    grid_generator = GridGenerator(
        proj_dir,
        proj_name,
        junctions_x,
        junctions_y,
        street_length,
        building_height_min,
        building_height_max,
        blockConfig,
    )
    grid_generator.generate_buildings()

    if ini_path is not None:
        grid_generator.set_omnetpp_playground_size(ini_path)
