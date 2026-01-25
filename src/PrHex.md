### <a id="prhex-fde3"></a>PrHex ($FDE3)

**Description:**

This routine prints the lower nibble of the A register (accumulator) as a single hexadecimal digit to standard output.

**Input:**

*   **Registers:**
    *   A: The value whose lower nibble is to be printed as a hexadecimal digit.
    *   X: N/A
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

*   Outputs a hexadecimal character.

**See also:**

*   [PrByte](#prbyte-fdda)
*   [COUT](#cout-fded)