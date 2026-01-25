### <a id="list-fe5e"></a>List ($FE5E)

**Description:**

This routine disassembles and prints 20 6502 instructions to standard output, starting from the address in [A1L/A1H](#a1l-a1h). After processing, [A1L/A1H](#a1l-a1h) is updated to point to the instruction after the last disassembled one. It calls internal routines like [InstDsp](#instdsp-f8d0).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Disassembled instructions are printed to standard output.
    *   [A1L/A1H](#a1l-a1h): Updated to point to the instruction after the last disassembled instruction.

**Side Effects:**

*   Prints disassembled instructions.
*   Modifies the [A1L/A1H](#a1l-a1h) pointer.

**See also:**

*   [InstDsp](#instdsp-f8d0)
*   [A1L/A1H](#a1l-a1h)