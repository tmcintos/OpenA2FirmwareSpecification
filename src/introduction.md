## <a id="introduction"></a>Introduction

### Purpose and Scope

This specification documents the application programming interface (API) contract for the unified ROM implementation of 8-bit Apple II family systems. It defines the behavior, entry points, memory locations, and operational characteristics that software written for any Apple II variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:

- Development of compatible ROMs in space-constrained configurations (4K minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to proprietary Apple source code
- Clean-room implementation of ROM components
- Software compatibility verification

### How to Use This Document

This technical reference is organized into eight main sections reflecting the structure of the Apple II firmware:

1. **Summary of Firmware Entry Points** - Quick reference table of all system ROM routines with addresses and function summaries
2. **Memory Locations** - Definitions of zero-page variables, RAM locations, and hardware register addresses used by firmware
3. **System Boot and Initialization Sequence** - System startup, reset handling, and peripheral boot protocols
4. **Monitor User Interface and Command Dispatcher** - User-facing monitor commands, escape sequences, and control character support
5. **Detailed Firmware Entry Points** - Complete documentation of all system ROM routines with input/output contracts, memory effects, and internal dependencies
6. **Peripheral Controller ROMs** - Overview of peripheral ROM structure, including:
   - Disk II Controller ROM overview and capabilities
   - Boot ROM identification protocols (DOS, Pascal 1.1, ProDOS)
7. **Disk II Controller ROM Specification** - Complete technical reference for the standard 5.25" disk controller ROM implementation

Within each routine entry, you will find:

- **Input Requirements** - Register and memory values expected on entry
- **Output Guarantees** - Register and memory values upon exit
- **Side Effects** - Other observable changes (calls to other routines, memory modifications)
- **Notes** - Implementation considerations and compatibility guidance

### Compatibility Philosophy

A correctly-implemented unified ROM following this specification should run software from any Apple II variant without variant detection. If variant-specific code paths are required, it indicates either:

1. The specification is incomplete, or
2. The implementation has diverged from the documented contract

This design principle enables clean, maintainable ROM implementations suitable for modern reproduction systems.