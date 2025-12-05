TARGET = raywars

LIBS_DIR = ../../../libs

HIDE_CONSOLE = true

ifeq ($(OS),Windows_NT)
	EXE = .exe
	PLATFORM = windows
  OPT_LIBS += "/LIBPATH:$(LIBS_DIR)/$(PLATFORM)/raylib_msvc/lib raylib.lib"
	ifeq ($(HIDE_CONSOLE),true)
		OPT += -subsystem:windows
	endif
else
	PLATFORM = linux
  OPT_LIBS += "-L$(LIBS_DIR)/$(PLATFORM)/raylib/lib -lraylib"
endif

OPT += -extra-linker-flags:$(OPT_LIBS)

all:
	odin build . -out:$(TARGET)$(EXE) $(OPT)


run: all
	LD_LIBRARY_PATH=$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
