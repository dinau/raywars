TARGET = raywars

HIDE_CONSOLE = true

ifeq ($(OS),Windows_NT)
	EXE = .exe
  OPT_LIBS += --passL:"-static -lraylib -lopengl32 -lgdi32 -lwinmm"
	ifeq ($(HIDE_CONSOLE),true)
		OPT += --passL:"-mwindows"
	endif
	PLATFORM = windows
else
  OPT_LIBS += --passL:"-lraylib"
	PLATFORM = linux
endif

LIBS_DIR = ../../../libs

OPT += --passL:"-L $(LIBS_DIR)/$(PLATFORM)/raylib/lib" $(OPT_LIBS)
OPT += -d:strip
# Silent warning
OPT += --passC:"-Wno-attributes"

.PHONY: nimony nim run clean gen

all: nimony

nimony:
	$@ c $(OPT) $(TARGET).nim
	@-strip ./nimcache/$(TARGET)$(EXE)

nim: clean
	$@ c -d:nim_compiler --nimcache:.nimcache $(OPT) $(TARGET).nim

clean:
	@-rm -fr .nimcache nimcache .nimcache_gen
	@-rm -f $(TARGET)$(EXE)

run: all
	(cd nimcache; LD_LIBRARY_PATH=../$(LIBS_DIR)/$(PLATFORM)/raylib/lib ./$(TARGET)$(EXE) )

GEN_OPT += -d:useFuthark -d:futharkRebuild --maxLoopIterationsVM:50000000
GEN_OPT += --hint:"User:off"
GEN_OPT += -d:nodeclguards

gen:
	nim c -f -c  $(GEN_OPT) --nimcache:.nimcache_$(notdir $@) raylib.nim
