## <a id="introduction"></a>Introduction

### Purpose and Scope

This specification documents the application programming interface (API) contract for the unified ROM implementation of 8-bit Apple II family systems. It defines the behavior, entry points, memory locations, and operational characteristics that software written for any Apple II variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:
- Development of compatible ROMs in space-constrained configurations (4K minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to proprietary Apple source code
- Clean-room implementation of ROM components
- Software compatibility verification

### How to Use This Document

This technical reference is organized into major sections:

1. **Firmware Entry Points** - Complete documentation of all ROM routines, including input/output registers, memory effects, and calling conventions
2. **Memory Locations** - Definitions of zero-page and non-zero-page memory locations used by firmware
3. **Boot Sequence** - System initialization and boot ROM protocols
4. **System Architecture** - Hardware interfaces and address modes
5. **Disk II Controller** - Peripheral ROM specifications for the standard 5.25" floppy drive controller

Each routine entry includes:
- **Input Requirements** - Register and memory values expected on entry
- **Output Guarantees** - Register and memory values upon exit
- **Side Effects** - Other observable changes (calls to other routines, memory modifications)
- **Notes** - Implementation considerations and compatibility guidance

### Compatibility Philosophy

A correctly-implemented unified ROM following this specification should run software from any Apple II variant without variant detection. If variant-specific code paths are required, it indicates either:
1. The specification is incomplete, or
2. The implementation has diverged from the documented contract

This design principle enables clean, maintainable ROM implementations suitable for modern reproduction systems.