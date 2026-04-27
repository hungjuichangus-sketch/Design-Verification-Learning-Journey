import re
import os

def parse_simulation_log(file_path):
    uvm_errors = 0
    uvm_fatals = 0
    sim_time = "Unknown"
    cov_string = "0.000%"
    coverage_value = 0.0

    if not os.path.exists(file_path):
        print(f"Error: Could not find the log file at '{file_path}'")
        return

    error_pattern = re.compile(r"UVM_ERROR\s*:\s*(\d+)")
    fatal_pattern = re.compile(r"UVM_FATAL\s*:\s*(\d+)")
    time_pattern = re.compile(r"Time:\s*(\d+\s*ns)")
    cov_pattern = re.compile(r"TYPE .*uart_coverage/cg\s*\|\s*([\d\.]+\%)")

    with open(file_path, 'r') as file:
        for line in file:
            err_match = error_pattern.search(line)
            if err_match:
                uvm_errors = int(err_match.group(1))
            
            fat_match = fatal_pattern.search(line)
            if fat_match:
                uvm_fatals = int(fat_match.group(1))
            
            time_match = time_pattern.search(line)
            if time_match:
                sim_time = time_match.group(1)
            
            cov_match = cov_pattern.search(line)
            if cov_match:
                cov_string = cov_match.group(1)
                coverage_value = float(cov_string.replace("%", ""))

    print("\n" + "="*50)
    print("UART UVM REGRESSION DASHBOARD")
    print("="*50)
    print(f"Total Simulation Time: {sim_time}")
    print(f"Final Coverage: {cov_string}")
    print("-"*50)

    if uvm_errors == 0 and uvm_fatals == 0 and coverage_value == "100.0":
        print(f"STATUS: PASSED with {cov_string} coverage")
    elif uvm_errors == 0 and uvm_fatals == 0:
        print(f"STATUS: PASSED but only with {cov_string} coverage")
    else:
        print(f"STATUS: FAILED ({uvm_errors} Errors, {uvm_fatals} Fatals)")
    print("="*50 + "\n")

if __name__ == "__main__":
    parse_simulation_log("sim_log.txt")

# \s matches whitespace (space, tab), \d matches a digit (0-9)
#
# Quantifiers:
# + means "one or more" (must exist)
# * means "zero or more" (optional)
# ex: \s+ matches " ", but not ""; \s* matches both " " and ""
# ex: \d+ matches "1" or "187", but not ""; \d* matches all
#
# Wildcards & Groups:
# .*?  is the "Lazy Wildcard": skips everything until it hits the next target.
# []   is a Character Set: matches one character from the options inside.
#      ex: [\dA-F] matches a digit OR letters A through F (Hex).
#
# Capture Groups:
# group(0) is the WHOLE string matched by the pattern.
# group(1) is the value captured inside the first set of ()
# group(2) is the value captured inside the second set of ()
#
# Example:
# Pattern: r"ID:\s*(\d+).*?DATA:\s*(0x[\dA-F]+)"
# Log line: "# [MONITOR] ID: 101 | DATA: 0xAA | STATUS: SUCCESS"
# 
# group(1) captures "101" (ID)
# group(2) captures "0xAA" (DATA)
# .*? skips the " | " between the ID and the DATA.
