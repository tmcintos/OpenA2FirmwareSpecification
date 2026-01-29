### <a id="idroutine-fe1f"></a>IDRoutine ($FE1F)

**Description:**

This routine is part of the documented Apple system identification interface for distinguishing 8-bit Apple II systems from 16-bit systems (Apple IIgs). On 8-bit Apple II family computers (Apple II through Apple IIc), this location contains a single return from subroutine (`RTS`) instruction. It immediately returns control to the caller without performing any operations or modifying any registers or memory locations.

**References:**
- Apple II Miscellaneous Technical Note #7: *Apple II Family Identification* (https://prodos8.com/docs/technote/misc/07/)
- Apple II Miscellaneous Technical Note #2: *Apple II Family Identification Routines 2.2* (https://prodos8.com/docs/technote/misc/02/)

**Calling Convention:**

Software should call IDRoutine with the Carry flag set:

```
SEC         ; Set carry flag
JSR $FE1F   ; Call IDRoutine
BCS IS_8BIT ; If carry still set, 8-bit Apple II
BCC IS_16BIT; If carry clear, 16-bit system (out of scope)
```

**Behavior on 8-bit Apple II:**

Since the 8-bit implementation is simply `RTS`, code calling IDRoutine with Carry set will have the Carry flag remain set upon return (no operation occurred to modify it), correctly indicating that the system is an 8-bit Apple II variant.

**Behavior on 16-bit Systems:**

The Apple IIgs (out of scope for this specification) implements actual identification logic at this address that clears the Carry flag and returns system information in registers. This difference allows software to detect the system type at runtime.

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
*   **Registers (16-bit systems, out of scope):**
    *   **C (Carry flag): Clear (=0) — indicates 16-bit system (Apple IIgs)**
    *   Register contents not documented (16-bit systems out of scope)
*   **Memory:** No memory locations are modified.

**Side Effects:** None on 8-bit Apple II (instruction is just `RTS`).

**See also:**
- [Hardware Variants and Identification](#hardware-variants-and-identification) - Complete hardware detection methods
- [Hardware Identification Bytes](#identification-byte-locations) - ROM identification byte table