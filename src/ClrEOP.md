### <a id="clreop-fc42"></a>ClrEOP ($FC42)

**Description:**

This routine clears the text window from the current cursor position to the end of the current line, and from the current line down to the bottom of the window. The cursor is then restored to its original starting position.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [CV](#cv) (address $25): Current vertical cursor position.
    *   [WNDBTM](#wndbtm) (address $23): Bottom edge of the text window.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.
    *   [INVFLG](#invflg) (address $32): Determines if the clear operation uses inverse or normal characters (Apple IIc variant).
    *   VFACTV (address $067B): Video firmware active flag (Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags may be affected
*   **Memory:**
    *   Text memory within the current window from the cursor position to the bottom of the window is cleared.

**Side Effects:**

*   Clears text within the current window.
*   Resets the cursor to its initial position.

**See also:**

*   [WNDWDTH](#wndwdth)
*   [CH](#ch)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)
*   [WNDBTM](#wndbtm)