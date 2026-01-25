### <a id="setinv-fe80"></a>SetInv ($FE80)

**Description:**

This routine sets [INVFLG](#invflg) to `$3F` so that subsequent text output through [COut1](#cout1-fdf0) will be displayed as inverse characters.

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
    *   [INVFLG](#invflg): The inverse flag is set to `$3F`.

**Side Effects:**

*   Sets [INVFLG](#invflg) to enable inverse text display.

**See also:**

*   [SetNorm](#setnorm-fe84)
*   [COut1](#cout1-fdf0)
*   [INVFLG](#invflg)