#! /bin/python3

import shutil
import os


KEY = "GRUB_CMDLINE_LINUX_DEFAULT"
FIX = "iommu=soft"

def get_kv(line):
	key = ""
	value = ""
	key_completed = False
	for c in line:
		if not key_completed:
			if c == "=":
				key_completed = True
			else:
				key += c
		else:
			value += c
			
	return key, value
		
def split_values(value_line):
	values = []
	value = ""
	for c in value_line:
		if c == " ":
			if value != "":
				values.append(value)
			value = ""
		else:
			value += c
			
	if value != "":
		values.append(value)
		
	return values
	
def values_to_line(values):
	line = ""
	for value in values:
		line += value + " "
	
	line = line.strip()
	return f'"{line}"'
	
if __name__ == "__main__":
	print("Fixing USB 2.0 via Grub modification")
	
	grub_file_path = "/etc/default/grub"
	
	with open(grub_file_path, "r") as grub_file:
		grub_file_lines = grub_file.readlines()
	
	target_line_index = -1
	target_line_key = None
	target_line_value = None
	for i, line in enumerate(grub_file_lines):
		if line.startswith("#"):
			continue
		
		line_trimmed = line.replace("\n", "")
		print(line_trimmed)
		
		target_line_key, target_line_value = get_kv(line_trimmed)
		if target_line_key == KEY:
			target_line_index = i
			break
		
	if target_line_index != -1:
		print(f"|{target_line_value}|")
		value_unquoted = target_line_value.replace('"', "")
		print(value_unquoted)
		value_items = split_values(value_unquoted)
		print(value_items)
		if FIX in value_items:
			print("Fix already applied!")
			quit(0)
			
		value_items.append(FIX)
		value_line_fixed = values_to_line(value_items)
		line_fixed = f'{target_line_key}={value_line_fixed}\n'
		grub_file_lines[target_line_index] = line_fixed
	else:
		print("Key not found, adding new line")
		grub_file_lines.append(f'{KEY}="{FIX}"\n')
	
	backup_filepath = grub_file_path + ".original"
	print(f"Writing backup to {backup_filepath}")
	
	shutil.copyfile(grub_file_path, backup_filepath)
	
	print("Writing fix...")
	with open(grub_file_path, "w") as grub_file:
		grub_file.writelines(grub_file_lines)
		
	proceed = input("CHECK GRUB FILE AND TYPE '[Y]ES' TO PROCEED: ")
	
	if proceed.lower().startswith("y"):
		os.system('sudo update-grub')
		print("Reboot to apply changes")
	else:
		print("Reverting changes...")
		os.remove(grub_file_path)
		shutil.copyfile(backup_filepath, grub_file_path)
		os.remove(backup_filepath)
		print("Changes reverted.")
	
