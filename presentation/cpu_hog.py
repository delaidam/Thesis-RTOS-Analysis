# io_hog.py
import time
import os
import sys

if sys.stdout.encoding != 'UTF-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except AttributeError:
        pass

print("Pokrenut I/O opterecenje. Pritisnite Ctrl+C za zaustavljanje.")
start_time = time.time() # <-- OVDJE JE DODANA INICIJALIZACIJA start_time
file_name = "temp_io_hog_file.tmp"
block_size = 1024 * 1024 # 1 MB
num_blocks = 100 # Write 100 MB repeatedly

try:
    while True:
        with open(file_name, "wb") as f:
            for _ in range(num_blocks):
                f.write(os.urandom(block_size)) # Pise random bajtove
        # Citanje fajla
        with open(file_name, "rb") as f:
            f.read()
        print(f"I/O ciklus zavrsen. Vrijeme: {time.time() - start_time:.2f}s")
        time.sleep(0.1) # Mala pauza da ne preoptereti disk totalno
except KeyboardInterrupt:
    print("\nI/O opterecenje zaustavljeno.")
finally:
    if os.path.exists(file_name):
        os.remove(file_name)