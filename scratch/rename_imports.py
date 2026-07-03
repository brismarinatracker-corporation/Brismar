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

# Update bris_web imports
process_directory(os.path.join(base_dir, "bris_web", "lib"), "brismar_web_admin", "bris_web")
process_directory(os.path.join(base_dir, "bris_web", "test"), "brismar_web_admin", "bris_web")
# Update bris_tracker imports
process_directory(os.path.join(base_dir, "bris_tracker", "lib"), "brismar_app", "bris_tracker")
process_directory(os.path.join(base_dir, "bris_tracker", "test"), "brismar_app", "bris_tracker")
# Update bris_admin imports
process_directory(os.path.join(base_dir, "bris_admin", "lib"), "brismar_executive_app", "bris_admin")
process_directory(os.path.join(base_dir, "bris_admin", "test"), "brismar_executive_app", "bris_admin")
