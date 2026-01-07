import os

def read_list_file(filename):
    """Read and return lines from a file, ignoring empty lines."""
    if not os.path.exists(filename):
        print(f"Error: File '{filename}' not found.")
        return []
    
    with open(filename, 'r') as f:
        return [line.strip() for line in f if line.strip()]

def find_unique_ips(list1_items, list2_items):
    """
    Find IPs that are only in one list, not both.
    Returns entries from list1 with IPs not in list2, 
    and entries from list2 with IPs not in list1.
    """
    # Extract all IPs from each list
    def extract_ips(lst):
        ips = set()
        for item in lst:
            parts = item.split()
            if len(parts) >= 2:
                ips.add(parts[-1])  # Last part is IP
        return ips
    
    # Get entries for specific IPs
    def get_entries_for_ips(lst, target_ips):
        entries = []
        for item in lst:
            parts = item.split()
            if len(parts) >= 2:
                ip = parts[-1]
                if ip in target_ips:
                    description = ' '.join(parts[:-1])
                    entries.append((description, ip))
        return entries
    
    # Get all IPs from each list
    ips1 = extract_ips(list1_items)
    ips2 = extract_ips(list2_items)
    
    # Find IPs that are only in one list
    ips_only_in_list1 = ips1 - ips2  # IPs in list1 but not list2
    ips_only_in_list2 = ips2 - ips1  # IPs in list2 but not list1
    
    # Get full entries for these unique IPs
    entries_only_in_list1 = get_entries_for_ips(list1_items, ips_only_in_list1)
    entries_only_in_list2 = get_entries_for_ips(list2_items, ips_only_in_list2)
    
    return entries_only_in_list1, entries_only_in_list2

def main():
    """Main function to run the comparison."""
    # Read the files
    print("Reading list1.txt and list2.txt...")
    list1_items = read_list_file('list1.txt')
    list2_items = read_list_file('list2.txt')
    
    if not list1_items or not list2_items:
        print("\nError: One or both files are empty or not found.")
        print("Please ensure list1.txt and list2.txt exist in the same directory.")
        return
    
    print(f"Read {len(list1_items)} items from list1.txt")
    print(f"Read {len(list2_items)} items from list2.txt")
    print()
    
    # Find IPs that are only in one list
    entries_only_in_list1, entries_only_in_list2 = find_unique_ips(list1_items, list2_items)
    
    # Print results
    print("=" * 60)
    print("IPs ONLY in list1.txt (not in list2.txt):")
    print("=" * 60)
    if entries_only_in_list1:
        for desc, ip in sorted(entries_only_in_list1, key=lambda x: x[1]):  # Sort by IP
            print(f"{desc} {ip}")
    else:
        print("None")
    
    total_unique_list1 = len(entries_only_in_list1)
    print(f"\nTotal IPs only in list1.txt: {total_unique_list1}")
    
    print("\n" + "=" * 60)
    print("IPs ONLY in list2.txt (not in list1.txt):")
    print("=" * 60)
    if entries_only_in_list2:
        for desc, ip in sorted(entries_only_in_list2, key=lambda x: x[1]):  # Sort by IP
            print(f"{desc} {ip}")
    else:
        print("None")
    
    total_unique_list2 = len(entries_only_in_list2)
    print(f"\nTotal IPs only in list2.txt: {total_unique_list2}")
    
    print("\n" + "=" * 60)
    print("SUMMARY:")
    print("=" * 60)
    print(f"Total IPs only in list1.txt: {total_unique_list1}")
    print(f"Total IPs only in list2.txt: {total_unique_list2}")
    print(f"Total IPs not in both lists: {total_unique_list1 + total_unique_list2}")
    
    # Option to save results
    save = input("\nDo you want to save results to a file? (y/n): ").strip().lower()
    if save == 'y':
        with open('unique_ips_results.txt', 'w') as f:
            f.write("IPs NOT IN BOTH LISTS\n")
            f.write("=" * 60 + "\n\n")
            
            f.write("IPs ONLY in list1.txt (not in list2.txt):\n")
            f.write("-" * 40 + "\n")
            if entries_only_in_list1:
                for desc, ip in sorted(entries_only_in_list1, key=lambda x: x[1]):
                    f.write(f"{desc} {ip}\n")
            else:
                f.write("None\n")
            f.write(f"\nTotal: {total_unique_list1}\n\n")
            
            f.write("IPs ONLY in list2.txt (not in list1.txt):\n")
            f.write("-" * 40 + "\n")
            if entries_only_in_list2:
                for desc, ip in sorted(entries_only_in_list2, key=lambda x: x[1]):
                    f.write(f"{desc} {ip}\n")
            else:
                f.write("None\n")
            f.write(f"\nTotal: {total_unique_list2}\n\n")
            
            f.write("SUMMARY:\n")
            f.write("-" * 40 + "\n")
            f.write(f"Total IPs only in list1.txt: {total_unique_list1}\n")
            f.write(f"Total IPs only in list2.txt: {total_unique_list2}\n")
            f.write(f"Total IPs not in both lists: {total_unique_list1 + total_unique_list2}\n")
        
        print("Results saved to 'unique_ips_results.txt'")

if __name__ == "__main__":
    main()