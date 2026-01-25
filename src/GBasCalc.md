### <a id="gbascalc-f847"></a>GBasCalc ($F847)

**Description:**

This routine calculates the 16-bit base memory address for a Lo-Res graphics display row ($00-$2F) provided in the A register. The calculated address is stored in [GBASL/GBASH](#gbasl-gbash).

**Input:**

*   **Registers:**
    *   A: Lo-Res graphics row number ($00-$2F)
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [GBASL/GBASH](#gbasl-gbash) (address $26-$27): Current low-resolution graphics base address. The routine reads the initial value of GBASL as part of its calculation.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address.
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by arithmetic operations.
*   **Memory:**
    *   [GBASL/GBASH](#gbasl-gbash): Updated with the computed 16-bit base address.

**Side Effects:** None.

**See also:**

*   [Plot](#plot-f800)
*   [Plot1](#plot1-f80e)
*   [GBASL/GBASH](#gbasl-gbash)