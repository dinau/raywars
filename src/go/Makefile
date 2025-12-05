TARGET = raywars

HIDE_CONSOLE = true

ifeq ($(OS),Windows_NT)
	EXE = .exe
	ifeq ($(HIDE_CONSOLE),true)
		GO_LD_FLAGS += -H=windowsgui
	endif
endif


GO_LD_FLAGS += -s -w
OPT += -ldflags="$(GO_LD_FLAGS)"

all: $(TARGET)$(EXE)

$(TARGET)$(EXE): main.go Makefile
	go build -o $(@) $(OPT) $<
	@-strip ./$(@)

run: all
	./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
