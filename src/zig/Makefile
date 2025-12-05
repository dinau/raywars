TARGET = raywars

OPT += --release=fast

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:
	zig version
	zig build $(OPT)

run: all
	(cd zig-out/bin; ./$(TARGET)$(EXE))


clean:
	@-rm -fr .zig-cache zig-out
	@-rm -fr libzig/raylib/.zig-cache
	@-rm -fr libzig/raylib/zig-out
