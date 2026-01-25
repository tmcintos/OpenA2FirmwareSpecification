### <a id="nxta4-fcb4"></a>NxtA4 ($FCB4)

**Description:**

This routine increments [A4L/A4H](#a4l-a4h) by 1, then calls [NxtA1](#nxta1-fcba). [NxtA1](#nxta1-fcba) performs a 16-bit comparison of [A1L/A1H](#a1l-a1h) with [A2L/A2H](#a2l-a2h) and increments [A1L/A1H](#a1l-a1h) by 1. `NxtA4` is called repeatedly by [Move](#move-fe2c) and [Verify](#verify-fe36) as long as [A1L/A1H](#a1l-a1h) <= [A2L/A2H](#a2l-a2h).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h): Initial value of the 16-bit address that is compared and incremented.
    *   [A2L/A2H](#a2l-a2h): The 16-bit address used for comparison with A1L/A2H.
    *   [A4L/A4H](#a4l-a4h): Initial value of the 16-bit address that is incremented.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected (reflects [NxtA1](#nxta1-fcba) comparison).
*   **Memory:**
    *   [A4L/A4H](#a4l-a4h) is incremented by 1.
    *   [A1L/A1H](#a1l-a1h) is incremented by 1.

**Side Effects:**

*   Increments memory pointers [A4L/A4H](#a4l-a4h) and [A1L/A1H](#a1l-a1h).
*   Performs a comparison and sets CPU flags.

**See also:**

*   [NxtA1](#nxta1-fcba)
*   [Move](#move-fe2c)
*   [Verify](#verify-fe36)
*   [A1L/A1H](#a1l-a1h)
*   [A2L/A2H](#a2l-a2h)
*   [A4L/A4H](#a4l-a4h)