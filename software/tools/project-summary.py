from pathlib import Path
import os

root = str(Path(__file__).parent.parent.parent.absolute()) + os.sep
srcs = root + 'srcs' + os.sep + 'hdl'

svl = 0
for f in os.listdir(srcs):
    f = open(srcs + os.sep + f, 'r')
    txt = f.read()
    f.close()
    lines = txt.split('\n')
    svl += len(lines)

srcs = root + 'software' + os.sep + 'progs'
asml = 0
for f in os.listdir(srcs):
    try: 
        fname = srcs + os.sep + f + os.sep + 'prog.gameboy.asm'
        f = open(fname, 'r')
        txt = f.read()
        f.close()
        lines = txt.split('\n')
        asml += len(lines)
    except: pass

print('SystemVerilog # lines:')
print(svl)
print('assemblyt # lines:')
print(asml)

    
