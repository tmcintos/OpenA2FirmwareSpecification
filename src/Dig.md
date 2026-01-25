### <a id="dig-ff8a"></a>Dig ($FF8A)

**Description:**

This routine converts an ASCII code representing a hexadecimal digit into its corresponding hexadecimal number. This process is initiated by [NxtChr ($FFAD)](#nxtchr-ffad), which preprocesses the ASCII code (performing an exclusive OR with $B0 and potentially adding $88 for characters A-F) before passing it in the A register to `Dig`. `Dig` then shifts the conditioned character bit-by-bit into the zero-page locations [A2L](#a2l) ($3E) and [A2H](#a2h) ($3F), effectively storing the hexadecimal value. Control is then passed back to [NxtChr ($FFAD)](#nxtchr-ffad). This combination of [NxtChr ($FFAD)](#nxtchr-ffad) and `Dig` routines is essential for converting user-entered ASCII digits into numerical values.

**Input:**

*   **Registers:**
    *   A: The ASCII code of a hexadecimal digit, after being conditioned by the [NxtChr ($FFAD)](#nxtchr-ffad) routine (e.g., $B0-$BF for 0-9, or $C1-$CF for A-F after processing).
    *   X: Undefined.
    *   Y: The offset into the input buffer ($0200) for the next character to decode.
*   **Memory:**
    *   Input buffer ($0200): The start of the Monitor's input buffer.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: The offset into the input buffer for the next character to decode (same as input Y).
    *   P: Undefined.
*   **Memory:**
    *   [A2L/A2H](#a2l-a2h) (addresses $3E-$3F): Stores the hexadecimal number decoded from the ASCII character.

**Side Effects:**

*   Converts an ASCII hexadecimal digit to its numerical equivalent.
*   Stores the result in [A2L/A2H](#a2l-a2h).
*   Transfers control back to [NxtChr ($FFAD)](#nxtchr-ffad).

**See also:**

*   [NxtChr ($FFAD)](#nxtchr-ffad)
*   [A2L/A2H](#a2l-a2h)