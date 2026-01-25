### <a id="pread-fb1e"></a>PRead ($FB1E)

**Description:**

This routine returns the dial position of a hand control or mouse axis ($00-$FF) in the Y register. The X register specifies the hand control ($00 or $01) or mouse axis ($00 for X, $01 for Y). If a mouse is connected and in transparent mode, `PRead` prioritizes reading the mouse position.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: Specifies the hand control number ($00 or $01) or the mouse axis to read ($00 for X-position, $01 for Y-position).
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Contains the position ($00-$FF).
    *   P: Flags affected by internal input operations.
*   **Memory:** None.

**Side Effects:**

*   Reads input from hand control or mouse.

**See also:**

*   [PRead4](#pread4-fb21)