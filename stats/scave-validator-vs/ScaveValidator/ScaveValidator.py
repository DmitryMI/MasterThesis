#!/usr/bin/env python3

import argparse
from genericpath import isfile
import os
import os.path

VERBOSITY_SILENT = 0
VERBOSITY_INFO = 1
VERBOSITY_DEBUG = 2

def parse_line(line, args):
    line = line.rstrip()

    if line == "":
        if args.verbosity >= VERBOSITY_INFO:
            print(f"Line parser ERROR: empty string")
        return False, None, None

    token = ""
    quote_open = False
    entry_type = None
    items = []
    for i, c in enumerate(line):
        if c == " ":
            if entry_type is None:
                entry_type = token
                token = ""
            elif not quote_open:
                items.append(token)
                token = ""
            else:
                token += c
        elif c == '"' and quote_open and (not token or token[-1] != '\\'):
            items.append(token)
            token = ""
            quote_open = False
        elif c == '"' and not quote_open and (not token or token[-1] != '\\'):
            if token != "":
                if args.verbosity >= VERBOSITY_INFO:
                    print(f"Line parser ERROR: unexpected quote!")
                return False, None, None

            quote_open = True
        else:
            token += c

    if quote_open:
        if args.verbosity >= VERBOSITY_INFO:
            print(f"Line parser ERROR: quote not closed!")
        return False, None, None

    if token != "":
        items.append(token)

    if args.verbosity >= VERBOSITY_DEBUG:
        print(f"Line parser info: {entry_type} {items}")

    return True, entry_type, items

def validate(schema, file_path, args):
    with open(file_path, "r") as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        line_stip = line.rstrip()
        if not line_stip:
            continue

        is_ok, entry_type, items = parse_line(line, args)

        if not is_ok:
            return False

        if entry_type not in schema:
            if args.verbose:
                print(f"Entry {entry_type} unknown!")
            return False

        items_number_expected = schema[entry_type]

        if items_number_expected != len(items):
            if args.verbosity >= VERBOSITY_INFO:
                print(f"Validation failed in file {file_path}: wrong number of items for entry '{entry_type}' in line {i + 1}")
            return False

    return True

def read_schema(schema_path, args):
    with open(schema_path, "r") as schema_file:
        lines = schema_file.readlines()

    schema = {}
    for line in lines:
        words = line.split(" ")
        schema[words[0]] = int(words[1])

    if args.verbosity >= VERBOSITY_INFO:
        print("Loaded schema: ")
        for key, value in schema.items():
            print(f"{key}: {value} items")

    return schema

def main():

    parser = argparse.ArgumentParser(
            prog="Scave Validator",
            description="Validates .sca files",
            epilog="By Dmitriy Monakhov",
        )

    parser.add_argument("schema_path")    
    parser.add_argument("target_path")
    parser.add_argument("-v", "--verbosity", required=False, type=int, default=0)
    parser.add_argument("-o", "--report", required=False, type=str, default=None)

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
                if ".sca" not in f:
                    continue
                full_name = os.path.join(root, f)
                validation_list[full_name] = None

    for key, value in validation_list.items():
        if value is not None:
            continue

        valid = validate(schema, key, args)
        validation_list[key] = valid
        print(f"\"{key}\" {valid}")

    if args.report is not None:
        if args.verbosity >= VERBOSITY_INFO:
            print(f"Writing list of failed validations to {args.report}")
        with open(args.report, "w") as report:
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
