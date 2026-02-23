import os
import re

def find_md_files(root_dir):
    """Finds all markdown files, ignoring specified directories."""
    md_files = []
    exclude_dirs = {'.obsidian', '.stfolder', 'picture'}
    for root, dirs, files in os.walk(root_dir, topdown=True):
        # Exclude directories in-place
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for file in files:
            if file.endswith(".md"):
                md_files.append(os.path.join(root, file))
    return md_files

def get_basenames(md_files):
    """Gets a set of basenames from a list of file paths."""
    return {os.path.splitext(os.path.basename(f))[0] for f in md_files}

def process_raw_links(raw_links_file):
    """Reads the raw grep output and extracts clean, unique link targets."""
    targets = set()
    try:
        with open(raw_links_file, 'r', encoding='utf-8') as f:
            for line in f:
                # Regex to find the target part of a wikilink, before | or #
                match = re.search(r'\[\[\s*([^\]|#\n]+)', line)
                if match:
                    target = match.group(1).strip()
                    # Basic filtering for invalid note names
                    if target and len(target) > 1 and not target.endswith(('.png', '.pdf', '.jpg')):
                        targets.add(target)
    except Exception as e:
        print(f"Error processing {raw_links_file}: {e}")
    return targets

def main():
    root_directory = "."
    
    # 1. Get all existing markdown filenames
    all_md_files = find_md_files(root_directory)
    existing_notes = get_basenames(all_md_files)
    
    # 2. Get all linked-to targets
    all_linked_notes = process_raw_links('all_links.txt')

    # 3. Find the difference to identify orphans
    orphaned_notes = existing_notes - all_linked_notes

    # 4. Find missing notes
    truly_missing_notes = all_linked_notes - existing_notes

    print("--- Link Audit Report ---")
    
    print(f"\n=== Potentially Redundant/Orphaned Files ({len(orphaned_notes)}) ===")
    if orphaned_notes:
        for note in sorted(list(orphaned_notes)):
            # Filter out utility/script files
            if not any(util in note.lower() for util in ['debug', 'filter', 'process', 'repair', 'find_orphans', '未命名', 'temp']):
                 print(f"- {note}.md")
    else:
        print("No orphaned files found.")
        
    print(f"\n=== Truly Missing Files ({len(truly_missing_notes)}) (Top 50) ===")
    if truly_missing_notes:
        for note in sorted(list(truly_missing_notes))[:50]:
            print(f"- {note}")
        if len(truly_missing_notes) > 50:
            print("...")
    else:
        print("No missing files found.")


if __name__ == "__main__":
    main()