## <a id="introduction"></a>Introduction

### Purpose and Scope

This specification documents the application programming interface (API) contract for the unified ROM implementation of 8-bit Apple II family systems. It defines the behavior, entry points, memory locations, and operational characteristics that software written for any Apple II variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:

- Development of compatible firmware images in space-constrained configurations (4K minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to proprietary source code
- Clean-room implementation of firmware components
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
6. **Detailed Firmware Entry Points** - Complete documentation of all system firmware routines with:
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

This specification defines a **capability‑based firmware API contract** for the 8‑bit Apple II family. Its purpose is to ensure that software can rely on a stable set of behaviors, regardless of whether the firmware is a historical ROM, a modern re‑implementation, a subset ROM, or a superset ROM. Implementations may target any hardware model or emulator, provided they truthfully advertise the capabilities they fully support.

#### Key Principles

- **Stable Firmware Contract**  
  Standard entry points, calling conventions, and behavioral guarantees form the core compatibility layer shared across all implementations.

- **Hardware‑First Feature Detection**  
  When hardware provides reliable, backward‑compatible feature detection (e.g., IIe soft switches, auxiliary memory behavior), software should use those mechanisms rather than relying solely on ROM identification bytes.

- **Truthful Capability Advertisement**  
  ROM ID bytes must represent the **lowest historical capability tier** for which the firmware implements the complete and correct behavior defined by this specification. Implementations may provide additional features beyond that tier, but must not claim a tier whose full behavior they do not implement.

- **Support for Subset and Superset Firmware Images**  
  Implementations are not required to match any historical Apple II ROM. A firmware image may omit rarely used features, add new ones, or combine capabilities in non‑historical ways, as long as it fully implements the tier it advertises and accurately reports any additional capabilities.

- **Contract Fidelity**  
  All implemented routines must honor the documented register usage, memory effects, and observable behavior. Partial or inconsistent implementations of advertised features are not permitted.

#### Implementation Requirements

- **ID Bytes**  
  Must identify the lowest historical capability tier for which the firmware provides a complete implementation. For example, a ROM that omits IIe‑specific firmware features must advertise II or II+, even if running on IIe‑class hardware.

- **Capability APIs**  
  Implementations may expose additional capabilities beyond the advertised tier. These capabilities must be discoverable through hardware probing or through any firmware‑level APIs defined in this specification. Future revisions may introduce additional capability APIs for finer‑grained detection.

- **API Contract Compliance**  
  All implemented entry points must behave exactly as documented, including register conventions, side effects, and memory interactions.

#### Resulting Behavior

This philosophy ensures that software relying on proper feature detection — using hardware probes where available and ROM‑advertised capability tiers where necessary — will operate correctly on any compliant firmware implementation, whether historical, minimal, extended, or custom.
