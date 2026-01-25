### <a id="prntyx-f940"></a>PrntYX ($F940)

**Description:**

This routine prints the contents of the Y (high byte) and X (low byte) registers as a four-digit hexadecimal value to standard output. This is achieved by internally calling [PrByte](#prbyte-fdda).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: Contains the low byte of the 16-bit value to be printed.
    *   Y: Contains the high byte of the 16-bit value to be printed.
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

*   Prints a four-digit hexadecimal value.

**See also:**

*   [PrByte](#prbyte-fdda)
*   [PrntAX](#prntax-f941)