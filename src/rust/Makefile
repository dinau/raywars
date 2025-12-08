all:
	cargo build --release
	@-mkdir -p target/release/resources
	@cp -fr ../../resources/*  target/release/resources/

run: all
	(cd target/release; ./raywars)



clean:
	@-rm -fr target
