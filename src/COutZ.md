### <a id="coutz-fdf6"></a>COutZ ($FDF6)

**Description:**

This routine is an alternative entry point to [COut1](#cout1-fdf0). Its functionality is identical, but `COutZ` bypasses the initial application of [INVFLG](#invflg). This is useful for enhanced video firmware that manages the inverse flag independently after processing control characters, preventing redundant application.

**Input:**

*   **Registers:**
    *   A: The ASCII character to be displayed.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [CV](#cv) (address $25): Current vertical cursor position.
    *   [KSWL/KSWH](#kswl-kswh) (address $36-$37): Address of the keyboard input routine, used by subroutines.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   Text memory at current cursor position is modified.
    *   [CH](#ch) and [CV](#cv) may be updated due to cursor advancement or control character processing.

**Side Effects:**

*   Displays a character.
*   Advances the cursor.
*   Processes specific control characters.

**See also:**

*   [COut](#cout-fded)
*   [COut1](#cout1-fdf0)
*   [INVFLG](#invflg)
*   [CH](#ch)
*   [CV](#cv)