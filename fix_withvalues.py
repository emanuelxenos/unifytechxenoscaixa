import os
import re

def fix_files():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Substitui withValues(alpha: X) por withOpacity(X)
                new_content = re.sub(r'withValues\(alpha: ([0-9.]+)\)', r'withOpacity(\1)', content)
                
                if content != new_content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed: {path}")

if __name__ == "__main__":
    fix_files()
