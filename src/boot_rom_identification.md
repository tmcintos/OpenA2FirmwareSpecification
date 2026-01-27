## Boot ROM Identification Protocols

Peripheral ROM devices must be properly identified by the system firmware and operating systems to be recognized as boot devices. This section documents the identification protocols used across different Apple II systems and operating environments.

### Overview

The Apple II family has used three primary boot ROM identification schemes:

1. **Original Apple II DOS** (minimal/none) - Simple presence detection at $Cn00
2. **Pascal 1.1 Firmware Protocol** - ID bytes at specific addresses for device classification
3. **ProDOS Block Device Protocol** - Extended ID byte structure for block devices and SmartPort

The protocol used depends on the target operating system and system generation.

### Protocol 1: Original Apple II DOS

### Identification Method

**DOS 3.2 and 3.3** do not implement a standardized identification protocol. Boot detection is based simply on the presence of executable code at the slot's boot ROM address.

### Boot ROM Requirements

- Code must be present and executable at **$Cn00-$CnFF** (where n = slot number)
- No specific ID bytes required
- Firmware scans slots 1-7 and executes the first boot ROM found
- First boot ROM to load successfully takes control of the system

### Target Systems

- Apple II
- Apple II+
- Some early Apple IIe configurations

---

### Protocol 2: Pascal 1.1 Firmware Protocol

### ID Byte Structure

Cards following the Pascal 1.1 Firmware Protocol can be identified by ID bytes at the following addresses (where n is the slot number):

| Address | Value | Definition |
|---------|-------|-----------|
| $Cn05 | $38 | ID byte (from Pascal 1.0) |
| $Cn07 | $18 | ID byte (from Pascal 1.0) |
| $Cn0B | $01 | Generic signature of cards with Pascal 1.1 Protocol |
| $Cn0C | $c:i | Device signature byte (c = device type, i = identifier) |

### Device Type Encodings ($Cn0C High Nibble)

| Value | Device Type |
|-------|-------------|
| $3x | Serial port |
| $8x | 80-column display |
| $2x | Mouse |
| Other | Reserved or vendor-specific |

### Important Warning

**Do NOT use Pascal 1.1 ID bytes to identify devices that do not follow this protocol.** This includes:

- Disk II controllers
- SmartPort devices
- SCSI controllers
- Memory expansion cards
- Most modern peripheral cards

Using these bytes to identify such devices can produce incorrect results and may cause system failures.

### Apple II Peripheral Cards Using Pascal 1.1 Protocol

| Card | $Cn05 | $Cn07 | $Cn0B | $Cn0C |
|------|-------|-------|-------|-------|
| Super Serial Card | $38 | $18 | $01 | $31 |
| Apple 80 Column Card | $38 | $18 | $01 | $88 |
| Apple II Mouse Card | $38 | $18 | $01 | $20 |

### Apple IIc Built-in Ports

The IIc includes built-in ports that follow the Pascal 1.1 protocol. Different ROM versions identified by the Version byte at $FBBF:

**IIc ROM 1st version** ($FBBF = $FF):

- Slot 1: Serial Port ($31)
- Slot 2: Serial Port ($31)
- Slot 3: 80-Column ($88)
- Slot 4: Mouse ($20)

**IIc ROM 2nd version** ($FBBF = $00):

- Slots 1-2: Serial Ports ($31)
- Slot 3: 80-Column ($88)
- Slot 4: Mouse ($20)
- Slot 7: AppleTalk ($31)

**IIc ROM 3rd-5th versions** ($FBBF = $03-$05):

- Slots 1-2: Serial Ports ($31)
- Slot 3: 80-Column ($88)
- Slot 7: Mouse ($20) or AppleTalk ($31)

### Target Systems

- Apple II Pascal
- Some Apple IIe Pascal configurations
- Early Apple IIc systems

---

### Protocol 3: ProDOS Block Device Protocol

### Overview

ProDOS introduced a standardized identification protocol for block devices (disk controllers) and SmartPort expansion devices. This protocol is used by:

- ProDOS 1.x and 2.x
- Apple IIe with ProDOS
- Apple IIc (native)
- Apple IIGS

### ID Byte Structure

ProDOS block devices and SmartPort devices are identified by ID bytes at the following addresses:

| Address | Field | Description |
|---------|-------|-------------|
| $Cn01 | Device ID | $20 for ProDOS block devices; $20 for SmartPort |
| $Cn03 | Reserved | $00 (must be zero for ProDOS block devices) |
| $Cn05 | General Code | $03 for ProDOS block devices; $03 for SmartPort |
| $Cn07 | Unit Number / Protocol | $00 for SmartPort; varies for other block devices |

### Identification Algorithm

To identify a device in slot n:

```

1. Read $Cn01
2. If NOT $20, device does not follow ProDOS protocol; skip this slot
3. Read $Cn03
4. If NOT $00, device does not follow ProDOS protocol; skip this slot
5. Read $Cn05
6. If NOT $03, device does not follow ProDOS protocol; skip this slot
7. Read $Cn07
8. If $00, device follows SmartPort protocol (see SmartPort section below)
9. If $xx (non-zero), device is a traditional ProDOS block device
```

### ProDOS Block Device

A ProDOS block device presents a traditional block storage interface:

- Single $Cn00 entry point for boot
- Block read/write via standard Disk II-compatible mechanism
- Examples: Disk II controller, some RAM disk cards, some hard drive controllers

**ID Bytes:**

- $Cn01 = $20
- $Cn03 = $00
- $Cn05 = $03
- $Cn07 = varies (device-specific)

### SmartPort Protocol

SmartPort is an extended protocol providing:

- Multiple logical units (drives) per slot
- Standardized status and control commands
- Support for variable block sizes
- Unified interface for diverse device types (hard drives, networks, etc.)

**ID Bytes:**

- $Cn01 = $20
- $Cn03 = $00
- $Cn05 = $03
- $Cn07 = $00

**Important:** SmartPort devices require protocol-specific STATUS and CONTROL commands for device identification and configuration. Full SmartPort specification details are beyond the scope of this document.

**Reference:** See [ProDOS 8 Organization](https://prodos8.com/docs/technote/15/) for complete SmartPort protocol documentation.

### Target Systems

- Apple IIe with ProDOS
- Apple IIc (native ProDOS support)
- Apple IIGS with ProDOS 8
- Modern emulators and compatible systems

---

### Target System and Protocol Mapping

| System | Primary Protocol | Secondary Protocol | Boot ROM Required |
|--------|-----------------|-------------------|------------------|
| Apple II | Original DOS | None | Yes (simple presence) |
| Apple II+ | Original DOS | None | Yes (simple presence) |
| Apple IIe | ProDOS Block Device | Pascal 1.1 (for built-ins) | Yes (ProDOS ID bytes) |
| Apple IIc | ProDOS Block Device / SmartPort | Pascal 1.1 (for built-ins) | Yes (ProDOS ID bytes) |
| Apple IIGS | ProDOS Block Device / SmartPort | None | Yes (ProDOS ID bytes) |

---

### Boot ROM Implementation Guidelines

### For Original Apple II / II+

- No specific ID bytes needed
- Code must be present and executable at $Cn00
- Firmware calls via `JMP (LOC0)` where LOC0 = $Cn00
- First boot ROM found takes control

### For Apple IIe with ProDOS

- Implement ProDOS Block Device ID bytes ($Cn01, $Cn03, $Cn05, $Cn07)
- Boot ROM at $Cn00 should follow traditional Disk II protocol
- ProDOS will scan for devices during boot and load ProDOS drivers
- Pascal-based systems will look for Pascal 1.1 ID bytes if present

### For Apple IIc / IIGS

- Implement ProDOS Block Device or SmartPort ID bytes
- Boot ROM follows ProDOS block device protocol
- System firmware expects ProDOS-compatible device
- SmartPort devices require additional protocol implementation

### For Multi-Device Compatibility

- Implement all three protocols if targeting multiple systems:
  - Pascal 1.1 ID bytes for compatibility with Pascal systems
  - ProDOS ID bytes for ProDOS systems
  - Executable code at $Cn00 for original DOS systems
- Do NOT use Pascal 1.1 bytes if device is SmartPort-only
- Do NOT implement SmartPort without full protocol support

---

### References

- **Apple II Technical Note #008: Pascal 1.1 Firmware Protocol ID Bytes**  
  https://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Computers/Apple%20II/Apple%20II/Documentation/Misc%20%23008%20Pascal%20Protocol%20ID.pdf

- **ProDOS 8 Organization - SmartPort and Block Device Protocols**  
  https://prodos8.com/docs/technote/15/

- **Apple IIc Technical Reference Manual** - Boot sequence and firmware protocol documentation

---
