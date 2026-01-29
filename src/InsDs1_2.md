### <a id="insds1_2-f88c"></a>InsDs1_2 ($F88C)

**Description:**

This routine loads the A register with an opcode from the memory location pointed to by [PCL/PCH](#pcl-pch) (Program Counter Low/High), indexed by the X register. It then falls into the [InsDs2](#insds2-f88e) routine, which is responsible for determining the instruction's length and addressing mode.

**Input:**

*   **Registers:**
    *   A: Undefined (loaded internally).
    *   X: The offset (relative to [PCL/PCH](#pcl-pch)) used to fetch the opcode from memory.
    *   Y: Undefined.
*   **Memory:**
    *   [PCL/PCH](#pcl-pch) (address $3A-$3B): The Program Counter Low/High, providing the base address from which the opcode is fetched.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Contains $00.
    *   P: Undefined.
*   **Memory:**
    *   [LENGTH](#length) (address $2F): Contains the calculated instruction length (minus one byte) for 6502 instructions, or $00 if not a recognized 6502 opcode (as set by [InsDs2](#insds2-f88e)).

**Side Effects:**

*   Loads the A register with an opcode from memory.
*   Transfers control to [InsDs2](#insds2-f88e).
*   Calculates the length of a 6502 instruction and stores it in [LENGTH](#length) (via [InsDs2](#insds2-f88e)).

**See also:**

*   [InsDs2](#insds2-f88e)
*   [PCL/PCH](#pcl-pch)
*   [LENGTH](#length)