#!/usr/bin/env python3
"""
Script to automatically fix use_build_context_synchronously errors in Dart files.
"""

import json
import re
from pathlib import Path
from typing import List, Dict, Set

def load_errors(errors_file: str) -> List[Dict]:
    """Load and parse the errors.txt file."""
    with open(errors_file, 'r') as f:
        content = f.read().strip()
    return json.loads(content)

def get_context_errors(errors: List[Dict]) -> Dict[str, List[int]]:
    """Extract use_build_context_synchronously errors grouped by file."""
    context_errors = {}
    for error in errors:
        if error.get('code', {}).get('value') == 'use_build_context_synchronously':
            file_path = error['resource']
            line_num = error['startLineNumber']
            if file_path not in context_errors:
                context_errors[file_path] = []
            context_errors[file_path].append(line_num)

    # Sort line numbers for each file
    for file_path in context_errors:
        context_errors[file_path] = sorted(set(context_errors[file_path]))

    return context_errors

def find_function_start(lines: List[str], error_line: int) -> int:
    """Find the start of the function containing the error line."""
    # Look backwards from error line to find function start
    for i in range(error_line - 1, -1, -1):
        line = lines[i].strip()
        # Look for async function declarations
        if 'async' in line and ('{' in line or (i + 1 < len(lines) and '{' in lines[i + 1])):
            return i
        # Look for function declarations
        if re.match(r'(Future|void|FutureOr).*\(.*\).*\{?', line):
            return i
    return error_line

def find_await_before_line(lines: List[str], start: int, target: int) -> int:
    """Find the last await statement before the target line."""
    last_await = start
    for i in range(start, target):
        if 'await' in lines[i]:
            last_await = i
    return last_await

def fix_context_in_file(file_path: str, error_lines: List[int]) -> int:
    """Fix context errors in a single file."""
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()

        original_lines = lines.copy()
        fixed_count = 0
        already_has_check = set()

        # Process errors from bottom to top to maintain line numbers
        for error_line in reversed(error_lines):
            if error_line - 1 >= len(lines):
                continue

            # Find the function containing this error
            func_start = find_function_start(lines, error_line - 1)

            # Find the last await before this line
            last_await = find_await_before_line(lines, func_start, error_line - 1)

            # Insert mounted check after the last await
            insert_line = last_await + 1

            # Skip if we already added a check at this position
            if insert_line in already_has_check:
                continue

            # Check if there's already a mounted check nearby
            check_range = lines[max(0, insert_line - 2):min(len(lines), insert_line + 2)]
            if any('context.mounted' in line for line in check_range):
                continue

            # Get the indentation of the next line
            indent = ''
            if insert_line < len(lines):
                indent = re.match(r'^(\s*)', lines[insert_line]).group(1)

            # Insert the mounted check
            mounted_check = f'{indent}if (!context.mounted) return;\n\n'
            lines.insert(insert_line, mounted_check)
            already_has_check.add(insert_line)
            fixed_count += 1

        # Only write if we made changes
        if fixed_count > 0:
            with open(file_path, 'w') as f:
                f.writelines(lines)

        return fixed_count
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return 0

def main():
    errors_file = '/Users/rakinzisilver/Downloads/POSpro-App/errors.txt'

    # Load errors
    print("Loading errors...")
    errors = load_errors(errors_file)
    context_errors = get_context_errors(errors)

    print(f"Found {sum(len(v) for v in context_errors.values())} context errors in {len(context_errors)} files")

    # Fix each file
    total_fixed = 0
    for file_path, error_lines in sorted(context_errors.items()):
        print(f"Fixing {file_path.split('/')[-1]} ({len(error_lines)} errors)...", end=' ')
        fixed = fix_context_in_file(file_path, error_lines)
        total_fixed += fixed
        print(f"✓ {fixed} fixed")

    print(f"\n✅ Total fixed: {total_fixed} context checks added")

if __name__ == '__main__':
    main()
