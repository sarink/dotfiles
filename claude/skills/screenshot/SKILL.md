---
name: screenshot
description: Capture the user's screen (every display) and look at it. Use when the user runs /screenshot.
disable-model-invocation: true
allowed-tools: Bash(screencapture *), Bash(sips *), Bash(rm -rf /tmp/claude-screenshot*), Read
---

# Screenshot

The user ran `/screenshot` to show you what's on their screen. Arguments: `$ARGUMENTS`

1. If the arguments start with a number (e.g. `/screenshot 5 why is this red?`),
   that's a delay in seconds so they can switch windows; use it as `-T <n>`.
   Otherwise no delay.

2. Capture every display (macOS writes one file per connected display, so
   unused names are simply not created), then shrink each to 1600px on its
   long side so it's cheap to read:

   ```sh
   d=/tmp/claude-screenshot && rm -rf $d && mkdir -p $d && screencapture -x [-T <n>] $d/1.png $d/2.png $d/3.png $d/4.png && sips -Z 1600 $d/*.png >/dev/null && ls $d
   ```

3. `Read` every PNG that `ls` printed. That's what puts the screenshot in
   front of you.

4. Respond to what's on screen. If the remaining arguments ask a question or
   give an instruction, do that. If there are none, carry on with whatever the
   conversation was about, using the screenshot as context; if nothing is in
   progress, briefly say what you see and ask what they want.

If the image is only wallpaper and no windows, the terminal app lacks Screen
Recording permission: tell the user to enable it in System Settings → Privacy &
Security → Screen & System Audio Recording, then restart the terminal.
