import sna_tools
import sim_tools
import io

class GameBoyState():
    def __init__(self):
        self.regnames = ['AF', 'BC', 'DE', 'HL', 'SP', 'PC']
        self.regs = {'AF': None, 'BC': None, 
                     'DE': None, 'HL': None, 
                     'SP': None, 'PC': None}

        # See https://gbdev.gg8.se/wiki/articles/Memory_Map
        self.rom0 = bytearray()
        self.romn = bytearray()
        self.vram = bytearray()
        self.eram = bytearray()
        self.wram = bytearray()
        self.oam = bytearray()
        self.ioreg = bytearray()
        self.hram = bytearray()
        self.ie = bytearray()
        self.mmio = {}
        self.origin = None
        self.printbuf = ''
        self.divider  = 0
        self.totalclks = 0

        self.section_offsets = {
            'vram' : 0x8000,
            'eram' : 0xa000,
            'wram' : 0xc000,
            'oam'  : 0xfe00,
            'hram' : 0xff80
        }
    
    def load_from_sna(self, path): 
        self.populate_self(sna_tools.parse_sna(path))
        self.origin = "Emulator SNA"

    def load_from_simdump(self, path): 
        self.populate_self(sim_tools.parse_simdump(path))
        self.origin = "XSIM Simdump"

    def populate_self(self, state_dic): 
        for reg, regval in state_dic['regs'].items():
            self.regs[reg] = regval

        def load_section(name): 
            if name in state_dic.keys(): 
                setattr(self, name, state_dic[name])
            else: 
                print("Warning: section `{}' missing...".format(name))
        
        load_section('wram')
        load_section('vram')
        load_section('oam')
        load_section('hram')
        load_section('ioreg')
        load_section('eram')

        if 'mmio' in state_dic.keys():
            for reg, val in state_dic['mmio'].items():
                if reg == 'div': self.mmio['div'] = val
                if reg == 'tac': self.mmio['tac'] = val
                if reg == 'tma': self.mmio['tma'] = val
                if reg == 'tima': self.mmio['tima'] = val

        if 'sys' in state_dic.keys():
            for reg, val in state_dic['sys'].items():
                if reg == 'divider': self.divider = val
                if reg == 'totalclks': self.totalclks = val


    def sprint(self, *args, **kwargs):
        sio = io.StringIO()
        print(*args, **kwargs, file=sio)
        self.printbuf += sio.getvalue()

    def stringify_regs(self): 
        sio = io.StringIO()
        for reg in self.regnames:
            print(reg + '\t', end='', file=sio)
        print('', file=sio)
        for reg in self.regnames:
            print('0x{:04x}\t'.format(self.regs[reg]), end='', file=sio)
        return sio.getvalue()

    def stringify_mem(self, section, colw=16):
        sio = io.StringIO()
        mem = getattr(self, section)
        offset = self.section_offsets[section]
        for row in range(len(mem) // colw):
            row_addr = offset + int(row * colw)
            print('{:_>4}:{:04x}  '.format(section, row_addr), end='', file=sio)
            for col in range(colw):
                print('{:02x} '.format(mem[int(row * colw) + col]), end='', file=sio)
        return sio.getvalue()
    
    def stringify_mmio(self):
        sio = io.StringIO()
        for reg, val in sorted(self.mmio.items()):
            print(reg.ljust(6), end='', file=sio)
        print('', file=sio)
        for reg, val in sorted(self.mmio.items()):
            s = ('0x{:02x}'.format(val)).ljust(6)
            print(s, end='', file=sio)
        return sio.getvalue()
    
    def compare(self, other):

        ###################

        reg_mismatch = False
        for reg in self.regnames:
            if self.regs[reg] != other.regs[reg]:
                reg_mismatch = True

        if reg_mismatch: 
            self.sprint('[XX] Register mismatch...')
            self.sprint('\n\t\t' + self.origin)
            self.sprint(self.stringify_regs())
            self.sprint('\n\t\t' + other.origin)
            self.sprint(other.stringify_regs())
            self.sprint('')
        else:
            print('[OK] Register are matching...')
            print(self.stringify_regs())
        
        ###################

        def compare_mem(section, colw=32):
            self_mem = getattr(self, section)
            other_mem = getattr(other, section)

            if self_mem == other_mem: 
                return False

            self.sprint(' ' * (18 + colw) + self.origin + ' ' * int(colw * 2.75) + other.origin)
            offset = self.section_offsets[section]

            for row in range(len(self_mem) // colw):
                row_addr = offset + int(row * colw)
                self.sprint('{:_>4}:{:04x}'.format(section, row_addr), end='')
                self.sprint('|', end='')
                for col in range(colw):
                    self.sprint('{:02x}'.format(self_mem[int(row * colw) + col]), end='')
                    if col != colw - 1: self.sprint(' ', end='')
                self.sprint('|', end='')
                for col in range(colw):
                    self.sprint('{:02x}'.format(other_mem[int(row * colw) + col]), end='')
                    if col != colw - 1: self.sprint(' ', end='')
                self.sprint('')

            return True
                    
        colw=32
        mem_mismatch = False
        mem_mismatch |= compare_mem('vram', colw)
        mem_mismatch |= compare_mem('wram', colw)
        mem_mismatch |= compare_mem('oam', colw)
        mem_mismatch |= compare_mem('hram', colw)

        if mem_mismatch:
            print('[XX] Memory mistmatches...')
        else:
            print('[OK] No Memory mismatch...')

        ###################

        mmio_mismatch = []
        def check_mmio(reg): 
            if self.mmio[reg] != other.mmio[reg]: 
                mmio_mismatch.append(reg)
        check_mmio('div')
        check_mmio('tac')
        check_mmio('tma')
        check_mmio('tima')
        
        if len(mmio_mismatch) != 0: 
            self.sprint('MMIO Mismatch')
            self.sprint('\n' + self.origin)
            self.sprint(self.stringify_mmio())
            self.sprint('\n' + other.origin)
            self.sprint(other.stringify_mmio())
        
        if len(mmio_mismatch) != 0: 
            print('[X] MMIO Mismatching: ' + ' '.join(mmio_mismatch))
        else:
            print('[OK] MMIO regs are matching')
            print(self.stringify_mmio())

        ###################

        print(self.printbuf, end='')

        #################

        sysmismatch = False
        if self.divider != other.divider: 
            print('[X] Dividers are not equal')
            print(self.origin + ' - Divider: 0x{:08x}'.format(self.divider ))
            print(other.origin + ' - Divider: 0x{:08x}'.format(other.divider ))
            sysmismatch = True
        else:
            print('[OK] Sys dividers equal: 0x{:08x}'.format(self.divider))

        if self.totalclks != other.totalclks: 
            print('[X] Totalclks are not equal')
            print(self.origin + ' - Totalclks: 0x{:08x}'.format(self.totalclks))
            print(other.origin + ' - Totalclks: 0x{:08x}'.format(other.totalclks))
            sysmismatch = True
        else:
            print('[OK] Sys Totalclks are equal: 0x{:08x}'.format(self.totalclks))

        ###################


        if (not mem_mismatch) and (not reg_mismatch) and (len(mmio_mismatch) == 0) and (not sysmismatch):
            print('[GOOD] ***States are equal!***')
            return True
        else:
            print('[BAD] ;-(')
            return False







if __name__ == "__main__": 
    gb1 = GameBoyState()
    gb1.load_from_sna('C:\\Users\\Ahmad\\Desktop\\Ape_Gang_FPGA_Project\\software\\tools\\tetris.sna')
    print(gb1.stringify_mem('oam'))
    #gb2 = GameBoyState()
    #gb2.load_from_simdump('F:\\Projects\\gb80\\gb80.sim\\sim_1\\behav\\xsim\\simdump.hex')

    #gb2.compare(gb1)