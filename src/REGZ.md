### REGZ ($FEBF)

**Description:**

Monitor command handler that transfers control to the register-display logic.

**Input:**

- **Registers:** A/X/Y undefined.
- **Memory:** Uses the saved-register locations documented under [Save](#save-ff4a) / [Restore](#restore-ff3f).

**Output:**

- Does not return directly to the caller (control returns to the Monitor through the Monitor’s normal flow).

**Side Effects:**

- Displays register state using [RegDsp](#regdsp-fad7).

**Notes:**

- This is typically reached via the Monitor’s command dispatcher tables ([CHRTBL](#chrtbl-ffcc)/[SUBTBL](#subtbl-ffe3)).

**See also:**

- [RegDsp](#regdsp-fad7)
- [Save](#save-ff4a)
- [Restore](#restore-ff3f)
- [MonZ](#monz-ff69)
