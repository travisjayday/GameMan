import os
from pathlib import Path
from shutil import copyfile

root = str(Path(__file__).parent.absolute())
prog_path = root + '{0}software{0}progs'.format(os.sep)
#sim_mem_path = root + '{0}gb80.srcs{0}sim_1{0}new{0}p1.coe'.format(os.sep)
sim_mem_path = root + '{0}program.coe'.format(os.sep)
sim_32k_rom_path = root + '{0}gb80.gen{0}sources_1{0}ip{0}bram_32k_rom{0}bram_32k_rom.mif'.format(os.sep)

print('Programs found at', prog_path)

progs = os.listdir(prog_path)

i = 1
for prog in progs:
    print(str(i) + ' ' + prog.split(os.sep)[-1])
    i += 1

select = input('Select Program: ')

prog_file = prog_path + os.sep + progs[int(select)-1]

for file in os.listdir(prog_file):
    if file.endswith('gb'):
        prog_file += os.sep + file
        break

def make_coe(path): 
    prog_data = open(path, 'rb')
    prog_hex = '''memory_initialization_radix=16;
    memory_initialization_vector=
    '''
    byte = prog_data.read(1)
    i = 0
    chars_per_line = 20
    br = 0
    while byte:
        prog_hex += byte.hex() + ', ' 
        i += 1
        if i == chars_per_line: 
            prog_hex += '\n'
            i = 0
            br += chars_per_line
        byte = prog_data.read(1)
    prog_hex = prog_hex[:-2] + ';'
    return prog_hex

def make_mif(path): 
    prog_data = open(path, 'rb')
    prog_mif = ''
    byte = prog_data.read(1)
    br = 0
    while byte:
        prog_mif += bin(int(byte.hex(), 16))[2:].zfill(8) + '\n'
        byte = prog_data.read(1)
    return prog_mif 

prog_coe = make_coe(prog_file)
prog_mif = make_mif(prog_file)


def write_to_file(path, data): 
    print('writing to', path)
    try: 
        mem_data = open(path, 'w')
        mem_data.write(data)
        mem_data.close()
        print('Succesfully copied program to sim')
    except:
        print('Failed to copy file!')

write_to_file(sim_32k_rom_path, prog_mif)
write_to_file(sim_mem_path, prog_coe)
input('...')