### <a id="idroutine-fe1f"></a>IDRoutine ($FE1F)

**Description:**

This routine is part of the documented Apple system identification interface. On 8-bit Apple II family computers (Apple II through Apple IIc), this location contains a single return from subroutine (`RTS`) instruction and serves as a placeholder. It immediately returns control to the caller without performing any operations or modifying any registers or memory locations. On the Apple IIGS, this address implements a non-trivial routine that performs actual system identification.

**API Contract (per IIc and IIgs Technical References):**

Software should call IDRoutine with the Carry flag set. Upon return, the Carry flag indicates the system type:

- **If Carry flag is set (returned as set):** System is an 8-bit Apple II, Apple II+, Apple IIe, or Apple IIc. Registers A, X, and Y are unchanged.
- **If Carry flag is clear (returned as clear):** System is an Apple IIGS or later system. Registers A, X, and Y contain identification information about the system.

**Behavior on 8-bit Apple II:**

Since the 8-bit implementation is simply `RTS`, code calling IDRoutine with Carry set will have the Carry flag remain set upon return (no operation occurred to modify it), correctly indicating that the system is an 8-bit Apple II variant.

**Note (System Difference):** The Apple IIGS ROM implements this address with actual system identification logic that clears the Carry flag and fills registers A, X, Y with system information. This allows compatible code to detect the system type at runtime.

**Input:**

*   **Registers:**
    *   A: Undefined (may contain any value)
    *   X: Undefined (may contain any value)
    *   Y: Undefined (may contain any value)
    *   **C (Carry flag): Must be set (=1) by the caller**
*   **Memory:** N/A

**Output:**

*   **Registers (8-bit Apple II):**
    *   A: Unchanged (preserved)
    *   X: Unchanged (preserved)
    *   Y: Unchanged (preserved)
    *   **C (Carry flag): Set (=1) — indicates 8-bit Apple II system**
*   **Registers (Apple IIGS):**
    *   A: System identification byte (varies)
    *   X: System identification byte (varies)
    *   Y: System identification byte (varies)
    *   **C (Carry flag): Clear (=0) — indicates Apple IIGS or later**
*   **Memory:** No memory locations are modified.

**Side Effects:** None on 8-bit Apple II (instruction is just `RTS`).

**See also:** System identification protocol for runtime system type detection.