### <a id="pread4-fb21"></a>PRead4 ($FB21)

**Description:**

This routine is identical to [PRead](#pread-fb1e), except it does not read the mouse position if connected. It exclusively acquires input from the hand control (game paddles).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Contains the position of the specified hand control's dial ($00-$FF).
    *   P: Flags affected by internal input operations.
*   **Memory:** None.

**Side Effects:**

*   Reads input exclusively from the hand control.

**See also:**

*   [PRead](#pread-fb1e)