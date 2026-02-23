import os
import re

def find_md_files(root_dir):
    """Finds all markdown files, ignoring plugin folders."""
    md_files = []
    exclude_dirs = ['.obsidian', '.stfolder', 'picture']
    for root, dirs, files in os.walk(root_dir, topdown=True):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for file in files:
            if file.endswith(".md"):
                md_files.append(os.path.join(root, file))
    return md_files

def extract_link_targets(file_path):
    """Extracts the targets of all wikilinks in a file."""
    targets = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Corrected Regex to find the target part of a wikilink, before | or #
        matches = re.findall(r'[[([^]|#\n]+?)\s*(?:|[^]\n]*)?(?:#[^]\n]*)?\s*]]', content)
        for target in matches:
            targets.add(target.strip())
    except Exception:
        pass
    return targets

def main():
    root_directory = "."
    all_md_files = find_md_files(root_directory)
    
    # Create a set of all existing note names (without .md extension)
    existing_notes = {os.path.splitext(os.path.basename(f))[0] for f in all_md_files}
    
    # Create a set of all notes that are linked to
    all_linked_notes = set()
    for md_file in all_md_files:
        all_linked_notes.update(extract_link_targets(md_file))

    # Find the difference
    orphaned_notes = existing_notes - all_linked_notes

    print("--- Orphaned Files Report ---")
    if orphaned_notes:
        print(f"Found {len(orphaned_notes)} files that are not linked to from any other file:")
        for note in sorted(list(orphaned_notes)):
            # Ignore files that are clearly not notes
            if 'temp' not in note.lower() and 'debug' not in note.lower() and 'filter' not in note.lower() and 'process' not in note.lower() and 'repair' not in note.lower() and 'find_orphans' not in note.lower() and note != '未命名':
                print(f"- {note}.md")
    else:
        print("No orphaned files found.")

if __name__ == "__main__":
    main()
