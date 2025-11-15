TARGET = raywars

LIBS_DIR = ../../../libs

ifeq ($(OS),Windows_NT)
	EXE = .exe
	PLATFORM = win
  OPT_LIBS += "/LIBPATH:$(LIBS_DIR)/$(PLATFORM)/raylib_msvc/lib raylib.lib"
else
	PLATFORM = linux
  OPT_LIBS += "-L$(LIBS_DIR)/$(PLATFORM)/raylib/lib -lraylib"
endif

OPT += $(OPT_LIBS)

all:
	odin build . -out:$(TARGET)$(EXE) -extra-linker-flags:$(OPT)


run: all
	LD_LIBRARY_PATH=$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
