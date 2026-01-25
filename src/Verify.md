### <a id="verify-fe36"></a>Verify ($FE36)

**Description:**

This routine compares the contents of two memory ranges. It reads from the first block (pointed to by [A1L/A1H](#a1l-a1h) + Y), then from the second ([A4L/A4H](#a4l-a4h) + Y), comparing until [A2L/A2H](#a2l-a2h). If bytes mismatch, it prints the address, a hyphen, the first byte, and (in parentheses) the second byte.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: An offset used for indexed addressing.
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h) (address $3C-$3D): Beginning address of the first block.
    *   [A2L/A2H](#a2l-a2h) (address $3E-$3F): Ending address of the first block.
    *   [A4L/A4H](#a4l-a4h) (address $40-$41): Beginning address of the second block.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Flags affected by internal comparisons.
*   **Memory:**
    *   Detected mismatches are reported to standard output.

**Side Effects:**

*   Compares memory ranges.
*   Reports mismatches to standard output.
*   Affects CPU flags.

**See also:**

*   [Move](#move-fe2c)
*   [NxtA4](#nxta4-fcb4)
*   [PrA1](#pra1-fd92)
*   [A1L/A1H](#a1l-a1h)
*   [A2L/A2H](#a2l-a2h)
*   [A4L/A4H](#a4l-a4h)
