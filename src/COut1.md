### <a id="cout1-fdf0"></a>COut1 ($FDF0)

**Description:**

This routine displays the ASCII character in the A register at the current cursor position, then advances the cursor. It processes control characters such as carriage return ($8D), line feed ($8A), backspace ($88), and bell ($87). Printable character display (normal or inverse) is governed by [INVFLG](#invflg), unless the character is a control character.

**Input:**

*   **Registers:**
    *   A: The ASCII character to be displayed.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [INVFLG](#invflg) (address $32): Determines if the output character should be inverse.
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [CV](#cv) (address $25): Current vertical cursor position.
    *   [KSWL/KSWH](#kswl-kswh) (address $36-$37): Address of the keyboard input routine, used by subroutines.
    *   VFACTV (address $067B): Video firmware active flag (Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   Text memory at the current cursor position is updated.
    *   [CH](#ch) and [CV](#cv) may be updated if the cursor advances or moves.

**Side Effects:**

*   Displays a character.
*   Advances the cursor.
*   Handles specific control characters.

**See also:**

*   [COut](#cout-fded)
*   [COutZ](#coutz-fdf6)
*   [INVFLG](#invflg)
*   [CH](#ch)
*   [CV](#cv)