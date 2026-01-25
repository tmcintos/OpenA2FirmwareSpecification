### <a id="move-fe2c"></a>Move ($FE2C)

**Description:**

This routine copies a block of memory from a source ([A1L/A1H](#a1l-a1h) to [A2L/A2H](#a2l-a2h)) to a destination ([A4L/A4H](#a4l-a4h)) byte-by-byte. It calls [NxtA4](#nxta4-fcb4) to increment pointers and compare [A1L/A1H](#a1l-a1h) with [A2L/A2H](#a2l-a2h). Copying continues as long as [A1L/A1H](#a1l-a1h) is less than or equal to [A2L/A2H](#a2l-a2h).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: An offset for indexed addressing (preserved across main loop iterations, but modified by [NxtA4](#nxta4-fcb4)).
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined (modified by [NxtA4](#nxta4-fcb4)).
    *   P: Flags affected by internal comparisons.
*   **Memory:**
    *   The destination memory block (starting at [A4L/A4H](#a4l-a4h)) contains the copied data.
    *   [A1L/A1H](#a1l-a1h) and [A4L/A4H](#a4l-a4h) are updated (incremented).

**Side Effects:**

*   Copies data between specified memory ranges.
*   Updates [A1L/A1H](#a1l-a1h) and [A4L/A4H](#a4l-a4h) memory locations.
*   Affects CPU flags.

**See also:**

*   [NxtA4](#nxta4-fcb4)
*   [Verify](#verify-fe36)
*   [A1L/A1H](#a1l-a1h)
*   [A2L/A2H](#a2l-a2h)
*   [A4L/A4H](#a4l-a4h)