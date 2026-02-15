import os

# Remover arquivos de teste
if os.path.exists('student_gradebook.db'):
    os.remove('student_gradebook.db')
    print("✓ Banco de dados removido")

if os.path.exists('test_db.py'):
    os.remove('test_db.py')
    print("✓ Arquivo de teste removido")

print("\nAplicação pronta para uso!")
