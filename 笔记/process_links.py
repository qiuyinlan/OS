import os
import re
import sys

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

def build_canonical_map(md_files):
    """Builds a map from any discovered variant to the best existing canonical filename."""
    existing_basenames = {os.path.splitext(os.path.basename(f))[0] for f in md_files}
    canonical_map = {name: name for name in existing_basenames}

    # Pass 1: Prioritize shorter exact filenames
    for name in sorted(list(existing_basenames), key=len):
        match = re.match(r'(.+?)\s*\((.+?)\)', name)
        if match:
            short_name = match.group(1).strip()
            if short_name in existing_basenames:
                canonical_map[name] = short_name
    
    # Pass 2: Map short link targets to existing longer filenames if the short file doesn't exist
    for name in existing_basenames:
        match = re.match(r'(.+?)\s*\((.+?)\)', name)
        if match:
            short_name_from_long = match.group(1).strip()
            acronym_inside_parens = match.group(2).strip()

            if acronym_inside_parens not in existing_basenames:
                 canonical_map[acronym_inside_parens] = name
            
            if short_name_from_long not in existing_basenames:
                canonical_map[short_name_from_long] = name

    return canonical_map, existing_basenames


def extract_links(file_path):
    """Extracts valid wikilinks from a markdown file."""
    links = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        all_matches = re.findall(r'\[\[\s*([^\]|#\n]+?)\s*(?:\|[^\]\n]*)?(?:#[^\]\n]*)?\s*\]\]', content)

        for link_target in all_matches:
            cleaned_link = link_target.strip()
            if cleaned_link and len(cleaned_link) > 1 and not re.fullmatch(r'[\d\W_]+', cleaned_link):
                 if not cleaned_link.endswith(('.md', '.png', '.pdf', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.bmp')):
                    links.add(cleaned_link)
    except Exception:
        pass
    return links

def main():
    root_directory = "."
    all_md_files = find_md_files(root_directory)
    
    canonical_map, existing_basenames = build_canonical_map(all_md_files)
    
    all_links_with_locs = []
    all_link_targets = set()
    for md_file in all_md_files:
        links_in_file = extract_links(md_file)
        for link in links_in_file:
            all_links_with_locs.append({'link': link, 'file': md_file})
            all_link_targets.add(link)
            
    redundant_links = {}
    missing_links = set()
    canonical_link_targets = set()

    for item in all_links_with_locs:
        link = item['link']
        file_loc = item['file']

        if link in existing_basenames:
            canonical_target = canonical_map.get(link, link)
            canonical_link_targets.add(canonical_target)
            if canonical_target != link:
                if (link, file_loc) not in redundant_links:
                    redundant_links[(link, file_loc)] = canonical_target
        elif link in canonical_map:
            canonical_target = canonical_map[link]
            canonical_link_targets.add(canonical_target)
            if (link, file_loc) not in redundant_links:
                 redundant_links[(link, file_loc)] = canonical_target
        else:
            missing_links.add(link)
    
    # Files that are never linked to
    orphaned_files = existing_basenames - canonical_link_targets
    # Filter this list to only include files that look like redundant long names
    potentially_redundant_files = {f for f in orphaned_files if re.search(r'\s*\((.+?)\)', f)}


    # --- Reporting ---
    print("--- Analysis Report ---")
    print(f"Scanned {len(all_md_files)} markdown files.")
    
    print("\n=== Potentially Redundant Files (Orphaned Aliases) ===")
    if potentially_redundant_files:
        print(f"Found {len(potentially_redundant_files)} files that are never linked to and may be redundant:")
        for fname in sorted(list(potentially_redundant_files)):
            print(f"- {fname}.md")
    else:
        print("No orphaned alias files found.")


    print("\n=== Redundant Links to Consolidate ===")
    if redundant_links:
        print(f"Found {len(redundant_links)} link instances to standardize:")
        # Sort for consistent output
        sorted_redundant = sorted(redundant_links.items(), key=lambda x: (x[0][1], x[0][0]))
        for (redundant, file_loc), canonical in sorted_redundant:
            print(f"- In '{file_loc}': Change '[[{redundant}]]' to '[[{canonical}]]'")
    else:
        print("No redundant links found.")

    print("\n=== Truly Missing Files (Top 50) ===")
    if missing_links:
        print(f"Found {len(missing_links)} unique notes that seem to be missing:")
        for missing in sorted(list(missing_links))[:50]:
            print(f"- {missing}")
        if len(missing_links) > 50:
            print("...")
    else:
        print("No missing files found.")

if __name__ == "__main__":
    main()