import re
import os

def parse_axi_lite_log(file_path):
    uvm_errors = 0
    uvm_fatals = 0
    sim_time = "Unknown"
    cov_string = "0.000%"
    coverage_value = 0.0

    if not os.path.exists(file_path):
        print(f"Error: Could not find the log file at '{file_path}'")
        return

    # Updated Patterns
    error_pattern = re.compile(r"UVM_ERROR\s*:\s*(\d+)")
    fatal_pattern = re.compile(r"UVM_FATAL\s*:\s*(\d+)")
    time_pattern = re.compile(r"Time:\s*(\d+\s*ns)")
    # Pattern updated for AXI-Lite hierarchy
    cov_pattern = re.compile(r"TYPE .*axi_lite_coverage/cg\s*\|\s*([\d\.]+\%)")

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
    print("AXI-LITE SLAVE REGRESSION DASHBOARD")
    print("="*50)
    print(f"Total Simulation Time: {sim_time}")
    print(f"Final Coverage:        {cov_string}")
    print("-"*50)

    # Fixed logic: comparing float to float
    if uvm_errors == 0 and uvm_fatals == 0 and coverage_value >= 100.0:
        print(f"STATUS: PASSED (100% Coverage)")
    elif uvm_errors == 0 and uvm_fatals == 0:
        print(f"STATUS: PASSED (Partial Coverage: {cov_string})")
    else:
        print(f"STATUS: FAILED ({uvm_errors} Errors, {uvm_fatals} Fatals)")
    print("="*50 + "\n")

if __name__ == "__main__":
    # Ensure this matches the name of your exported EDA Playground log
    parse_axi_lite_log("sim_log.txt")