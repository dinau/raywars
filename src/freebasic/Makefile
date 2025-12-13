TARGET = raywars

LIBS_DIR = ../../../libs/raylib4fb
OPT  += -i $(LIBS_DIR)/include
OPT  += -p $(LIBS_DIR)/lib/win64

HIDE_CONSOLE = true

ifeq ($(OS),Windows_NT)
	EXE = .exe
	PLATFORM = windows
	#STATIC_LINK_RAYLIB = true
	ifeq ($(STATIC_LINK_RAYLIB),true)
		LIB_RAYLIB = -l raylib
	else
		LIB_RAYLIB = -l raylib
	endif
	ifeq ($(HIDE_CONSOLE),true)
		OPT += -s gui
	endif
	# Use 32bit resource file, see res/Makefile
	RES += res/ray32.res
else
	PLATFORM = linux
	LIB_RAYLIB = -l raylib
endif

OPT += $(LIB_RAYLIB)

all: $(TARGET)$(EXE)
ifeq ($(OS),Windows_NT)
ifneq ($(STATIC_LINK_RAYLIB),true)
	@cp -f $(LIBS_DIR)/bin/win64/raylib.dll .
endif
endif

%$(EXE): %.bas Makefile
	@fbc --version
	fbc  $(OPT) $< $(RES)

run: all
	LD_LIBRARY_PATH=$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)

clean:
	@-rm -f $(TARGET)$(EXE)
ifeq ($(PLATFORM),windows)
	@-rm -f raylib.dll
endif
