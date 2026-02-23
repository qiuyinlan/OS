import os
import re
import sys

# Define root directory based on current working directory
ROOT_DIR = os.getcwd()

def find_md_files(root_dir):
    """Finds all markdown files, ignoring plugin folders."""
    md_files = []
    exclude_dirs = ['.obsidian', '.stfolder', 'picture']
    for root, dirs, files in os.walk(root_dir, topdown=True):
        # Exclude specified directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for file in files:
            if file.endswith(".md"):
                md_files.append(os.path.join(root, file))
    return md_files

def repair_link_in_file(file_path, old_link_target, new_link_target):
    """
    Replaces all occurrences of a specific redundant wikilink target with its canonical form
    within a given file. Handles [[old]] and [[old|alias]] forms.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Regex to find [[old_link_target]] or [[old_link_target|alias]]
        # Need to escape old_link_target for regex special characters
        escaped_old_link_target = re.escape(old_link_target)
        
        # This regex will match the full wikilink: [[target]] or [[target|alias]]
        # We replace only the target part if it matches.
        # It's crucial to correctly handle the capture groups.

        # Pattern: [[ (potentially spaces) target (optional |alias or #header) (potentially spaces) ]]
        # We need to replace the 'target' part if it matches old_link_target
        # And construct the new link string.

        modified_content = content
        replacements_made = 0

        # Find all wikilinks that need to be updated
        # Group 1: The full link target (before | or #)
        # Group 2: The optional alias part (including |)
        # Group 3: The optional header part (including #)
        # Example: [[LDT|Local Descriptor Table]] -> Group 1="LDT", Group 2="|Local Descriptor Table"
        # Example: [[LDT#Section]] -> Group 1="LDT", Group 3="#Section"
        # Example: [[LDT]] -> Group 1="LDT"

        # Find all actual instances of the old link target within wikilinks
        # This regex matches the entire [[...]] structure
        # (?:[[\s*)               # Non-capturing group for [[ and leading spaces
        # (old_link_target)        # Capturing group for the exact old link target
        # (\s*                     # Potentially trailing spaces
        # (?:|[^\]\n]*)?          # Optional alias part
        # (?:#[^\]\n]*)?           # Optional header part
        # )                        # End of optional parts
        # (\s*\]\])                # Trailing spaces and ]]
        
        # Simpler approach: find the full [[...]] structure, then check its target
        
        # Pattern to capture the entire wikilink and its internal parts
        # Group 1: The link target (before | or #)
        # Group 2: The optional alias part (starting with |)
        # Group 3: The optional header part (starting with #)
        
        # This pattern should correctly identify wikilinks that *start* with the old_link_target
        # and replace them
        pattern = r'(\[\[\s*)(' + escaped_old_link_target + r')(\s*(?:\|[^\\\]\n]*)?(?:#[^\\\]\n]*)?\s*\]\])'
        
        def replacement_func(match):
            nonlocal replacements_made
            # Ensure we are only replacing the link target, not the alias part if it's there
            # Example: [[LDT|Some Alias]] -> we want to change LDT to LDT (Local Descriptor Table)
            # Result: [[LDT (Local Descriptor Table)|Some Alias]]
            
            current_target = match.group(2) # This is the old_link_target that was matched
            suffix = match.group(3) # This is the part after the target, e.g., "|alias]]" or "#header]]" or "]]"

            if current_target == old_link_target: # Ensure we're only replacing the exact target
                replacements_made += 1
                return match.group(1) + new_link_target + suffix
            else:
                return match.group(0) # Return original match if not exact target (shouldn't happen with this regex)

        modified_content = re.sub(pattern, replacement_func, content)
        
        if replacements_made > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            print(f"  - Replaced {replacements_made} occurrences in '{file_path}'.")
            return True
        else:
            # print(f"  - No replacements needed in '{file_path}'. (Found 0 matches for '[[{old_link_target}]]')", file=sys.stderr)
            return False

    except FileNotFoundError:
        print(f"Error: File not found at '{file_path}'", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error processing '{file_path}': {e}", file=sys.stderr)
        return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 repair_links.py <old_link_target> <new_link_target>")
        print("Example: python3 repair_links.py 'LDT' 'LDT (Local Descriptor Table)'")
        sys.exit(1)

    old_link_target = sys.argv[1]
    new_link_target = sys.argv[2]

    print(f"Attempting to change '[[{old_link_target}]]' to '[[{new_link_target}]]'")

    md_files = find_md_files(ROOT_DIR)
    
    files_modified_count = 0
    for file_path in md_files:
        if repair_link_in_file(os.path.join(ROOT_DIR, file_path), old_link_target, new_link_target):
            files_modified_count += 1
    
    print(f"\nCompleted. Modified links in {files_modified_count} files.")

if __name__ == "__main__":
    main()
