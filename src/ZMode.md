### <a id="zmode-ffc7"></a>ZMode ($FFC7)

**Description:**

This routine clears the System Monitor's operational mode flag by storing `$00` into the [Monitor Mode Byte](#monitor-mode-byte). This byte dictates how the Monitor interprets hexadecimal numbers in input.

**Input:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   [Monitor Mode Byte](#monitor-mode-byte): The Monitor's mode flag is set to `$00`.

**Side Effects:**

*   Clears the Monitor's operational mode.

**See also:**

*   [MonZ](#monz-ff69)
*   [Monitor Mode Byte](#monitor-mode-byte)