#!/bin/bash

# ==============================================================================
# Node Project Security Scanner
# This script hunts for specific vulnerable dependencies across your projects.
# ==============================================================================

# STEP 1: Determine the target directory
# We use "${1:-.}" to check if the user provided an argument (like /path/to/folder).
# If they didn't, it defaults to "." which means the current directory.
TARGET_DIR="${1:-.}"

echo "==================================================="
echo "[*] INITIATING SECURITY SCAN"
echo "[*] Target Directory: $TARGET_DIR"
echo "==================================================="
echo "[*] Searching for Node.js projects (looking for package.json files)..."

# STEP 2: Find the projects
# We use the 'find' command to locate projects.
# -name "node_modules" -prune: This tells 'find' to completely ignore node_modules 
# folders during the search phase. This makes the search exponentially faster.
# -o -name "package.json" -print: If it's NOT node_modules, look for package.json and print its path.
find "$TARGET_DIR" -name "node_modules" -prune -o -name "package.json" -print | while read -r pkg_path; do
    
    # Extract just the directory path from the full file path
    dir=$(dirname "$pkg_path")
    
    echo ""
    echo "---------------------------------------------------"
    echo "[+] PROJECT FOUND: $dir"
    echo "---------------------------------------------------"
    
    # ---------------------------------------------------------
    # STEP 3: Inspect package.json
    # ---------------------------------------------------------
    # We check the package.json to see if the vulnerability is a direct dependency.
    if [ -f "$dir/package.json" ]; then
        echo "    [*] Reading package.json..."
        
        # grep -q runs quietly. It just checks if the string exists.
        if grep -q '"plain-crypto-js"' "$dir/package.json"; then
            echo "        [!!!] WARNING: 'plain-crypto-js' found in package.json!"
        fi
        
        # grep -A1 grabs the matched line AND the line immediately after it (usually the version number).
        # We then pipe (|) that to grep -E to look for our specific vulnerable versions.
        axios_pkg_out=$(grep -A1 '"axios"' "$dir/package.json" | grep -E "1\.14\.1|0\.30\.4")
        if [ -n "$axios_pkg_out" ]; then
            echo "        [!!!] WARNING: Vulnerable 'axios' version found in package.json!"
        fi
    fi

    # ---------------------------------------------------------
    # STEP 4: Inspect package-lock.json
    # ---------------------------------------------------------
    # The lockfile shows the exact tree of everything installed, including nested dependencies.
    if [ -f "$dir/package-lock.json" ]; then
        echo "    [*] Reading package-lock.json..."
        
        if grep -q '"plain-crypto-js"' "$dir/package-lock.json"; then
            echo "        [!!!] WARNING: 'plain-crypto-js' found in package-lock.json!"
        fi

        axios_lock_out=$(grep -A1 '"axios"' "$dir/package-lock.json" | grep -E "1\.14\.1|0\.30\.4")
        if [ -n "$axios_lock_out" ]; then
            echo "        [!!!] WARNING: Vulnerable 'axios' version found in package-lock.json!"
        fi
    else
        echo "    [-] No package-lock.json found. Skipping lockfile check."
    fi

    # ---------------------------------------------------------
    # STEP 5: Inspect physical node_modules & run npm list
    # ---------------------------------------------------------
    # Finally, we check what is actually installed on the machine.
    if [ -d "$dir/node_modules" ]; then
        echo "    [*] Inspecting node_modules directory..."
        
        # Look for the physical folder of the malicious package
        if [ -d "$dir/node_modules/plain-crypto-js" ]; then
            echo "        [!!!] DANGER: 'plain-crypto-js' folder exists in node_modules!"
        fi

        echo "    [*] Running 'npm list axios' to check resolved dependency tree..."
        
        # We use a subshell (cd "$dir" && ...) to temporarily move into the project folder.
        # This ensures 'npm list' runs in the correct context without changing the script's main directory.
        # 2>/dev/null hides standard npm errors (like missing peer dependencies) to keep the output clean.
        npm_out=$(cd "$dir" && npm list axios 2>/dev/null | grep -E "1\.14\.1|0\.30\.4")
        
        # If the output variable is not empty (-n), we found a match!
        if [ -n "$npm_out" ]; then
            echo "        [!!!] WARNING: Vulnerable 'axios' version detected via 'npm list'!"
            echo "              Output trace: $npm_out"
        fi
    else
        echo "    [-] No node_modules folder found. Skipping physical installation checks."
    fi

done

echo ""
echo "==================================================="
echo "[*] SCAN COMPLETE"
echo "==================================================="