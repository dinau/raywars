TARGET = raywars

STATIC_LINK_RAYLIB = true
ifeq ($(STATIC_LINK_RAYLIB),true)
	LIB_RAYLIB = -lraylib
else
	LIB_RAYLIB = -lraylibdll
endif

ifeq ($(OS),Windows_NT)
	EXE = .exe
	# Hide conlosle
	#NELUA_LDFLAGS += -mwindows
	NELUA_LDFLAGS += $(LIB_RAYLIB) -lopengl32 -lgdi32 -lwinmm -limm32
	PLATFORM = win
else
	PLATFORM = linux
	NELUA_LDFLAGS += $(LIB_RAYLIB)
endif

LIBS_DIR       = ../../../libs
RAYLIB_NELUA_DIR =   $(LIBS_DIR)/Raylib.nelua
NELUA_FLAGS     += -L$(LIBS_DIR)/Raylib.nelua --cache-dir .neluacache -o $(TARGET)$(EXE)
NELUA_CFLAGS    += -I$(LIBS_DIR)/$(PLATFORM)/raylib/include -O2 -Wl,-s
NELUA_LDFLAGS   += -lraylib -L$(LIBS_DIR)/$(PLATFORM)/raylib/lib


all: $(TARGET)$(EXE)

clean:
	@-rm -fr .neluacache
	@-rm -f $(TARGET)$(EXE)
	@-rm -f raylib.dll

$(TARGET)$(EXE): $(TARGET).nelua Makefile
	nelua -r $< $(NELUA_FLAGS) --cflags="$(NELUA_CFLAGS)" --ldflags="$(NELUA_LDFLAGS)"
ifeq ($(PLATFORM),win)
ifneq ($(STATIC_LINK_RAYLIB),true)
	cp -f $(LIBS_DIR)/$(PLATFORM)/raylib/lib/raylib.dll .
endif
endif

run: all
	LD_LIBRARY_PATH=$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)$(EXE)
