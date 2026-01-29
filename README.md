# Open A2 ROM Specification

This project provides a comprehensive, open-source technical reference for 8-bit Apple II series firmware, created to support clean-room ROM implementations.

## Overview

The goal of this project is to produce a comprehensive technical reference manual (TRM) for compatible ROM implementations targeting 8-bit systems in the Apple II family. This specification details firmware entry points, register states (on entry and exit), memory effects, and overall functionality.

**View the latest specification:**

- [OpenA2FirmwareSpecification.md](https://tmcintos.github.io/OpenA2FirmwareSpecification/OpenA2FirmwareSpecification.md) - Read online (Markdown, rendered by GitHub)
- [OpenA2FirmwareSpecification.pdf](https://tmcintos.github.io/OpenA2FirmwareSpecification/OpenA2FirmwareSpecification.pdf) - Download PDF

Both files are generated from the various Markdown files in the `src` directory.

## Building the Specification

To build the specification documents, you will need to have `pandoc` and `lualatex` installed. Once installed, you can generate both Markdown and PDF outputs by running:

```bash
make
```

This will create:

- `OpenA2FirmwareSpecification.md` - Complete specification in Markdown format
- `OpenA2FirmwareSpecification.pdf` - Formatted PDF with proper typography

To build only the Markdown version:

```bash
make markdown
```

To build only the PDF version:

```bash
make pdf
```

## Legal Notice

This project is a clean-room technical specification documenting the public firmware API contract necessary for software compatibility with 8-bit Apple II systems.

**Trademark Acknowledgment:** References to "Apple II," "Apple IIe," "Apple IIc," and related product names are used descriptively to identify the systems and products for which the original firmware was designed. These are trademarks of Apple Inc.

**License:** MIT License. See `LICENSE.md` for details.

This work is intended for compatibility and educational purposes, supporting legitimate interoperability goals.

## Repository Structure

The repository is structured as follows:

*   `Makefile`: The makefile used to build the final specification documents (Markdown and PDF).
*   `src/`: This directory contains all the individual Markdown files that are combined to create the final specification, organized into logical sections:
    *   `src/introduction.md`: Introduction and document purpose
    *   `src/summary_of_firmware_entry_points.md`: Summary table of all 110 firmware entry points
    *   `src/symbol_definitions_intro.md`: Introduction to symbol definitions
    *   `src/zero_page_definitions.md`: Zero-page memory location definitions
    *   `src/non_zero_page_definitions.md`: Other memory locations and constants
    *   `src/system_architecture_overview.md`: Overview of system architecture (with subsections for hardware identification, memory system, display system, I/O soft switches, and ROM organization)
    *   `src/boot_and_initialization.md`: Boot sequence and initialization
    *   `src/interrupt_handling.md`: Interrupt handling specification
    *   `src/monitor_user_interface.md`: Monitor commands and escape sequences
    *   `src/*.md`: Individual files for each of the 110+ firmware routines
    *   `src/peripheral_controller_roms_heading.md`: Peripheral controller ROM overview
    *   `src/boot_rom_identification.md`: Boot ROM identification protocols
    *   `src/diskrom_section.md`: Disk II controller ROM specification
    *   `src/DiskROM.md`: Detailed Disk II ROM documentation
*   `pandoc-raw-html.lua`: Lua filter for pandoc to handle raw HTML anchors
*   `clean-headings-for-toc.lua`: Lua filter to clean headings for table of contents
*   `shift-headings-pdf.lua`: Lua filter to adjust heading levels for PDF output
*   `esc-symbol.lua`: Lua filter to handle escape character symbols
*   `lualatex-custom.tex`: LaTeX template for PDF generation
