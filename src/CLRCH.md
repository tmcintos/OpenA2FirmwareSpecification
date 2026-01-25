### <a id="clrch-fee9"></a>CLRCH ($FEE9) (Internal)

**Description:**

This is an **internal helper routine** called by routines like [HOMECUR](#homecur-cda5) to clear the horizontal cursor positions. It initializes a value in the A register and then calls [GETCUR2](#getcur2-ccad) to perform the actual updates to [CH](#ch), [OLDCH](#oldch), and [OURCH](#ourch). Before returning, it loads the final value of [OURCH](#ourch) into the A register.

**Input:**

*   **Registers:** N/A (the routine itself sets the initial value for A).
*   **Memory:**
    *   [OURCH](#ourch) (address $057B): Its value is read just before returning, effectively making it an input to the A register output.

**Output:**

*   **Registers:**
    *   A: Contains the value of [OURCH](#ourch) on exit.
    *   X: Modified by internal calls (specifically [GETCUR2](#getcur2-ccad)).
    *   Y: Modified by internal calls (specifically [GETCUR2](#getcur2-ccad)).
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [CH](#ch) (address $24): Set by [GETCUR2](#getcur2-ccad) (to $00 if in 80-column mode, or based on the input Y to [GETCUR2](#getcur2-ccad)).
    *   [OLDCH](#oldch) (address $047B): Set by [GETCUR2](#getcur2-ccad).
    *   [OURCH](#ourch) (address $057B): Updated by [GETCUR2](#getcur2-ccad).

**Side Effects:**

*   Calls [GETCUR2](#getcur2-ccad) to manage horizontal cursor positions.
*   Sets [CH](#ch), [OLDCH](#oldch), and [OURCH](#ourch) based on 80-column mode and the Y register value passed to [GETCUR2](#getcur2-ccad).

**See also:**

*   [HOMECUR](#homecur-cda5)
*   [GETCUR2](#getcur2-ccad)
*   [CH](#ch)
*   [OLDCH](#oldch)
*   [OURCH](#ourch)