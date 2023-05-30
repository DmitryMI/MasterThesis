#!/bin/python3

import subprocess
import os
import os.path
import argparse
from alive_progress import alive_bar
import time

RUNFILE_NAME = "./runfile.remote.txt"

def get_runfile():
    if os.path.exists(RUNFILE_NAME):
        os.remove(RUNFILE_NAME)
    process = subprocess.Popen("./get_runfile.sh", stdout=subprocess.PIPE)
    process.wait()
        
    if not os.path.exists(RUNFILE_NAME):
        print("Failed to download runfile.txt")
        quit(1)
    
    with open(RUNFILE_NAME) as runfile:
        lines = runfile.readlines()
    return lines

def get_runinfo(runfile_lines, do_print=False):
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
            if do_print:
                print(f"Line {line}: fail!")
            
        elif line[0] == "e":
            total_error += 1
            total_commands += 1
            if do_print:
                print(f"Line {line}: error!")
            
        elif line[0] == "r":
            total_running += 1
            total_commands += 1
        else:
            total_unrecognized += 1
            if do_print:
                print(f"Unknown status in line {line}")
            
    return total_commands, total_inactive, total_running, total_done, total_fail, total_error, total_unrecognized

def check_limit(counter, limit):
    if limit is None or limit == 0:
        return True
    return counter < limit

def monitor(period, period_waiting, limit):
    if period is None or period == 0:
        return
    
    if limit is not None and limit > 0:
        print(f"Monitor will only run for {limit} cycles.")
    else:
        print("Monitor will run until all jobs are finished.")
    
    counter = 0
    
    runfile_lines = get_runfile()
    total_initial, inactive, _, done, failed, error, _ = get_runinfo(runfile_lines)

    finished_previous = done + failed + error
    finished = finished_previous
    
    if inactive == total_initial:
        print(f"HPC not started yet. Checking every {period_waiting} seconds...")
        with alive_bar(title="Waiting", unknown="wait") as bar:
            while(check_limit(counter, limit) and inactive == total_initial):
                runfile_lines = get_runfile()
                total, inactive, _, done, failed, error, _ = get_runinfo(runfile_lines)
                if total != total_initial:
                    print("Runfile changed!")
                
                if inactive != total_initial:
                    bar(1)
                
                counter += 1
                time.sleep(period_waiting)
    
    if total_initial != inactive:
        print(f"Monitoring progress, checking every {period} seconds...")
    else:
        print("Monitor have reached refresh limit. HPC did not start.")
        return
    
    with alive_bar(total_initial, title="Job progress") as bar:
        if finished > 0:
            bar(finished, skipped=True)
        
        while(check_limit(counter, limit) and finished < total_initial):
            runfile_lines = get_runfile()
            total, _, _, done, failed, error, _ = get_runinfo(runfile_lines)
            if total != total_initial:
                print("Runfile changed!")
                
            
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

def filter_runfile(filt_status):
    res = []
    runfile_lines = get_runfile()
    for line in runfile_lines:
        if line.strip() == "":
            continue
        
        status = line[0]
        
        if type(filt_status) is str:
            if status == filt_status:
                res.append(line)
        elif type(filt_status) is list:
            if status in filt_status:
                res.append(line) 
        else:
            if filt_status(status):
                res.append(line)
    return res
     

def main():
    parser = argparse.ArgumentParser(
        prog="Get Run Info",
    )
    
    parser.add_argument("-w", "--waiting_period", required=False, default=None, type=int)
    parser.add_argument("-m", "--monitor_period", required=False, default=None, type=int)
    parser.add_argument("-n", "--monitor_number", required=False, default=None, type=int)
    parser.add_argument("--list", required=False, default=None, action="append")

    args = parser.parse_args()
    
    
    monitor_period = args.monitor_period
    waiting_period = args.waiting_period
    
    if waiting_period is None:
        waiting_period = monitor_period
    
    monitor_number = args.monitor_number
   
    monitor(monitor_period, waiting_period, monitor_number)
    print()
    
    runfile_lines = get_runfile()
    if args.list:
        runfile_lines = filter_runfile(args.list)
        for line in runfile_lines:
            print(line)
        return
    
    
    t, i, r, d, f, e, u = get_runinfo(runfile_lines, True)
    print_runinfo(t, i, r, d, f, e, u)
    
if __name__ == "__main__":
    main()
