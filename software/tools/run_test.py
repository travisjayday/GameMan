from pathlib import Path
import os
import subprocess
import time
import pyautogui
import sim_prog_selector as sim_selector
from gb_state import GameBoyState

vivado_bin = 'F:\\tools\\WinXilinix\\Vivado\\2021.1\\bin\\'
xsim_exe = vivado_bin + 'xsim' 
root = str(Path(__file__).parent.parent.parent.absolute())
emu_dir = root + '{0}software{0}emu{0}'.format(os.sep)
prog_dir = root + '{0}software{0}progs{0}'.format(os.sep)
xsim_dir = root + '{0}gb80.sim{0}sim_1{0}behav{0}xsim{0}'.format(os.sep)
emu_exe = emu_dir + 'bgb64.exe'
emu_cfg = emu_dir + 'bgb.ini'

def set_bootrom_path(path):
    with open(emu_cfg, 'r') as f:
        content = f.read()
    new_content = []
    for line in content.split('\n'):
        if line.startswith('DmgBootRom'):
            new_content.append('DmgBootRom=' + path)
        else:
            new_content.append(line)
    with open(emu_cfg, 'w') as f:
        f.write('\n'.join(new_content))

def assemble_program(prog_file): 

    # Assemble current program
    prog_dir = os.sep.join(prog_file.split(os.sep)[0:-1])
    p = subprocess.run(['make', '-C', prog_dir], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    while True: 
        line = str(p.stdout, 'utf8') + str(p.stderr, 'utf8')
        print('LINE:', line)
        if 'error' in line.lower(): 
            print('FATAL ERROR. Aborting testing...')
            quit()
        elif 'leaving directory' in line.lower():
            break

def run_emu_as_bootrom(prog_file, debug=False):
    print('using', prog_file, ' as prog_file')
    b = None
    with open(prog_file, 'rb') as f:
        b = f.read()
        b = list(b[:256])
        b[-1] = 5 
        b = bytes(b)
    with open(prog_file, 'wb') as f:
        f.write(b)

    set_bootrom_path(prog_file)
    p = subprocess.Popen([emu_exe, emu_dir + 'empty.gb'], stdin=subprocess.PIPE)
    if debug: 
        input('Press enter to continue...')
        quit()

    # Wait for emu to start
    time.sleep(1)

    # Press enter on dialog that rom is broken
    pyautogui.press('enter')
    time.sleep(0.25)

    # Run emu code
    pyautogui.press('f9')
    time.sleep(1)

    # Save emu code as run.sna
    pyautogui.hotkey('ctrl', 'w')
    time.sleep(0.25)
    pyautogui.typewrite('run.sna\n')
    time.sleep(0.5)
    gb = GameBoyState()
    gb.load_from_sna(emu_dir + 'run.sna')
    p.terminate()
    return gb

def run_xsim_program(prog_file): 
    pwd = os.getcwd()

    # Select program for XSIM
    sim_selector.select_prog(prog_file)

    args = 'cpu_tb1_behav -key {Behavioral:sim_1:Functional:cpu_tb1} -tclbatch {cpu_tb1.tcl} -log run.log'
    cmd = [xsim_exe] + args.split()
    cmd = ' '.join(cmd)
    os.chdir(xsim_dir)

    print('Running xsim...')
    p = subprocess.Popen(cmd.split(), shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    output = []
    while True:
        line = str(p.stdout.readline(), 'utf8')
        print(line, end='')
        output.append(line)
        if 'xsim: Time' in line or "$finish called" in line: 
            break
    print('Stopping xsim...')
    p.stdin.write(bytes('exit\n', 'utf8'))

    print('RTL Simulation Done')

    os.chdir(pwd)

    gb = GameBoyState()
    gb.load_from_simdump(xsim_dir + 'simdump.hex')
    return gb

if __name__ == "__main__": 

    testall = False
    uts = []
    for prog in os.listdir(prog_dir):
        if not testall: 
            if prog.startswith('ut_interrupt'):
                uts.append(prog_dir + prog)
        else:
            if prog.startswith('ut_cpu_flow'):
                uts.append(prog_dir + prog)

    passed = []
    failed = []
    for test_dir in uts: 
        prog_file = test_dir + os.sep + 'out.gb' 
        assemble_program(prog_file)
        gb_emu = run_emu_as_bootrom(prog_file, debug=False)
        gb_uut = run_xsim_program(prog_file)

        if gb_uut.compare(gb_emu): 
            passed.append(test_dir)
        else:
            failed.append(test_dir)

    if testall:
        print('Passed:', passed)
        print('Failed:', failed)
        if len(failed) != 0:
            print("Sorry you fool")
        #print(gb_uut.stringify_mem("oam"))
