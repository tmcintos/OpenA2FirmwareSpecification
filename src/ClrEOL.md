### <a id="clreol-fc9c"></a>ClrEOL ($FC9C)

**Description:**

This routine erases text on the current line within the active text window, starting from the current horizontal cursor position ([CH](#ch)) and extending to the rightmost boundary of the window ([WNDWDTH](#wndwdth)).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.
    *   [WNDLFT](#wndlft) (address $20): Left edge of the text window.
    *   [INVFLG](#invflg) (address $32): Determines if the clear operation uses inverse or normal characters (Apple IIc variant).
    *   OURCH (address $057B): Used for 80-column display.
    *   VFACTV (address $067B): Video firmware active flag (Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   Text memory is modified from [CH](#ch) to [WNDWDTH](#wndwdth) on the current line.

**Side Effects:**

*   Clears a portion of the visible text on the current line.

**See also:**

*   [WNDWDTH](#wndwdth)
*   [CH](#ch)
*   [BASL/BASH](#basl-bash)