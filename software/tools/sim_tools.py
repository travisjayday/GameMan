def parse_simdump(path): 
    data = None
    with open(path, 'r') as f: 
        data = f.read()

    regs = {}
    vram = None
    eram = None
    wram = None
    oam = None
    hram = None

    sections = data.split('SECTION ')
    for section in sections:
        if len(section) == 0: continue
        lines = section.split('\n')
        header = lines[0]
        print(header)
        if header == 'REGS': 
            regdata = lines[2].split()
            regnames = ['AF', 'BC', 'DE', 'HL', 'SP', 'PC']
            for i in range(len(regnames)):
                regs[regnames[i]] = int(regdata[i], 16)
        if header == 'MEM': 
            hexdata = lines[1:]
            intbuffer = []
            buf_vram = []
            buf_wram = []
            buf_eram = []
            buf_oam = []
            buf_hram = []
            for hexline in hexdata: 
                if len(hexline) == 0: continue
                namespace, data = hexline.split('  ')
                data = data.split()
                if   namespace.startswith('VRAM'): buf = buf_vram
                elif namespace.startswith('ERAM'): buf = buf_eram
                elif namespace.startswith('WRAM'): buf = buf_wram
                elif namespace.startswith('_OAM'): buf = buf_oam
                elif namespace.startswith('HRAM'): buf = buf_hram
                elif namespace.startswith('ROM'):  continue 
                else: 
                    print('Unkown address space encountered: ', namespace)
                    quit()
                buf += [int(x, 16) for x in data]
            vram = bytearray(buf_vram)
            eram = bytearray(buf_eram)
            wram = bytearray(buf_wram)
            oam  = bytearray(buf_oam)
            hram = bytearray(buf_hram)


    state = {
        'regs': regs,
        'vram': vram,
        'eram': eram,
        'wram': wram,
        'oam': oam,
        'hram': hram
    }

    return state


if __name__ == "__main__":
    parse_simdump('F:\\Projects\\gb80\\gb80.sim\\sim_1\\behav\\xsim\\simdump.hex')
