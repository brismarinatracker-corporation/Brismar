import os
import re

def process_directory(directory, old_pkg, new_pkg):
    pattern = re.compile(f"package:{old_pkg}")
    replacement = f"package:{new_pkg}"
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = pattern.sub(replacement, content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated: {filepath}")

base_dir = "/home/jhonataningesis/Documentos/Brismar/BRISMAR_APP"

# Update bris_tracker imports using the actual old package name "brismar_mobile"
process_directory(os.path.join(base_dir, "bris_tracker", "lib"), "brismar_mobile", "bris_tracker")
process_directory(os.path.join(base_dir, "bris_tracker", "test"), "brismar_mobile", "bris_tracker")
