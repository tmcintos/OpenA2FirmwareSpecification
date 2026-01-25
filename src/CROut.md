### <a id="crout-fd8e"></a>CROut ($FD8E)

**Description:**

This routine initiates a carriage return by sending a carriage return character to the standard output, typically repositioning the cursor to the beginning of the next line.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): The address of the current character output routine.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by the underlying output routine.
*   **Memory:**
    *   Text memory at the current cursor position may be modified.
    *   [CH](#ch) and [CV](#cv) may be updated, depending on the active output routine.

**Side Effects:**

*   Outputs a carriage return.
*   Modifies the cursor's position.

**See also:**

*   [COut](#cout-fded)
*   [CR](#cr-fc62)
*   [CSWL/CSWH](#cswl-cswh)
*   [CH](#ch)
*   [CV](#cv)