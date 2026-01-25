### <a id="prntax-f941"></a>PrntAX ($F941)

**Description:**

This routine prints the contents of the A (high byte) and X (low byte) registers as a four-digit hexadecimal value to standard output.

**Input:**

*   **Registers:**
    *   A: Contains the high byte of the 16-bit value to be printed.
    *   X: Contains the low byte of the 16-bit value to be printed.
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   Standard output is used.

**Side Effects:**

*   Prints a four-digit hexadecimal value to standard output.

**See also:**

*   [PrByte](#prbyte-fdda)
*   [PrHex](#prhex-fde3)