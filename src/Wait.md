### <a id="wait-fca8"></a>Wait ($FCA8)

**Description:**

This routine introduces a time delay determined by the value in the A register ($00-$FF). The delay calculation varies by Apple IIc model:

*   **Apple IIc**: `0.5 * (26 + 27A + 5A^2)` cycles (`0.488889 * (26 + 27A + 5A^2)` microseconds).
*   **Apple IIc Plus**: `0.5 * (50 + 25A + 3A^2) + 29` cycles (`0.488889 * (50 + 25A + 5A^2) + 16.711114` microseconds).

**Input:**

*   **Registers:**
    *   A: The delay value ($00-$FF).
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by internal timing loops.
*   **Memory:** None.

**Side Effects:**

*   Introduces a time delay.

**See also:** None.