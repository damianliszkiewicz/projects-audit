# projects-audit

`projects-audit` is an early-stage Bash-based local scanner for Node.js project folders. It helps developers make a quick first-pass check for a small set of known malicious, suspicious, or vulnerable npm dependencies across local projects.

## Why This Exists

Node.js projects often depend on large dependency trees, and software supply-chain issues can appear in both direct and transitive npm packages. A developer may have many local project folders, old lockfiles, and installed dependency trees that are worth checking quickly before deeper review.

This project is intended to be a fast local first-pass scanner. It is not a replacement for full security platforms, package manager audits, software composition analysis tools, or manual security review. The goal is to make targeted checks simple, transparent, and easy to extend.

## Current Features

- Finds Node.js projects by searching for `package.json` files.
- Skips `node_modules` during project discovery to keep scans faster.
- Checks each discovered project for `plain-crypto-js` in `package.json`, `package-lock.json`, and the top-level `node_modules` folder.
- Checks for Axios versions `1.14.1` and `0.30.4` in `package.json`, `package-lock.json`, and `npm list axios` output.
- Prints readable terminal output showing discovered projects, inspected files, skipped checks, and warnings.

## Usage

Clone this repository, then make the scanner executable:

```bash
git clone <repository-url>
cd projects-audit
chmod +x audit-projects.sh
```

Run the scanner from the repository directory:

```bash
./audit-projects.sh
```

By default, the script scans the current directory and its subdirectories. You can also pass a specific path:

```bash
./audit-projects.sh ~/Path/To/Your/Projects
```

The script has no package install step today. It uses standard shell commands plus `npm list axios` when a scanned project has a `node_modules` directory.

## What the Scanner Checks

The current implementation is intentionally small and rule-based. For every discovered Node.js project, `audit-projects.sh` checks:

- `package.json` for a direct reference to `plain-crypto-js`.
- `package-lock.json`, when present, for a reference to `plain-crypto-js`.
- `node_modules/plain-crypto-js`, when `node_modules` exists, for a physical installed copy of the package.
- `package.json` and `package-lock.json` for `axios` entries near the version strings `1.14.1` or `0.30.4`.
- `npm list axios` output for installed Axios versions matching `1.14.1` or `0.30.4`.

These checks are currently implemented with Bash, `find`, `grep`, and `npm list`. The scanner does not yet provide JSON output, advisory references, version range parsing, automated remediation, or a general vulnerability database.

## AI-Assisted Vulnerability Research Vision

Future versions may use AI-assisted workflows to help research recent npm and package vulnerabilities from public sources such as CVEs, GitHub Security Advisories, npm advisories, changelogs, maintainer disclosures, and security reports.

The intended role of AI is to help summarize advisories, extract affected package and version data, draft candidate detection rules, and generate practical remediation guidance. AI should not be treated as the source of truth. Every scanner rule should reference a public advisory, maintainer disclosure, or other trusted source that can be reviewed by contributors.

## Roadmap

### Short Term

- Add more detection rules for known malicious or vulnerable packages.
- Add tests for the existing `plain-crypto-js` and Axios checks.
- Add advisory or source references for each rule.
- Add clearer remediation messages to warning output.

### Medium Term

- Add JSON output for CI and automation use cases.
- Add a GitHub Actions example.
- Add documentation for contributing new rules.
- Improve version matching beyond simple `grep` checks.

### Long Term

- Build an AI-assisted workflow for monitoring recent npm vulnerabilities and generating candidate scanner rules.
- Require trusted public sources for generated or proposed rules.
- Support a maintainable rule format separate from the scanner script.
- Expand reporting while keeping local scanning fast and understandable.

## Contributing

Contributions are welcome, especially small, well-documented rules and tests. Useful contributions include new package detections, clearer output, test fixtures, documentation improvements, and examples for CI usage.

When proposing a new detection rule, please include:

- Package name.
- Affected version or version range.
- Short explanation of the risk.
- Advisory or source link.
- Recommended remediation.
- Test case or fixture, if possible.

Rules should be easy to review and should avoid relying on unsupported claims. Public sources are important so maintainers and users can understand why a package or version is flagged.

## Project Status

This project is early-stage and actively evolving. The current scanner is useful for a narrow set of targeted checks, but it is not yet a comprehensive Node.js security scanner.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
