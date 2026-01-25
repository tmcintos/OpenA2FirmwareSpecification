### <a id="setx-ce1a"></a>SETX ($CE1A) (Internal)

**Description:**

This is an **internal helper routine** that consists solely of a return from subroutine (`RTS`) instruction. It immediately returns control to the caller without performing any operations or modifying any registers or memory locations. In the context of routines like [CHK80](#chk80-cdcd), it serves as an exit point when no column mode conversion is necessary.

**Input:**

*   **Registers:** N/A
*   **Memory:** N/A

**Output:**

*   **Registers:** All registers are preserved.
*   **Memory:** No memory locations are modified.

**Side Effects:** None.

**See also:**

*   [CHK80](#chk80-cdcd)