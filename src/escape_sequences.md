### <a id="escape-sequences-with-rdchar"></a>Table: Escape sequences with RdChar

| Escape Code             | Function                                                     |
| :---------------------- | :----------------------------------------------------------- |
| ␛⃣ - @⃣                   | Clears the current window, homes the cursor (moves it to the upper-left corner of the screen), and exits escape mode. |
| ␛⃣ - A⃣ or ␛⃣ - a⃣       | Moves the cursor right one character position and exits escape mode. |
| ␛⃣ - B⃣ or ␛⃣ - b⃣       | Moves the cursor left one character position and exits escape mode. |
| ␛⃣ - C⃣ or ␛⃣ - c⃣       | Moves the cursor down one line and exits escape mode.        |
| ␛⃣ - D⃣ or ␛⃣ - d⃣       | Moves the cursor up one line and exits escape mode.          |
| ␛⃣ - E⃣ or ␛⃣ - e⃣       | Clears the current line from the cursor position to the end, then exits escape mode. |
| ␛⃣ - F⃣ or ␛⃣ - f⃣       | Clears the current window from the cursor position to the bottom, then exits escape mode. |
| ␛⃣ - I⃣ or ␛⃣ - i⃣ or ␛⃣ - ↑⃣ | Moves the cursor up one line and remains in escape mode.     |
| ␛⃣ - J⃣ or ␛⃣ - j⃣ or ␛⃣ - ←⃣ | Moves the cursor left one character position and remains in escape mode. |
| ␛⃣ - K⃣ or ␛⃣ - k⃣ or ␛⃣ - →⃣ | Moves the cursor right one character position and remains in escape mode. |
| ␛⃣ - M⃣ or ␛⃣ - m⃣ or ␛⃣ - ↓⃣ | Moves the cursor down one line and remains in escape mode.   |
| ␛⃣ - 4⃣                  | Switches to 40-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ - 8⃣                  | Switches to 80-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ - Control - D⃣       | Disables control characters, allowing only carriage return, linefeed, bell, and backspace to have an effect when printed. |
| ␛⃣ - Control - E⃣       | Reactivates control characters.                              |
| ␛⃣ - Control - Q⃣       | Deactivates the enhanced video firmware, sets the input/output links to `KeyIn` and `COut1`, restores the normal window size and then exits escape mode. |

*Note: The commands Esc - 4⃣, Esc - 8⃣, and Esc - Control - Q⃣ only function when enhanced video firmware is active.*