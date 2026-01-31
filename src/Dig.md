### <a id="dig-ff8a"></a>Dig ($FF8A)

**Description:**

This entry point is part of the Monitor’s hex-scanning implementation. It converts one hexadecimal digit into a 4-bit value and shifts it into the 16-bit accumulator [A2L/A2H](#a2l-a2h) ($3E/$3F).

`Dig` is reached from [NxtChr ($FFAD)](#nxtchr-ffad) after the input character has been transformed into a form suitable for range checks and decoding. `Dig` does **not** return to its caller with `RTS`; instead it continues with the shared digit-scan logic and then branches back into `NxtChr`.

Because `Dig` only shifts into a 16-bit accumulator, supplying more than four digits while building a value naturally discards earlier (high) digits and retains only the most recent four.

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

*   Decodes a single digit and shifts it into [A2L/A2H](#a2l-a2h).
*   When [MODE](#mode) is `$00`, each accepted digit also causes the current accumulated value in `A2` to be copied into `A1` and `A3` (i.e., `A1L/A1H` and `A3L/A3H` track the same value while scanning).
*   Transfers control back into [NxtChr ($FFAD)](#nxtchr-ffad) rather than returning via `RTS`.

**See also:**

*   [NxtChr ($FFAD)](#nxtchr-ffad)
*   [A2L/A2H](#a2l-a2h)