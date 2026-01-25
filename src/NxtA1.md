### <a id="nxta1-fcba"></a>NxtA1 ($FCBA)

**Description:**

This routine performs a 16-bit comparison of [A1L/A1H](#a1l-a1h) with [A2L/A2H](#a2l-a2h), then increments [A1L/A1H](#a1l-a1h) by 1. `NxtAl` is an alternate entry point to [NxtA4](#nxta4-fcb4); it does not increment [A4L/A4H](#a4l-a4h), but is otherwise identical to [NxtA4](#nxta4-fcb4).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h): Initial value of the 16-bit address that is compared and incremented.
    *   [A2L/A2H](#a2l-a2h): The 16-bit address used for comparison with A1L/A1H.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected (reflects comparison: Carry set if [A1L/A1H](#a1l-a1h) > [A2L/A2H](#a2l-a2h), Carry clear if <, Zero set if =).
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h) is incremented by 1.

**Side Effects:**

*   Performs a 16-bit comparison and sets CPU flags.
*   Increments [A1L/A1H](#a1l-a1h).

**See also:**

*   [NxtA4](#nxta4-fcb4)
*   [Move](#move-fe2c)
*   [Verify](#verify-fe36)
*   [A1L/A1H](#a1l-a1h)
*   [A2L/A2H](#a2l-a2h)