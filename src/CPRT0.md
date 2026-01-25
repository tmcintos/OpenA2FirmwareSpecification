### <a id="cprt0-fec2"></a>CPRT0 ($FEC2) (Internal)

**Description:**

This is an **internal helper routine**, primarily branched to by the `IPORT ($FE9B)` routine when handling certain input/output configurations. It decrements the A register (intended to turn $00 into $FF), stores this resulting value into the zero-page location [CURSOR](#cursor), and then loads A with a constant value of `#$F7`. Finally, it branches to the `DOPR0 ($FECE)` routine. This sequence suggests it's part of a process to set a "checkerboard" cursor and then initiate a PR#0-like reset of video firmware.

**Input:**

*   **Registers:**
    *   A: Expected to be $00 on entry, so that `dec A` results in $FF.
    *   X: N/A
    *   Y: N/A
*   **Memory:** N/A (the routine primarily acts on its A register input, which is a fixed value).

**Output:**

*   **Registers:**
    *   A: Modified (contains `#$F7` on transfer to `DOPR0`).
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Flags affected by `dec A`, `sta`, and `lda` operations.
*   **Memory:**
    *   [CURSOR](#cursor) (address $07FB): Set to $FF (checkerboard cursor).

**Side Effects:**

*   Sets the [CURSOR](#cursor) to $FF (representing a checkerboard cursor).
*   Transfers control to the `DOPR0 ($FECE)` routine.

**See also:**

*   `IPORT ($FE9B)` (internal routine)
*   `DOPR0 ($FECE)` (internal routine)
*   [CURSOR](#cursor)