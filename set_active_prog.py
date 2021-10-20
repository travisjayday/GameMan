import os
from pathlib import Path
from shutil import copyfile

root = str(Path(__file__).parent.absolute())
prog_path = root + '{0}software{0}progs'.format(os.sep)
sim_mem_path = root + '{0}gb80.srcs{0}sim_1{0}new{0}p1.mem'.format(os.sep)

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

prog_data = open(prog_file, 'rb')
prog_hex = ''
byte = prog_data.read(1)
i = 0
chars_per_line = 20
br = 0
while byte:
    prog_hex += byte.hex() + ' ' 
    i += 1
    if i == chars_per_line: 
        prog_hex += '\n'
        i = 0
        br += chars_per_line
    byte = prog_data.read(1)

print('converted ', prog_file, ' to loadable hex')
try: 
    mem_data = open(sim_mem_path, 'w')
    mem_data.write(prog_hex)
    mem_data.close()
    #copyfile(prog_file, sim_mem_path)
    print('Succesfully copied program to sim')
except:
    print('Failed to copy file!')
input('...')