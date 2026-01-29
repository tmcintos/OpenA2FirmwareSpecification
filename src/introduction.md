## <a id="introduction"></a>Introduction

### Purpose and Scope

This specification documents the application programming interface (API) contract for the unified ROM implementation of 8-bit Apple II family systems. It defines the behavior, entry points, memory locations, and operational characteristics that software written for any Apple II variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:

- Development of compatible ROMs in space-constrained configurations (4K minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to proprietary Apple source code
- Clean-room implementation of ROM components
- Software compatibility verification

### How to Use This Document

This technical reference is organized to provide progressive understanding, from high-level architecture to detailed specifications:

1. **System Architecture Overview** - High-level introduction to Apple II hardware and firmware organization, including:
   - Hardware Variants and Identification
   - Memory System
   - Display System
   - I/O and Soft Switches
   - ROM Organization and Banking
2. **System Boot and Initialization** - Reset handling, memory detection, warm start, peripheral boot protocols
3. **Interrupt Handling** - BRK, IRQ, and NMI interrupts, memory state preservation, vector usage
4. **Monitor User Interface** - Monitor commands, escape sequences, control characters, command dispatcher
5. **Summary of Firmware Entry Points** - Quick reference table of all entry points with addresses
6. **Detailed Firmware Entry Points** - Complete documentation of all system ROM routines with:
    - Input/output register contracts
    - Memory effects and side effects
    - Internal dependencies and call chains
    - Implementation requirements
7. **Symbol Definitions** - Zero-page variables, system variables, hardware registers referenced throughout
8. **Peripheral Controller ROMs** - Overview of peripheral ROM protocols and boot ROM identification
9. **Disk II Controller ROM Specification** - Complete technical reference for the standard 5.25" disk controller

Within each routine entry, you will find:

- **Input Requirements** - Register and memory values expected on entry
- **Output Guarantees** - Register and memory values upon exit
- **Side Effects** - Other observable changes (calls to other routines, memory modifications)
- **Notes** - Implementation considerations and compatibility guidance

### Compatibility Philosophy

This specification documents the **firmware API contract** that provides software compatibility across 8-bit Apple II family systems. The goal is to enable ROM implementations that can run software written for any Apple II variant (II, II+, IIe, IIc) without requiring software to detect which model it's running on.

**Key Principles:**

1. **Consistent Entry Points** - Same firmware routine addresses provide compatible functionality across models
2. **Hardware-Adaptive Implementation** - ROMs detect their host hardware and implement variant-appropriate behavior internally
3. **Unified Programming Interface** - Software can depend on documented entry point behavior without variant-specific code paths

**Implementation Approach:**

A ROM following this specification:
- Detects host hardware capabilities using documented identification methods
- Implements the documented API contract appropriate for available hardware features  
- Provides consistent external behavior so application software remains portable
- Uses internal branching when hardware differences require different approaches

**Example:** The Home routine ($FC58) clears the screen on all variants with the same entry point and register contract, but internally:
- On IIe/IIc with 80-column support: clears both main and auxiliary display memory
- On II/II+: clears only main display memory

This design principle enables clean, maintainable ROM implementations suitable for reproduction systems while preserving software compatibility with the historical Apple II software library.