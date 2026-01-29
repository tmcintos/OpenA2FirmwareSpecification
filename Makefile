# Makefile for OpenA2 ROM Specification
#
# Builds the complete Apple II ROM specification from modular source files.
# Produces both Markdown (for GitHub) and PDF (for printing/distribution).

OUTPUT_FILE = OpenA2FirmwareSpecification.md
PDF_OUTPUT = OpenA2FirmwareSpecification.pdf
TEMP_DIR = tmp
SRC_DIR = src

# Front matter
TITLE_PAGE = $(SRC_DIR)/title_page.md
INTRODUCTION = $(SRC_DIR)/introduction.md

# Architecture and system sections
SYSTEM_ARCHITECTURE = $(SRC_DIR)/system_architecture_overview.md
SYSTEM_ARCH_HARDWARE_ID = $(SRC_DIR)/hardware_identification.md
SYSTEM_ARCH_MEMORY = $(SRC_DIR)/memory_system.md
SYSTEM_ARCH_DISPLAY = $(SRC_DIR)/display_system.md
SYSTEM_ARCH_IO = $(SRC_DIR)/io_soft_switches.md
SYSTEM_ARCH_ROM_ORG = $(SRC_DIR)/rom_organization.md
BOOT_AND_INIT = $(SRC_DIR)/boot_and_initialization.md
INTERRUPT_HANDLING = $(SRC_DIR)/interrupt_handling.md
MONITOR_UI = $(SRC_DIR)/monitor_user_interface.md

# Symbol definitions and reference tables
SYMBOL_DEFINITIONS_INTRO = $(SRC_DIR)/symbol_definitions_intro.md
ZERO_PAGE_DEFS = $(SRC_DIR)/zero_page_definitions.md
NON_ZERO_PAGE_DEFS = $(SRC_DIR)/non_zero_page_definitions.md
SUMMARY = $(SRC_DIR)/summary_of_firmware_entry_points.md

# Peripheral ROM documentation
PERIPHERAL_ROM_HEADING = $(SRC_DIR)/peripheral_controller_roms_heading.md
BOOT_ROM_IDENTIFICATION = $(SRC_DIR)/boot_rom_identification.md
PERIPHERAL_ROM_SECTION = $(SRC_DIR)/diskrom_section.md
DISK_ROM_DETAILED = $(SRC_DIR)/DiskROM.md

# Generated temporary files
DETAILED_ENTRY_POINTS_HEADER = $(TEMP_DIR)/detailed_entry_points_header.md
DETAILED_ENTRY_POINTS_TMP = $(TEMP_DIR)/detailed_firmware_entry_points_combined.md

# Individual firmware entry point files (auto-discovered)
ROUTINE_FILES = $(sort $(filter-out $(TITLE_PAGE) $(INTRODUCTION) $(SUMMARY) $(SYSTEM_ARCHITECTURE) $(SYSTEM_ARCH_HARDWARE_ID) $(SYSTEM_ARCH_MEMORY) $(SYSTEM_ARCH_DISPLAY) $(SYSTEM_ARCH_IO) $(SYSTEM_ARCH_ROM_ORG) $(BOOT_AND_INIT) $(INTERRUPT_HANDLING) $(MONITOR_UI) $(SYMBOL_DEFINITIONS_INTRO) $(ZERO_PAGE_DEFS) $(NON_ZERO_PAGE_DEFS) $(PERIPHERAL_ROM_HEADING) $(BOOT_ROM_IDENTIFICATION) $(PERIPHERAL_ROM_SECTION) $(DISK_ROM_DETAILED), $(wildcard $(SRC_DIR)/*.md)))


.PHONY: all clean pdf markdown

all: markdown pdf

markdown: $(OUTPUT_FILE)

pdf: $(PDF_OUTPUT)

# Assemble complete Markdown document from source files
$(OUTPUT_FILE): $(TITLE_PAGE) $(INTRODUCTION) $(SYSTEM_ARCHITECTURE) $(SYSTEM_ARCH_HARDWARE_ID) $(SYSTEM_ARCH_MEMORY) $(SYSTEM_ARCH_DISPLAY) $(SYSTEM_ARCH_IO) $(SYSTEM_ARCH_ROM_ORG) $(BOOT_AND_INIT) $(INTERRUPT_HANDLING) $(MONITOR_UI) $(SUMMARY) $(DETAILED_ENTRY_POINTS_HEADER) $(DETAILED_ENTRY_POINTS_TMP) $(SYMBOL_DEFINITIONS_INTRO) $(ZERO_PAGE_DEFS) $(NON_ZERO_PAGE_DEFS) $(PERIPHERAL_ROM_HEADING) $(PERIPHERAL_ROM_SECTION) $(BOOT_ROM_IDENTIFICATION) $(DISK_ROM_DETAILED)
	pandoc --standalone \
		--number-sections \
		--from=markdown-tex_math_dollars \
		--to=gfm \
		--lua-filter=clean-headings-for-toc.lua \
		--lua-filter=pandoc-raw-html.lua \
		$(TITLE_PAGE) \
		$(INTRODUCTION) \
		$(SYSTEM_ARCHITECTURE) \
		$(SYSTEM_ARCH_HARDWARE_ID) \
		$(SYSTEM_ARCH_MEMORY) \
		$(SYSTEM_ARCH_DISPLAY) \
		$(SYSTEM_ARCH_IO) \
		$(SYSTEM_ARCH_ROM_ORG) \
		$(BOOT_AND_INIT) \
		$(INTERRUPT_HANDLING) \
		$(MONITOR_UI) \
		$(SUMMARY) \
		$(DETAILED_ENTRY_POINTS_HEADER) \
		$(DETAILED_ENTRY_POINTS_TMP) \
		$(SYMBOL_DEFINITIONS_INTRO) \
		$(ZERO_PAGE_DEFS) \
		$(NON_ZERO_PAGE_DEFS) \
		$(PERIPHERAL_ROM_HEADING) \
		$(PERIPHERAL_ROM_SECTION) \
		$(BOOT_ROM_IDENTIFICATION) \
		$(DISK_ROM_DETAILED) \
		-o $(OUTPUT_FILE)

# Generate PDF from assembled Markdown
$(PDF_OUTPUT): $(OUTPUT_FILE)
	pandoc $(OUTPUT_FILE) \
		--toc \
		--toc-depth=5 \
		--lua-filter=shift-headings-pdf.lua \
		--lua-filter=esc-symbol.lua \
		--pdf-engine=/usr/local/texlive/2025/bin/universal-darwin/xelatex \
		--template=lualatex-custom.tex \
		-o $(PDF_OUTPUT)

# Generate section header for detailed entry points
$(DETAILED_ENTRY_POINTS_HEADER):
	mkdir -p $(TEMP_DIR)
	echo "## Detailed Firmware Entry Points" > $(DETAILED_ENTRY_POINTS_HEADER)

# Combine all individual entry point files into single section
$(DETAILED_ENTRY_POINTS_TMP): $(ROUTINE_FILES)
	mkdir -p $(TEMP_DIR)
	touch $(DETAILED_ENTRY_POINTS_TMP)
	for f in $(ROUTINE_FILES); do \
		echo "\n\n" >> $(DETAILED_ENTRY_POINTS_TMP); \
		cat $$f >> $(DETAILED_ENTRY_POINTS_TMP); \
	done

clean:
	rm -f $(OUTPUT_FILE) $(PDF_OUTPUT) $(DETAILED_ENTRY_POINTS_TMP) $(DETAILED_ENTRY_POINTS_HEADER)
	rm -rf $(TEMP_DIR)
