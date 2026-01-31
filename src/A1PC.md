### <a id="a1pc-fe75"></a>A1PC ($FE75)

**Description:**

This is an **internal helper routine** primarily used by other firmware routines (e.g., [Go](#go-feb6)) to conditionally copy a 16-bit address from the zero-page locations [A1L/A1H](#a1l-a1h) to the program counter ([PCL/PCH](#pcl-pch)). Its behavior is dependent on the initial value of the X register. If the X register is zero on entry, the routine performs no copy and returns immediately. If X is non-zero (typically $01), it copies the contents of [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch).

**Input:**

*   **Registers:**
    *   X: Controls the copy operation. If X=$00, no copy is performed. If X=$01, both bytes of the 16-bit address are copied.
    *   A: N/A
    *   Y: N/A
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h) (address $3C-$3D): The 16-bit source address that may be copied to the program counter. Its initial value is read during the copy operation.

**Output:**

*   **Registers:**
    *   A: Modified (contains the last byte copied or the value of X if no copy).
    *   X: Modified (decremented during the copy loop if X was initially non-zero).
    *   Y: Preserved.
    *   P: Flags affected by `txa`, `beq`, `lda`, `sta`, and `dex` instructions.
*   **Memory:**
    *   [PCL/PCH](#pcl-pch) (address $3A-$3B): The 16-bit program counter address, updated with the value from [A1L/A1H](#a1l-a1h) if X was non-zero on entry.

**Side Effects:**

*   Conditionally copies a 16-bit address from [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch).

**See also:**

*   [Go](#go-feb6)
*   [A1L/A1H](#a1l-a1h)
*   [PCL/PCH](#pcl-pch)