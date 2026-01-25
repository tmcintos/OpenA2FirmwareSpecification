# Makefile for OpenA2 ROM Specification

OUTPUT_FILE = OpenA2FirmwareSpecification.md
PDF_OUTPUT = OpenA2FirmwareSpecification.pdf
TEMP_DIR = tmp
SRC_DIR = src
TITLE_PAGE = $(SRC_DIR)/title_page.md
INTRODUCTION = $(SRC_DIR)/introduction.md
SUMMARY = $(SRC_DIR)/summary_of_firmware_entry_points.md
ZERO_PAGE_DEFS = $(SRC_DIR)/zero_page_definitions.md
NON_ZERO_PAGE_DEFS = $(SRC_DIR)/non_zero_page_definitions.md
ESCAPE_SEQUENCES = $(SRC_DIR)/escape_sequences.md
BOOT_SEQUENCE_OVERVIEW = $(SRC_DIR)/boot_sequence_overview.md
BOOT_ROM_IDENTIFICATION = $(SRC_DIR)/boot_rom_identification.md
DETAILED_ENTRY_POINTS_HEADER = $(TEMP_DIR)/detailed_entry_points_header.md
DETAILED_ENTRY_POINTS_TMP = $(TEMP_DIR)/detailed_firmware_entry_points_combined.md
DISK_ROM_SECTION = $(SRC_DIR)/diskrom_section.md

MONITOR_USER_INTERFACE = $(SRC_DIR)/monitor_user_interface.md
DISK_ROM_DETAILED = $(SRC_DIR)/DiskROM.md
# List of all individual routine files in the src directory
ROUTINE_FILES = $(sort $(filter-out $(TITLE_PAGE) $(INTRODUCTION) $(SUMMARY) $(ZERO_PAGE_DEFS) $(NON_ZERO_PAGE_DEFS) $(ESCAPE_SEQUENCES) $(BOOT_SEQUENCE_OVERVIEW) $(BOOT_ROM_IDENTIFICATION) $(MONITOR_USER_INTERFACE) $(DISK_ROM_SECTION) $(DISK_ROM_DETAILED), $(wildcard $(SRC_DIR)/*.md)))

.PHONY: all clean pdf markdown

all: markdown pdf

markdown: $(OUTPUT_FILE)

pdf: $(PDF_OUTPUT)

$(OUTPUT_FILE): $(TITLE_PAGE) $(INTRODUCTION) $(SUMMARY) $(ZERO_PAGE_DEFS) $(NON_ZERO_PAGE_DEFS) $(ESCAPE_SEQUENCES) $(BOOT_SEQUENCE_OVERVIEW) $(BOOT_ROM_IDENTIFICATION) $(MONITOR_USER_INTERFACE) $(DETAILED_ENTRY_POINTS_HEADER) $(DETAILED_ENTRY_POINTS_TMP) $(DISK_ROM_SECTION) $(DISK_ROM_DETAILED)
	pandoc --standalone \
		--number-sections \
		--toc \
		--toc-depth=2 \
		--from=markdown-tex_math_dollars \
		--to=gfm \
		--lua-filter=clean-headings-for-toc.lua \
		--lua-filter=pandoc-raw-html.lua \
		$(TITLE_PAGE) \
		$(INTRODUCTION) \
		$(SUMMARY) \
		$(ZERO_PAGE_DEFS) \
		$(NON_ZERO_PAGE_DEFS) \
		$(ESCAPE_SEQUENCES) \
		$(BOOT_SEQUENCE_OVERVIEW) \
		$(BOOT_ROM_IDENTIFICATION) \
		$(MONITOR_USER_INTERFACE) \
		$(DETAILED_ENTRY_POINTS_HEADER) \
		$(DETAILED_ENTRY_POINTS_TMP) \
		$(DISK_ROM_SECTION) \
		$(DISK_ROM_DETAILED) \
		-o $(OUTPUT_FILE)

$(PDF_OUTPUT): $(OUTPUT_FILE)
	pandoc $(OUTPUT_FILE) \
		--lua-filter=esc-symbol.lua \
		--pdf-engine=/usr/local/texlive/2025/bin/universal-darwin/xelatex \
		--template=lualatex-custom.tex \
		-o $(PDF_OUTPUT)

$(DETAILED_ENTRY_POINTS_HEADER):
	mkdir -p $(TEMP_DIR)
	echo "## Detailed Firmware Entry Points" > $(DETAILED_ENTRY_POINTS_HEADER)

$(DETAILED_ENTRY_POINTS_TMP): $(ROUTINE_FILES)
	mkdir -p $(TEMP_DIR)
	# Start with an empty file, then append each routine file with blank lines in between
	touch $(DETAILED_ENTRY_POINTS_TMP)
	for f in $(ROUTINE_FILES); do \
		echo "\n\n" >> $(DETAILED_ENTRY_POINTS_TMP); \
		cat $$f >> $(DETAILED_ENTRY_POINTS_TMP); \
	done

clean:
	rm -f $(OUTPUT_FILE) $(PDF_OUTPUT) $(DETAILED_ENTRY_POINTS_TMP) $(DETAILED_ENTRY_POINTS_HEADER)
	rm -rf $(TEMP_DIR)
