f = open('tetris.sna', 'rb')
data = bytearray()
byte = None
while byte != b'':
    byte = f.read(1)
    data += byte

reg_search = {
    'AF': b'AF',
    'BC': b'BC',
    'DE': b'DE',
    'HL': b'HL',
    'SP': b'SP',
    'PC': b'PC'
}
regs = {
    'AF': None,
    'BC': None,
    'DE': None,
    'HL': None,
    'SP': None,
    'PC': None
}

# 8kB@ 0xC000-0xDFFF
wram = None

# 8kB@ 0x8000-0x9FFF
vram = None

# 127B@ 0xFF80 - 0xFFFE
hram = None

# 160B@ 0xFE00 - 0xFE9F
oam = None

c = 0
for i in range(len(data)):
    c += 1
    b = data[i]

    # Find Registers
    found = []
    for reg, search in reg_search.items():
        if data[i:i+2] == search:
            regs[reg] = int.from_bytes(data[i+7:i+9], byteorder='little')
            found.append(reg)
    for reg in found: del reg_search[reg]

    # Find WRAM 0 and 1 (8kB)
    if data[i:i+4] == b'WRAM':
        wram = data[i+9:i+9+4096*2]

    # Find VRAM (8kB)
    if data[i:i+4] == b'VRAM':
        vram = data[i+9:i+9+4096*2]

    # Find VRAM (8kB)
    if data[i:i+4] == b'HRAM':
        hram = data[i+9:i+9+227]

    # OAM (160B)
    if data[i:i+3] == b'OAM':
        oam = data[i+8:i+8+160]

    if data[i:i+4] == b'\xff\x55\xfe\xff':
        print("FOUDNDND", i)
        

    # Find VRAM

print(data[700:740])
print(regs)
#print(vram)
print(oam)

for reg, val in regs.items():
    print(reg, '{:04x}'.format(val))

hex_per_line = 40
def print_mem(mem):
    i = 1
    for b in mem:
        print('{:02x}'.format(b), end='\n' if i % hex_per_line == 0 else ' ')
        i += 1
print('OAM')
print_mem(oam)
print('VRAM')
print_mem(vram)
print('\nWRAM')
print_mem(wram)
