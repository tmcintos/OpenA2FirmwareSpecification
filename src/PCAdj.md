### <a id="pcadj-f953"></a>PCAdj ($F953)

**Description:**

This routine adjusts the Monitor's program counter ([PCL/PCH](#pcl-pch)). It loads [PCL](#pcl-pch) into A and [PCH](#pcl-pch) into Y, then increments A and Y by a value (1-4). [LENGTH](#length) stores 1 less than the increment amount. The adjusted PC value is stored back into [PCL/PCH](#pcl-pch).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the incremented [PCL](#pcl-pch).
    *   X: Preserved
    *   Y: Contains the incremented [PCH](#pcl-pch).
    *   P: Flags affected by arithmetic additions.
*   **Memory:**
    *   [PCL/PCH](#pcl-pch): Updated with the incremented value.

**Side Effects:**

*   Increments the Monitor's program counter ([PCL/PCH](#pcl-pch)).

**See also:**

*   [LENGTH](#length)
*   [PCL/PCH](#pcl-pch)