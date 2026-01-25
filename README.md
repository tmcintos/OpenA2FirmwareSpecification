# Open A2 ROM Specification

This project provides a comprehensive, open-source technical reference for 8-bit Apple II series firmware, created to support clean-room ROM implementations. The specification was developed by synthesizing documented behavior from published technical references and ROM disassemblies into a unified, implementable contract.

## Overview

The goal of this project is to produce a comprehensive technical reference manual (TRM) for compatible ROM implementations targeting 8-bit systems in the Apple II family. This specification details firmware entry points, register states (on entry and exit), memory effects, and overall functionality.

The final output is the `OpenA2_ROM_Specification.md` file, which is generated from the various Markdown files in the `src` directory.

## Building the Specification

To build the final `OpenA2_ROM_Specification.md` document, you will need to have `pandoc` installed. Once `pandoc` is installed, you can generate the document by running the following command:

```bash
make
```

This will create the `OpenA2_ROM_Specification.md` file in the root directory.

## Legal Notice

This project is a clean-room technical specification created through analysis and synthesis of publicly available documentation and ROM disassemblies. It documents the public firmware API contract necessary for software compatibility.

**Trademark Acknowledgment:** References to "Apple II," "Apple IIe," "Apple IIc," and related product names are used descriptively to identify the systems and products for which the original firmware was designed. These are trademarks of Apple Inc.

**License:** MIT License. See `LICENSE.md` for details.

**Derivation:** This specification is an original work synthesizing documented APIs from:
- Published technical reference manuals (Apple IIc Technical Reference, Apple IIgs Firmware Reference)
- Publicly available ROM disassemblies
- Clean-room analysis of firmware entry point contracts

This work is intended for compatibility and educational purposes, supporting legitimate interoperability goals.

## Repository Structure

The repository is structured as follows:

*   `Makefile`: The makefile used to build the final specification document.
*   `src/`: This directory contains all the individual Markdown files that are combined to create the final specification.
    *   `src/introduction.md`: The introduction to the specification.
    *   `src/summary_of_firmware_entry_points.md`: A summary table of all firmware entry points.
    *   `src/zero_page_definitions.md`: Definitions for zero-page memory locations.
    *   `src/non_zero_page_definitions.md`: Definitions for non-zero-page memory locations.
    *   `src/*.md`: Individual files for each firmware routine.
*   `pandoc-raw-html.lua`: A Lua filter for pandoc to handle raw HTML.
