TARGET = raywars

CC = gcc
#CC = zig cc
#CC = clang

CFLAGS += -O0

LIBS_DIR = ../../../libs

HIDE_CONSOLE = true

ifeq ($(OS),Windows_NT)
	EXE = .exe
	PLATFORM = windows
	STATIC_LINK_RAYLIB = true
	ifeq ($(STATIC_LINK_RAYLIB),true)
		LIB_RAYLIB = -lraylib
		LDFLAGS += -static
		LDFLAGS += res/ray64.res
	else
		LIB_RAYLIB = -lraylibdll
	endif
	ifeq ($(HIDE_CONSOLE),true)
		LDFLAGS += -mwindows
	endif
else
	PLATFORM = linux
	LIB_RAYLIB = -lraylib
endif

LDFLAGS += -L$(LIBS_DIR)/$(PLATFORM)/raylib/lib

# Strip debug info
LDFLAGS += -Wl,-s

ifeq ($(OS),Windows_NT)
	LDFLAGS += $(LIB_RAYLIB) -lopengl32 -lgdi32 -lwinmm
else
	LDFLAGS += $(LIB_RAYLIB)
endif

CFLAGS  += -I$(LIBS_DIR)/$(PLATFORM)/raylib/include

all: $(TARGET)$(EXE)

$(TARGET)$(EXE): $(TARGET).c Makefile stb_ds.h
	$(CC) $(CFLAGS) $(TARGET).c -o $(TARGET)$(EXE) $(LDFLAGS)
ifneq ($(STATIC_LINK_RAYLIB),true)
ifeq ($(PLATFORM),windows)
	cp -f $(LIBS_DIR)/$(PLATFORM)/raylib/lib/raylib.dll .
endif
endif

run: all
	LD_LIBRARY_PATH=$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
ifeq ($(PLATFORM),windows)
	@-rm -f raylib.dll
endif

fmt:
	clang-format -i $(TARGET).c
