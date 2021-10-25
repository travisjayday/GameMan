from pathlib import Path
import os
import subprocess
import time
import pyautogui

root = str(Path(__file__).parent.parent.absolute())
emu_dir = root + '{0}emu{0}'.format(os.sep)
emu_exe = emu_dir + 'bgb64.exe'
p = subprocess.Popen([emu_exe, 'empty.gb'], stdin=subprocess.PIPE)
#time.sleep(1)
#p.stdin.write(bytes('echo "Hello\t\t\tWorld"\n', 'utf8'))
time.sleep(2)
print('pressing f12')
pyautogui.press('f12')
