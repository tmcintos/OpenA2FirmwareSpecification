### <a id="write-fecd"></a>Write ($FECD)

**Description:**

This is an obsolete entry point. It simply returns to the calling routine via an `RTS` instruction, performing no other actions.

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
    *   Y: Preserved
    *   P: Preserved
*   **Memory:** None.

**Side Effects:**

*   Returns from a subroutine. Its primary purpose as an entry point is for peripheral card slot identification.

**See also:**

*   [Read](#read-fefd)