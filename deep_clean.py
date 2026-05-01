import os
import re

def fix_all_files():
    # Regex robusto para pegar withValues com qualquer espaçamento
    pattern = re.compile(r'withValues\s*\(\s*alpha\s*:\s*([0-9.]+)\s*\)')
    
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Substituição global e robusta
                new_content = pattern.sub(r'withOpacity(\1)', content)
                
                # Caso alguém tenha usado sem o nome do parâmetro 'alpha' (raro, mas possível)
                new_content = re.sub(r'withValues\s*\(\s*([0-9.]+)\s*\)', r'withOpacity(\1)', new_content)
                
                if content != new_content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Limpando: {path}")

if __name__ == "__main__":
    print("Iniciando limpeza profunda de incompatibilidades...")
    fix_all_files()
    print("Limpeza concluída com sucesso.")
