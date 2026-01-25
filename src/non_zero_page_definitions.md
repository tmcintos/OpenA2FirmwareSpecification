## <a id="non-zero-page-definitions"></a>Non-Zero-Page Memory Locations

| Address | Label(s) | Description | Usage |
|---|---|---|---|
| $03F0-$03F1 | BRKV | Break Instruction Vector (IIe+). | 16-bit pointer executed when BRK ($00) instruction is encountered. Default points to Monitor Break handler. Used for debugging and system break handling. Added in Apple IIe; not present in original Apple II/II+. |
| $03F2-$03F3 | SOFTEV | Warm Start / Soft Power-On Vector (IIe+). | 16-bit pointer to warm-start routine. Executed on RESET if [SOFTEV XOR (SOFTEV+1) = PWREDUP], indicating a clean shutdown. Default points to firmware initialization. Added in Apple IIe. |
| $03F4 | PWREDUP | Power-Up Detection Byte (IIe+). | Single byte containing magic value for warm-start detection. Valid value = SOFTEV+1 XOR $A5 (complement of high byte). If this value matches, RESET is treated as warm start instead of cold start. Added in Apple IIe. |
| $03F8-$03F9 | USRADR | User Address / Applesoft Exit Vector. | 16-bit pointer executed by `POP` instruction (simulated via stack manipulation) or Applesoft END statement. Default points to Monitor. Used for returning from user programs. Present in all Apple II variants. |
| $03FB-$03FC | NMI | Non-Maskable Interrupt Handler Vector. | 16-bit pointer executed when NMI (non-maskable interrupt) signal is asserted. Used for system-critical interrupt handling. Present in all Apple II variants. |
| $03FE-$03FF | IRQLOC | Interrupt Request Handler Vector. | 16-bit pointer executed when IRQ (maskable interrupt) signal is asserted. Default points to firmware IRQ handler. Present in all Apple II variants. |
| $07FB | <a id="cursor"></a>CURSOR | Cursor type and status. | Defines the type of cursor displayed by input routines (e.g., block, checkerboard). |
| $047B | <a id="oldch"></a>OLDCH | Old Horizontal Cursor Position. | Stores the previous horizontal cursor position; used in 80-column mode to track cursor movement. |
| $057B | <a id="ourch"></a>OURCH | Our Horizontal Cursor Position. | Stores the current horizontal cursor position in 80-column mode; used internally by 80-column display routines. |
| $067B | <a id="vfactv"></a>VFACTV | Video Firmware Active Flag. | Bit 7 = 0 when video firmware is inactive; used to test if 80-column card is active. |
| $04FB | <a id="vmode"></a>VMODE | Video Mode Byte. | 80-column mode flag; used internally to track whether 80-column mode is enabled. |
| $C000 | KBD | Keyboard Data Register. | Read: Returns last key pressed, with bit 7 set ($80 | ASCII code). Used for polling keyboard input. |
| $C010 | KBDSTRB | Keyboard Strobe Register. | Read/Write: Reading clears the keyboard interrupt. Must be read to acknowledge keyboard input. |
| $0200 | <a id="inbuf"></a>INBUF | Monitor Input Buffer. | 128-byte buffer for storing user input lines, typically in the Monitor or command-line input routines. |
| $FE95 | OutPort | "PR#" Output Port Entry. | Routine entry point that selects the output port (character destination); used to redirect output to peripherals. |
| $FFCC | CHRTBL | Monitor ASCII Command Table. | Table of ASCII characters corresponding to Monitor commands (e.g., 'G', 'X', 'A', 'L', 'S'). Located at fixed address for compatibility with external tools. |
| $FFE3 | SUBTBL | Monitor Routine Offset Table. | Table of routine offsets corresponding to commands in CHRTBL; indices are paired with CHRTBL for command dispatch. |
