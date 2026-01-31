### Trace ($FE6F)

**Description:**

Monitor command handler for trace-mode control.

**Input:**

- **Registers / Memory:** Monitor parser state (not intended as a general-purpose API).

**Output:**

- Hardware/firmware dependent.

**Side Effects:**

- Hardware/firmware dependent.

**Notes:**

- On Apple II/II+ firmware, `TRACE` is at $FEC2 and participates in step/trace execution.
- On some later systems (e.g., unenhanced IIe), the historical trace/step entry points exist but return immediately.
- On the IIc 32KB firmware family, the trace handler appears at $FE6F and is paired with [StepZ](#stepz-fe71).

**See also:**

- [StepZ](#stepz-fe71)
- [MonZ](#monz-ff69)
