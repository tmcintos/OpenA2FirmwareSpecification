## Peripheral Controller ROMs

### Disk II Controller ROM

In addition to the main system firmware documented in previous sections, Apple II computers often include expansion cards for disk drive control. The most common is the **Disk II Controller Card** (pronounced "Disk Two"), which includes a 256-byte boot loader ROM.

**Location:** Slot-relative address $Cn00 (where n is the slot number, typically $C600 for slot 6)

**Purpose:** Initializes the Disk II drive controller and loads the secondary boot loader (BOOT1) from disk into system memory at $0800.

**Key Functions:**
- Initialize disk controller (IWM - Integrated Woz Machine) hardware
- Generate 6+2 encoding decoder table for disk data
- Seek disk head to track 0
- Read track 0, sector 0 (boot sector) from disk
- Decode 6+2 encoded data and store in $0800-$0BFF
- Jump to BOOT1 code at $0801 for continued system initialization

**Entry Points:**
- **$Cn00 (typically $C600):** Main boot entry point - reads boot sector from disk and jumps to BOOT1
- **$Cn5C (typically $C65C):** ReadSector routine - reads a single disk sector (internal use)

**Hardware Accessed:**
- IWM Control Registers ($C080-$C08F range) - Stepper motor and drive control
- System RAM ($0300-$0BFF) - Decoder tables and data buffers

**Memory Usage:**
- $0300-$0355: 2-bit chunk buffer for 6+2 decoding
- $0356-$03D5: 6+2 decoder lookup table
- $0800-$0BFF: BOOT1 code loaded from disk
- Zero-page: $26-$27, $2B, $3C-$41

**Special Features:**
- Slot-independent design allows placement in any slot
- Blind seek algorithm doesn't require track detection
- 6+2 encoding provides error detection via specific bit patterns
- Auto-detects boot sector size from first byte of BOOT1

**Typical Boot Sequence:**
1. System reset vector jumps to firmware initialization
2. Slot detection determines which controller cards are installed
3. Disk II ROM entry ($C600) selected if drive controller present
4. Boot ROM reads track 0, sector 0 from disk
5. BOOT1 code loaded into memory at $0800
6. Control transfers to BOOT1 at $0801
7. BOOT1 continues initialization and loads main program/operating system

---

**For detailed technical specification of the Disk II ROM, see [Disk II Controller ROM Specification](#disk-ii-controller-rom-specification) below.**

