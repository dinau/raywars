# For Windows OS
# Add
# c:\your-Lazarus-installed-path
# c:\your-Lazarus-installed-path\fpc\3.2.2\bin\x86_64-win64
# to the PATH environment variable on Windows.

TARGET = raywars

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

.PHONY: run clean

all:
	lazbuild $(TARGET).lpr

run: all
	./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
	@-rm -fr lib
