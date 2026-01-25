### <a id="insds2-f88e"></a>InsDs2 ($F88E)

**Description:**

This routine determines the length of a 6502 instruction whose opcode is provided in the A register. It returns the calculated instruction length (minus one byte) for recognized 6502 opcodes. For any non-6502 opcode, it returns a length of $00. Notably, for compatibility reasons, the `BRK` opcode also returns a length of $00, not $01 as might otherwise be expected.

**Input:**

*   **Registers:**
    *   A: The opcode of the 6502 instruction for which the length is to be determined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Contains $00.
    *   P: Undefined.
*   **Memory:**
    *   [LENGTH](#length) (address $2F): Contains the calculated instruction length (minus one byte) for 6502 instructions, or $00 if not a recognized 6502 opcode.

**Side Effects:**

*   Calculates the length of a 6502 instruction and stores it in [LENGTH](#length).

**See also:**

*   [InsDs1-2](#insds1-2-f88c)
*   [LENGTH](#length)