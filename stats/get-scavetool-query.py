#!/usr/bin/env python3

with open("scavetool-variables.txt", "r") as f:
    lines = f.readlines()
    
fragments = []

for line in lines:
    fragments.append(f"name({line.rstrip()})")
    
query = " OR ".join(fragments)

print(query)
