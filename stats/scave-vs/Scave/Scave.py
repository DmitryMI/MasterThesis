#!/usr/bin/env python3

import argparse
import os
import os.path
import re

VERBOSITY_SILENT = 0
VERBOSITY_INFO = 1
VERBOSITY_DEBUG = 2

TABLE_HEADER = "run,type,module,name,attrname,attrvalue,value"
TABLE_COLUMNS = TABLE_HEADER.split(',')

PROGRESS_REPORT_STEP = 0.01

log_level = VERBOSITY_INFO

def slog(msg, level=VERBOSITY_INFO):
    if level <= log_level:
        print(msg)

def print_progress_bar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '*', printEnd = "\r"):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    # Print New Line on Complete
    if iteration == total: 
        print()

def read_schema(schema_path):
    with open(schema_path, "r") as schema_file:
        lines = schema_file.readlines()

    schema = {}
    for line in lines:
        words = line.split(" ")
        schema[words[0]] = int(words[1])

    slog("Loaded schema: ")
    for key, value in schema.items():
        slog(f"{key}: {value} items")

    return schema

def parse_line(line):
    line = line.rstrip()

    if line == "":
        slog(f"Line parser ERROR: empty string")
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
                slog(f"Line parser ERROR: unexpected quote!")
                return False, None, None

            quote_open = True
        else:
            token += c

    if quote_open:
        slog(f"Line parser ERROR: quote not closed!")
        return False, None, None

    if token != "":
        items.append(token)

    slog(f"Line parser info: {entry_type} {items}", VERBOSITY_DEBUG)

    return True, entry_type, items

def create_csv(csv_path, rewrite):
    if not rewrite:
        if os.path.exists(csv_path):
            with open(csv_path, "r") as csv:
                line = csv.readline()
                if line == TABLE_HEADER:
                    return
    
    with open(csv_path, "w") as csv:
        csv.write(TABLE_HEADER)

class ScaveFile:
    def __init__(self, sca_path, csv_path, filter_list, schema=None):
        self.sca_path = sca_path
        self.csv_path = csv_path
        self.filter_list = filter_list
        self.schema = schema

        self._run = None
        self._version = None
        

    def _scave_line(self, entry_type, items):

        if entry_type == "version":
            self._version = int(items[0])
            return False

        elif entry_type == "run":
            self._run = items[0]
            return False

        elif entry_type == "attr":
            row_values = {}
            row_values["run"] = self._run
            row_values["type"] = "runattr"
            row_values["attrname"] = items[0]
            row_values["attrvalue"] = items[1]
            
        elif entry_type == "itervar":
            row_values = {}
            row_values["run"] = self._run
            row_values["type"] = "itervar"
            row_values["attrname"] = items[0]
            row_values["attrvalue"] = items[1]

        elif entry_type == "param":
            row_values = {}
            row_values["run"] = self._run
            row_values["type"] = "param"
            row_values["attrname"] = items[0]
            row_values["attrvalue"] = items[1]
            
        elif entry_type == "scalar":
            row_values = {}

            scalar_name = items[1]
            if self.filter_list and scalar_name not in self.filter_list:
                return False

            row_values["run"] = self._run
            row_values["type"] = "scalar"
            row_values["module"] = items[0]
            row_values["name"] = items[1]
            row_values["value"] = items[2]
        else:
            return False

        csv_values = []
        for col in TABLE_COLUMNS:
            if col in row_values:
                csv_values.append(row_values[col])
            else:
                csv_values.append("")

        with open(self.csv_path, "a") as csv:
            csv.write(",".join(csv_values))
            csv.write("\n")

        return True

    def scave_file(self):
        with open(self.sca_path, "r") as f:
            lines = f.readlines()

        for i, line in enumerate(lines):
            line_stip = line.rstrip()
            if not line_stip:
                continue

            parser_ok, entry_type, items = parse_line(line)

            if not parser_ok:
                slog(f"Parser failed in file {self.sca_path}: in line {i + 1} ({line_stip})")
                return False

            if self.schema is not None:
                if entry_type not in self.schema:
                    slog(f"Entry {entry_type} unknown!")
                    return False

                items_number_expected = self.schema[entry_type]

                if items_number_expected != len(items):
                    slog(f"Validation failed in file {self.sca_path}: wrong number of items for entry '{entry_type}' in line {i + 1} ({line_stip})")
                    return False

            scave_ok = self._scave_line(entry_type, items)
            if not scave_ok:
                slog(f"Line {line_stip} in file {self.sca_path} filtered out!", VERBOSITY_DEBUG)                

        return True

def main():
    global log_level

    parser = argparse.ArgumentParser(
            prog="Scave Tool (better one)",
            description="Converting .sca files into .csv tables",
            epilog="By Dmitriy Monakhov",
        )

    parser.add_argument("target_path")
    parser.add_argument("output_path")
    parser.add_argument("-r", "--file_regex", required=False)
    parser.add_argument("-s", "--schema_path", required=False)    
    parser.add_argument("-f", "--filters", required=False)
    parser.add_argument("--filters_file", required=False)
    parser.add_argument("-v", "--verbosity", required=False, type=int, default=log_level)
    parser.add_argument("-w", "--rewrite", required=False, type=bool, default=True)

    args = parser.parse_args()

    target_path = args.target_path
    if not os.path.exists(target_path):
        print(f"File or directory {target_path} does not exist!")
        quit(1)

    output_path = os.path.abspath(args.output_path)
    output_dir = os.path.dirname(output_path)
    if not os.path.exists(output_dir):
        print(f"Directory {output_dir} does not exist. Creating...")
        os.makedirs(output_dir)
        quit(1)

    log_level = args.verbosity
    schema_path = args.schema_path
    file_regex_str = args.file_regex    

    if file_regex_str is not None:
        fregex = re.compile(file_regex_str)

    if schema_path is not None and not os.path.exists(schema_path):
        print(f"File {schema_path} does not exist!")
        quit(1)
    
    if schema_path is not None:
        schema = read_schema(schema_path)
    else:
        schema = {"version":1, "run":1, "attr":2, "itervar":2, "param": 2, "scalar":3}

    filt_str = args.filters
    if filt_str is not None:
        filt_list = filt_str.split('|')
    else:
        filt_list = None

    if args.filters_file is not None:
        if not os.path.exists(args.filters_file):
            print(f"File {args.filters_file} does not exist!")
            quit(1)
        if filt_list is None:
            filt_list = []
        with open(args.filters_file, "r") as filters_file:
            filt_lines = filters_file.readlines()
        for filt_line in filt_lines:
            filt_line = filt_line.rstrip()
            filt_list.append(filt_line)    

    create_csv(output_path, args.rewrite)

    sca_file_list = []

    for root, dirs, files in os.walk(target_path, topdown=False):
        for f in files:
            if ".sca" not in f:
                continue

            if fregex is not None and not fregex.fullmatch(f):
                continue

            full_name = os.path.join(root, f)
            sca_file_list.append(full_name)

    last_reported_progress = None
    for i, sca_file_path in enumerate(sca_file_list):
        scave = ScaveFile(sca_file_path, output_path, filt_list, schema)
        scave.scave_file()

        progress = float(i) / len(sca_file_list)
        if last_reported_progress is None or progress - last_reported_progress >= PROGRESS_REPORT_STEP:
            print_progress_bar( i, len(sca_file_list), prefix="Scave:",)
            last_reported_progress = progress

    print_progress_bar(len(sca_file_list), len(sca_file_list), prefix="Scave:",)

if __name__ == "__main__":
    main()
