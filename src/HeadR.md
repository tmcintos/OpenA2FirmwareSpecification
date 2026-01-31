### <a id="headr-fcc9"></a>HeadR ($FCC9)

**Description:**

In Apple IIc firmware, `HeadR ($FCC9)` is an obsolete entry point that consists solely of a return from subroutine (`RTS`) instruction. While earlier firmware revisions might have contained different or more extensive code at this address, the IIc implementation makes it a non-functional entry point that immediately returns control to the caller. The entry point at this address is documented as referring to a "usable gap" of memory of `0x0043` bytes.

**Input:**

*   **Registers:** N/A
*   **Memory:** N/A

**Output:**

*   **Registers:**
    *   A: Preserved.
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Preserved.
*   **Memory:** N/A

**Side Effects:** None (other than returning to the caller).

**See also:** None.