# windres.exe is included bintuils package
# pacman -S mingw-w64-ucrt-x86_64-binutils

all: res

TARGET = ray

res:
	@#-windres -O coff $(TARGET).rc -o $(TARGET)32.res
	@-windres -O coff $(TARGET).rc -o $(TARGET)64.res
