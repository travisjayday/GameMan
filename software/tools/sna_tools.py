def parse_sna(path):
    f = open(path, 'rb')
    data = bytearray()
    byte = None
    while byte != b'':
        byte = f.read(1)
        data += byte

    reg_search = {
        'AF': b'AF\x00\x02',
        'BC': b'BC\x00\x02',
        'DE': b'DE\x00\x02',
        'HL': b'HL\x00\x02',
        'SP': b'SP\x00\x02',
        'PC': b'PC\x00\x02'
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

    # 128B@ 0xFF80 - 0xFFFE
    hram = None

    # 160B@ 0xFE00 - 0xFE9F
    oam = None

    mmio = {}

    sys = {}


    c = 0
    for i in range(len(data)):
        c += 1
        b = data[i]

        # Find Registers
        found = []
        for reg, search in reg_search.items():
            if data[i:i+4] == search:
                regs[reg] = int.from_bytes(data[i+7:i+9], byteorder='little')
                found.append(reg)
        for reg in found: del reg_search[reg]

        # Find WRAM 0 and 1 (8kB)
        if data[i:i+4] == b'WRAM':
            wram = data[i+9:i+9+4096*2]

        # Find VRAM (8kB)
        if data[i:i+4] == b'VRAM':
            vram = data[i+9:i+9+4096*2]

        # Find HRAM (8kB)
        if data[i:i+4] == b'HRAM':
            hram = data[i+9:i+9+128]
            hram[-1] = 0

        # OAM (160B)
        if data[i:i+3] == b'OAM':
            oam = data[i+8:i+8+160]

        # MMIO 
        if data[i:i+3] == b'DIV':
            mmio['div'] = int.from_bytes(data[i+8:i+8+1], byteorder='little')

        if data[i:i+3] == b'TAC':
            mmio['tac'] = int.from_bytes(data[i+8:i+8+1], byteorder='little')

        if data[i:i+3] == b'TMA':
            mmio['tma'] = int.from_bytes(data[i+8:i+8+1], byteorder='little')

        if data[i:i+4] == b'TIMA':
            mmio['tima'] = int.from_bytes(data[i+9:i+9+1], byteorder='little')

        if data[i:i+9] == b'totalclks':
            clks = int.from_bytes(data[i+14:i+14+4], byteorder='little')
            sys['totalclks'] = (clks // 2) * 4  # convert from 1 nop in doublespeed (4ds clks) to 1 clk in single speed

        if data[i:i+7] == b'divider':
            b = data[i+12:i+12+4]
            #print(b)
            if b[-1] == 0x80:
                b[-1] -= 0x80   # for some reason...
            clks = int.from_bytes(b, byteorder='little')
            sys['divider'] = (clks // 2) * 4  # convert from 1 nop in doublespeed (4ds clks) to 1 clk in single speed

    sna = {
        'regs': regs,
        'oam': oam,
        'vram': vram,
        'wram': wram,
        'hram': hram,
        'mmio': mmio,
        'sys': sys
    }

    return sna
            

def print_sna(sna):

    for reg, val in sna['regs'].items():
        print(reg, '{:04x}'.format(val))

    hex_per_line = 40
    def print_mem(mem):
        i = 1
        for b in mem:
            print('{:02x}'.format(b), end='\n' if i % hex_per_line == 0 else ' ')
            i += 1
    print('OAM')
    print_mem(sna['oam'])
    print('VRAM')
    print_mem(sna['vram'])
    print('\nWRAM')
    print_mem(sna['wram'])


if __name__ == "__main__": 
    res = parse_sna('F:\\Projects\\gb80\\software\\emu\\run.sna')
    print(hex(res['regs']['SP']))
    print('mmio')
    print(res['mmio'])