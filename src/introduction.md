## <a id="introduction"></a>Introduction

### Purpose and Scope

This specification documents the application programming interface (API) contract for the unified ROM implementation of 8-bit Apple II family systems. It defines the behavior, entry points, memory locations, and operational characteristics that software written for any Apple II variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:

- Development of compatible ROMs in space-constrained configurations (4K minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to proprietary Apple source code
- Clean-room implementation of ROM components
- Software compatibility verification

### How to Use This Document

This technical reference is organized into logical sections reflecting the structure of the Apple II firmware:

1. **Memory Locations** - Definitions of zero-page, RAM, and hardware register locations used by firmware
2. **Boot Sequence and Initialization** - System startup, reset handling, and boot protocols
3. **Monitor User Interface** - User-facing monitor commands and control character support
4. **Detailed Firmware Entry Points** - Complete documentation of all system ROM routines with input/output contracts, memory effects, and internal dependencies
5. **Peripheral Controller ROMs** - Boot ROM identification protocols and how peripheral devices extend system capabilities
6. **Disk II Controller ROM Specification** - Complete technical reference for the standard 5.25" disk controller ROM

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