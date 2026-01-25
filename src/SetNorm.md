### <a id="setnorm-fe84"></a>SetNorm ($FE84)

**Description:**

This routine sets [INVFLG](#invflg) to `$FF` so that subsequent text output through [COut1](#cout1-fdf0) will be displayed as normal characters.

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
    *   P: Undefined
*   **Memory:**
    *   [INVFLG](#invflg): The inverse flag is set to `$FF`.

**Side Effects:**

*   Sets [INVFLG](#invflg) to enable normal text display.

**See also:**

*   [SetInv](#setinv-fe80)
*   [COut1](#cout1-fdf0)
*   [INVFLG](#invflg)