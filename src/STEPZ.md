### StepZ ($FE71)

**Description:**

Monitor command handler for single-step execution.

**Input:**

- **Registers / Memory:** Monitor parser state (not intended as a general-purpose API).

**Output:**

- Hardware/firmware dependent.

**Side Effects:**

- Hardware/firmware dependent.

**Notes:**

- On Apple II/II+ firmware, `STEPZ` is at $FEC4 and participates in step execution (often after optionally copying a specified address into the program counter via [A1PC](#a1pc-fe75)).
- On some later systems (e.g., unenhanced IIe), the historical trace/step entry points exist but return immediately.
- On the IIc 32KB firmware family, the step handler appears at $FE71.

**See also:**

- [Trace](#trace-fe6f)
- [A1PC](#a1pc-fe75)
- [Go](#go-feb6)
