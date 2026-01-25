### <a id="instdsp-f8d0"></a>InstDsp ($F8D0)

**Description:**

This routine disassembles and displays a single 6502 instruction. The instruction to be disassembled is pointed to by the 16-bit address stored in [PCL](#pcl) and [PCH](#pch) (Program Counter Low and High bytes) in bank $00. The disassembled output is sent to the standard output device (e.g., the screen).

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:**
    *   [PCL](#pcl) (address $3A): Low byte of the program counter, pointing to the instruction to disassemble.
    *   [PCH](#pch) (address $3B): High byte of the program counter, pointing to the instruction to disassemble.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Standard output device (e.g., screen) displays the disassembled instruction.

**Side Effects:**

*   Outputs the disassembled instruction to the standard output device.

**See also:**

*   [PCL](#pcl)
*   [PCH](#pch)
*   [COUT](#cout-fded) (for outputting characters)
*   [InsDs1-2](#insds1-2-f88c)
*   [InsDs2](#insds2-f88e)