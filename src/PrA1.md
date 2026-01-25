### <a id="pra1-fd92"></a>PrA1 ($FD92)

**Description:**

This routine sends a carriage return to standard output, then prints the contents of [A1L/A1H](#a1l-a1h) in hexadecimal, followed by a hyphen (-). The [Verify](#verify-fe36) routine uses `PrA1` with [PrByte](#prbyte-fdda) to print addresses and values during memory comparisons.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Standard output is used.

**Side Effects:**

*   Outputs a carriage return.
*   Prints hex value of [A1L/A1H](#a1l-a1h) and a hyphen.

**See also:**

*   [PrByte](#prbyte-fdda)
*   [Verify](#verify-fe36)
*   [A1L/A1H](#a1l-a1h)