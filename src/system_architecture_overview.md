## System Architecture Overview

The Apple II family represents a cohesive architecture that evolved over more than a decade while maintaining backward compatibility. This section provides a high-level overview of the system architecture common to all 8-bit Apple II computers, establishing the foundation for understanding the detailed specifications that follow.

### Design Philosophy

The Apple II architecture is characterized by:

- **Simplicity:** Minimal hardware complexity, maximum software flexibility
- **Expandability:** Slot-based peripheral architecture (except IIc)
- **Compatibility:** Each generation maintains compatibility with software from earlier models
- **Memory-Mapped I/O:** All hardware control through memory addresses, no special I/O instructions
- **Open Architecture:** Documented interfaces enable third-party hardware and software

### Core Components

**Processor:**

- 6502 microprocessor @ 1.023 MHz (original models)
- 65C02 @ 1.023 MHz (enhanced models) or @ 4 MHz (IIc Plus)
- 8-bit data bus, 16-bit address bus (64KB address space)

**Memory:**

- 48KB to 128KB RAM depending on model and configuration
- 8KB to 32KB ROM containing firmware and system software
- Bank-switched memory expansion (language card, auxiliary RAM)

**Display:**

- Text modes:
	- 40-column or
	- 80-column (IIe/IIc with appropriate hardware)
- Graphics modes:
	- Low-resolution (40×48),
	- High-resolution (280×192)
	- Double high-resolution (560×192) on IIe/IIc with 128K RAM
- Memory-mapped video with hardware support for page flipping

**I/O:**

- Memory-mapped soft switches ($C000-$C0FF)
- Slot-based peripheral cards (II/II+/IIe)
- Integrated peripherals (IIc)
- Standard keyboard and speaker

### Subsystem Overview

The following subsections detail major system components, providing the architectural foundation for understanding Apple II firmware implementation.
