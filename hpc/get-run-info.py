#!/bin/python3

import subprocess
import os
import os.path

RUNFILE_NAME = "./runfile.remote.txt"

os.remove(RUNFILE_NAME)

process = subprocess.Popen("./get_runfile.sh", stdout=subprocess.PIPE)
process.wait()
for line in process.stdout:
    print(line)
    
if not os.path.exists(RUNFILE_NAME):
    print("Failed to download runfile.txt")
    quit(1)

with open(RUNFILE_NAME) as runfile:
    lines = runfile.readlines()

total_commands = 0
total_inactive = 0
total_running = 0
total_done = 0
total_fail = 0
total_error = 0
total_unrecognized = 0

for line in lines:
    if line[0] == ".":
        total_inactive += 1
        total_commands += 1
        
    elif line[0] == "d":
        total_done += 1
        total_commands += 1
        
    elif line[0] == "!":
        total_fail += 1
        total_commands += 1
        print(f"Line {line}: fail!")
        
    elif line[0] == "e":
        total_error += 1
        total_commands += 1
        print(f"Line {line}: error!")
        
    elif line[0] == "r":
        total_running += 1
        total_commands += 1
    else:
        total_unrecognized += 1
        print(f"Unknown status in line {line}")
        
if total_commands == 0:
    print("runfile contains no commands!")
    quit(0)
        
print("RUN INFO:")
print(f"Total commands:\t\t{total_commands}")
print(f"Total inactive:\t\t{total_inactive}")
print(f"Total running:\t\t{total_running}")
print(f"Total done:\t\t{total_done}")
print(f"Total failed:\t\t{total_fail}")
print(f"Total error:\t\t{total_error}")
print(f"Total unrecognized:\t{total_error}")
print("")

total_finished = total_done + total_fail + total_error

progress = total_finished / total_commands * 100
print(f"Overall progress: \t{progress:.2f}%")

if total_finished == 0:
    success_rate = 0
else:
    success_rate = total_done / total_finished * 100

print(f"Overall success rate: \t{success_rate:.2f}%")
