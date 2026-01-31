### XBASIC ($FEB0)

**Description:**

Monitor command handler that transfers control to the resident BASIC interpreter’s cold-start entry.

**Input:**

- Monitor internal state.

**Output:**

- Does not return to the Monitor in normal operation.

**Side Effects:**

- Enters BASIC cold start.

**Notes:**

- This routine is Monitor-internal and is typically reached via `Ctrl+B` in the Monitor command table on later firmware revisions (for example, IIc-family systems).

**See also:**

- [BASCONT](#bascont-feb3) — BASIC warm start/continue
- [MonZ](#monz-ff69)
