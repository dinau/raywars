TARGET = raywars

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

OPT += -ldflags="-s -w"

all:
	go build -o $(TARGET)$(EXE) $(OPT) main.go

run: all
	./$(TARGET)$(EXE)

clean:
	@-rm -f $(TARGET)$(EXE)
