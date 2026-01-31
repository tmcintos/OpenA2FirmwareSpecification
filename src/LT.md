### LT ($FE20)

**Description:**

Monitor command handler for the “`<`” delimiter used by the `M` (Move) and `V` (Verify) commands.

This routine copies the 16-bit value currently in [A2L/A2H](#a2l-a2h) into both [A4L/A4H](#a4l-a4h) and `A5L/A5H` ($44/$45). This sets up the destination pointer used by [Move](#move-fe2c) / [Verify](#verify-fe36), and also preserves the same address in A5.

**Input:**

- **Memory:**
  - [A2L/A2H](#a2l-a2h) = address parsed from the command line (right-hand side of the delimiter)

**Output:**

- **Memory:**
  - [A4L/A4H](#a4l-a4h) updated to the A2 value
  - `A5L/A5H` ($44/$45) updated to the A2 value

**Side Effects:**

- Prepares Monitor address variables for subsequent Move/Verify execution.

**Notes:**

- Monitor-internal helper reached from the `CHRTBL`/`SUBTBL` dispatcher; not intended as a general-purpose API.

**See also:**

- [Move](#move-fe2c)
- [Verify](#verify-fe36)
- [A2L/A2H](#a2l-a2h)
- [A4L/A4H](#a4l-a4h)
- `A5L/A5H` ($44/$45)
