### <a id="iorts-ff58"></a>IORTS ($FF58)

**Description:**

This address contains an `RTS` instruction. On Apple II systems with expansion slots, peripheral cards can use this to determine their slot.

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

**See also:** None.