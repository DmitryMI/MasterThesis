#!/bin/python3

import subprocess
import os
import os.path
import argparse
from alive_progress import alive_bar
import time

RUNFILE_NAME = "./runfile.remote.txt"

def get_runfile():
    os.remove(RUNFILE_NAME)
    process = subprocess.Popen("./get_runfile.sh", stdout=subprocess.PIPE)
    process.wait()
        
    if not os.path.exists(RUNFILE_NAME):
        print("Failed to download runfile.txt")
        quit(1)
    
    with open(RUNFILE_NAME) as runfile:
        lines = runfile.readlines()
    return lines

def get_runinfo(runfile_lines):
    total_commands = 0
    total_inactive = 0
    total_running = 0
    total_done = 0
    total_fail = 0
    total_error = 0
    total_unrecognized = 0

    for line in runfile_lines:
        if line.strip() == "":
            continue
            
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
            
    return total_commands, total_inactive, total_running, total_done, total_fail, total_error, total_unrecognized

def check_limit(counter, limit):
    if limit is None or limit == 0:
        return True
    return counter < limit

def monitor(period, limit):
    if period is None or period == 0:
        return
    
    counter = 0
    
    runfile_lines = get_runfile()
    total_initial, inactive, _, done, failed, error, _ = get_runinfo(runfile_lines)

    finished_previous = done + failed + error
    finished = finished_previous
    
    if inactive == total_initial:
        print("HPC not started yet. Waiting...")
        with alive_bar(1) as bar:
            while(check_limit(counter, limit) and inactive == total_initial):
                total, inactive, _, done, failed, error, _ = get_runinfo(runfile_lines)
                if total != total_initial:
                    print("Runfile changed!")
                    return
                
                if inactive != total_initial:
                    bar(finished_new)
                
                counter += 1
                time.sleep(period)
    
    with alive_bar(total_initial) as bar:
        if finished > 0:
            bar(finished)
        
        while(check_limit(counter, limit) and finished < total_initial):
            total, _, _, done, failed, error, _ = get_runinfo(runfile_lines)
            if total != total_initial:
                print("Runfile changed!")
                return
            
            finished = done + failed + error
            finished_new = finished - finished_previous
            finished_previous = finished
            if finished_new > 0:
                bar(finished_new)
            
            counter += 1
            time.sleep(period)

    
def print_runinfo(t, i, r, d, f, e, u):
    print("RUN INFO:")
    if t is not None:
        print(f"Total commands:\t\t{t}")
        
    if i is not None:
        print(f"Total inactive:\t\t{i}")
    
    if r is not None:
        print(f"Total running:\t\t{r}")
    
    if d is not None:
        print(f"Total done:\t\t{d}")
    
    if f is not None:
        print(f"Total failed:\t\t{f}")
    
    if e is not None:
        print(f"Total error:\t\t{e}")
    
    if u is not None:
        print(f"Total unrecognized:\t{u}")
        
    print("")

    if d is None or f is None or e is None or t is None:
        pass
    else:
        total_finished = d + f + e
        progress = total_finished / t * 100
        print(f"Overall progress: \t{progress:.2f}%")

        if total_finished == 0:
            success_rate = 0
        else:
            success_rate = d / total_finished * 100

    print(f"Overall success rate: \t{success_rate:.2f}%")

def main():
    parser = argparse.ArgumentParser(
        prog="Get Run Info",
    )
    
    parser.add_argument("-m", "--monitor_period", required=False, default=None, type=int)
    parser.add_argument("-n", "--monitor_number", required=False, default=None, type=int)

    args = parser.parse_args()
    monitor_period = args.monitor_period
    monitor_number = args.monitor_number

    runfile_lines = get_runfile()

    t, i, r, d, f, e, u = get_runinfo(runfile_lines)

    if t == 0:
        print("runfile contains no commands!")
        quit(0)
            
    monitor(monitor_period, monitor_number)
    print()
    
    print_runinfo(t, i, r, d, f, e, u)
    
if __name__ == "__main__":
    main()
