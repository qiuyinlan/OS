# Top-level Makefile for chapter_8
# This Makefile can build any subdirectory (a, b, c, d, e)

# Default subdirectory to build
SUBDIR ?= a

# All subdirectories
SUBDIRS = a b c d e

# Hard disk image path (in parent directory)
HD_IMG = ../hd60M.img

.PHONY: all clean install help $(SUBDIRS)

# Default target - build the specified subdirectory
all:
	@echo "Building chapter_8/$(SUBDIR)..."
	@cd $(SUBDIR) && $(MAKE) all

# Install target - build and install to disk
install:
	@echo "Building and installing chapter_8/$(SUBDIR)..."
	@cd $(SUBDIR) && $(MAKE) all && $(MAKE) hd

# Clean the specified subdirectory
clean:
	@echo "Cleaning chapter_8/$(SUBDIR)..."
	@cd $(SUBDIR) && $(MAKE) clean

# Clean all subdirectories
clean-all:
	@echo "Cleaning all subdirectories..."
	@for dir in $(SUBDIRS); do \
		echo "Cleaning $$dir..."; \
		cd $$dir && $(MAKE) clean && cd ..; \
	done

# Individual subdirectory targets
$(SUBDIRS):
	@echo "Building chapter_8/$@..."
	@cd $@ && $(MAKE) all

# Help message
help:
	@echo "Chapter 8 Makefile"
	@echo "=================="
	@echo "Usage:"
	@echo "  make [SUBDIR=<dir>] [target]"
	@echo ""
	@echo "Subdirectories: $(SUBDIRS)"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the specified subdirectory (default: $(SUBDIR))"
	@echo "  install   - Build and install to disk image"
	@echo "  clean     - Clean the specified subdirectory"
	@echo "  clean-all - Clean all subdirectories"
	@echo "  <subdir>  - Build a specific subdirectory"
	@echo ""
	@echo "Examples:"
	@echo "  make              # Build subdirectory 'a' (default)"
	@echo "  make SUBDIR=b     # Build subdirectory 'b'"
	@echo "  make install      # Build and install subdirectory 'a'"
	@echo "  make SUBDIR=c install  # Build and install subdirectory 'c'"
	@echo "  make b            # Build subdirectory 'b'"
	@echo "  make clean-all    # Clean all subdirectories"
