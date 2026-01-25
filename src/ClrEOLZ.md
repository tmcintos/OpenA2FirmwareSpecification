### <a id="clreolz-fc9e"></a>ClrEOLZ ($FC9E)

**Description:**

This routine clears a segment of the current text line from the column specified by the Y register to the rightmost edge of the active text window ([WNDWDTH](#wndwdth)).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: Starting column position for clearing.
*   **Memory:**
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.
    *   [INVFLG](#invflg) (address $32): Determines if the clear operation uses inverse or normal characters (Apple IIc variant).
    *   VFACTV (address $067B): Video firmware active flag (Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags may be affected
*   **Memory:**
    *   Text memory is modified from the column specified by Y up to [WNDWDTH](#wndwdth) on the current line.

**Side Effects:**

*   Clears a portion of the visible text on the current line.

**See also:**

*   [WNDWDTH](#wndwdth)
*   [WNDLFT](#wndlft)
*   [BASL/BASH](#basl-bash)