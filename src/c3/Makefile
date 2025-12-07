
all:
	c3c --version
ifeq ($(OS),Windows_NT)
	c3c build
else
	#c3c build -z -lraylib55 -z -lm
	c3c build -z -lraylib -z -lm
endif
	@-mkdir -p build/resources
	@cp -f resources/ray.png build/resources/

run: all
	(cd ./build; ./raywars)

clean:
	@-rm -fr build/*

update:
	c3c vendor-fetch raylib
	c3c vendor-fetch raygui
