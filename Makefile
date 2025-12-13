EXAMPLE_DIRS := \
								src/c \
								src/c3 \
								src/freebasic
								src/go \
								src/nelua \
								src/nim \
								src/nimony \
								src/odin \
								src/pascal \
								src/rust \
								src/zig

define def_make
  @echo
	@echo ==== Enter: $(1) ====
	@-$(MAKE) -C  $(1) $(2)

endef

all:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))

clean:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))



MAKEFLAGS += --no-print-directory
