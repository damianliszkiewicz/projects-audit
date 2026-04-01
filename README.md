# Node Project Security Scanner

A lightweight, fast Bash script that scans your local directories for specific vulnerable Node.js packages. 

Currently, this script is configured to hunt for:
* Malicious package: `plain-crypto-js`
* Vulnerable versions of Axios: `1.14.1` and `0.30.4`

## How it works
To keep the scan incredibly fast, the script actively skips digging into large `node_modules` folders during the discovery phase. Instead, it locates `package.json` files to identify project roots. Once a project is found, it explicitly checks:
1. `package.json` for direct dependencies.
2. `package-lock.json` for nested dependencies.
3. `node_modules` (if present) for physical installation paths.
4. `npm list` to catch deeply nested or hidden vulnerable versions.

## Usage

### 1. Download the script
Clone this repository or download the `audit-projects.sh` file directly.

### 2. Make it executable
Before running the script, you need to grant it execution permissions:
\`\`\`bash
chmod +x audit-projects.sh
\`\`\`

### 3. Run the scan
By default, running the script without arguments will scan the **current directory** and all its subdirectories.
\`\`\`bash
./audit-projects.sh
\`\`\`

You can also pass a specific path to scan a different directory:
\`\`\`bash
./audit-projects.sh ~/Path/To/Your/Projects
\`\`\`

## Output
The script is "chatty" by default, meaning it will print the path of every `package.json` and `package-lock.json` it inspects. If it detects a targeted vulnerability, it will print a highly visible warning beneath the affected file.