*   **Description:**

This routine, present in Apple IIe and later ROMs, performs a cold start of the system, including a partial system reset. It may perform partial or complete initialization of the main memory range between `$0200` and `$BEFF`. The specific range and method of initialization can vary between ROM variants. The routine then attempts to start the system via a disk drive or AppleTalk. If no startup device is available, the message "Check startup Device" appears on the screen. This routine does not return to the calling program.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A.

**Output:**

*   **Registers:** None (does not return to calling program).
*   **Memory:**
    *   Main memory, addresses `$0200-$BEFF`: May be partially or completely initialized.
    *   Screen: May display "Check startup Device".

**Side Effects:**

*   Performs a partial system reset.
*   May perform partial or complete initialization of the main memory range between `$0200-$BEFF`.
*   Attempts to boot from a disk drive or AppleTalk.
*   Does not return to the calling program.

**See also:**

*   [Reset ($FA62)](#reset-fa62) (for full system reset)
*   [SLOOP ($FABA)](#sloop-faba) (startup device search loop)
