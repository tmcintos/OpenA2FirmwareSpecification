### <a id="crout1-fd8b"></a>CROut1 ($FD8B)

**Description:**

This routine first calls [ClrEOL](#clreol-fc9c) to clear the current text line from the cursor's position to the right edge of the window. It then loads the ASCII carriage return character (`$8D`) into the A register and flows into the [COut](#cout-fded) routine to output this character.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined (consumed by COut)
    *   X: Preserved
    *   Y: Undefined (may be altered by COut or its subroutines)
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   Text memory is modified due to the call to [ClrEOL](#clreol-fc9c).
    *   Cursor position (horizontal and vertical) is modified by [COut](#cout-fded) and its subroutines.

**Side Effects:**

*   Calls [ClrEOL](#clreol-fc9c) to clear a portion of the current text line.
*   Flows into [COut](#cout-fded) to output a carriage return character, which repositions the cursor and may scroll the display.

**See also:**

*   [CROut](#crout-fd8e)
*   [ClrEOL](#clreol-fc9c)
*   [WNDWDTH](#wndwdth)
*   [CH](#ch)
*   [BASL/BASH](#basl-bash)