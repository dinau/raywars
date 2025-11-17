all:
ifeq ($(OS),Windows_NT)
	c3c build
else
	c3c build -z -lraylib -z -lm
endif

run: all
	./build/raywars

clean:
	@-rm -fr build/
