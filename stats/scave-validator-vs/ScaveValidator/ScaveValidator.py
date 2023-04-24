#!/usr/bin/env python3

import argparse
from genericpath import isfile
import os
import os.path

def validate(schema, file_path, args):
    with open(file_path, "r") as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        words = line.split(" ")

        entry_type = words[0]
        if entry_type not in schema:
            if args.verbose:
                print(f"Entry {entry_type} unknown!")
            return False

        items_number_expected = schema[entry_type]
        items_number_actual = len(words) - 1

        if items_number_expected != items_number_actual:
            if args.verbose:
                print(f"Validation failed in file {file_path}: wrong number of items for entry {entry_type} in line {i + 1}")
            return False

    return True

def read_schema(schema_path, args):
    with open(schema_path, "r") as schema_file:
        lines = schema_file.readlines()

    schema = {}
    for line in lines:
        words = line.split(" ")
        schema[words[0]] = int(words[1])

    if args.verbose:
        print("Loaded schema: ")
        for key, value in schema.items():
            print(f"{key}: {value} items")


def main():

    parser = argparse.ArgumentParser(
            prog="Scave Validator",
            description="Validates .sca files",
            epilog="By Dmitriy Monakhov",
        )

    parser.add_argument("schema_path")    
    parser.add_argument("target_path")
    parser.add_argument("-v", "--verbose", required=False, type=bool, default=False)
    parser.add_argument("-o", "--report", required=False, type=str, default=False)

    args = parser.parse_args()

    schema_path = args.schema_path

    if not os.path.exists(schema_path):
        print(f"File {schema_path} does not exist!")
        quit(1)

    schema = read_schema(schema_path, args)

    target_path = args.target_path

    if not os.path.exists(target_path):
        print(f"File or directory {target_path} does not exist!")
        quit(1)

    validation_list = {}

    if os.path.isfile(target_path):
        validation_list.append(target_path)
    else:
        for root, dirs, files in os.walk(target_path, topdown=False):
            for f in files:
                validation_list[f] = None

    for key, value in validation_list.items():
        if value is not None:
            continue

        valid = validate(schema, key, args)
        validation_list[key] = valid
        print(f"\"{key}\" {valid}")

    if args.report is not None:
        with open("args.report", "w") as report:
            for key, value in validation_list.items():
                if value is None:
                    print("Error: dictionary value is None!")
                    return 1
                if value is None or value == False:
                    report.write(f"{key}\n")
        
    return 0

if __name__ == "__main__":
    code = main()
    quit(code)
