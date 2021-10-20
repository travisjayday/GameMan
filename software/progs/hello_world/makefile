cc="../toolchain/rgbasm.exe"
ll="../toolchain/rgblink.exe"
fix="../toolchain/rgbfix.exe"
emu="../emu/bgb64.exe"

main:
	$(cc) -L -o out.o hello_world.gameboy.asm
	$(ll) -o out.gb out.o
	$(fix) -v -p 0xFF out.gb

emu: main
	$(emu) out.gb
	

