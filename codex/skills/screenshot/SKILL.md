---
name: screenshot
description: Capture and inspect the user's macOS displays when explicitly invoked with $screenshot, optionally after a delay.
---

# Screenshot

The user invoked `$screenshot` to show you their screen.

1. If the text following the invocation starts with a nonnegative integer
   (for example, `$screenshot 5 why is this red?`), use it as the delay in
   seconds. Otherwise use zero. Treat the remaining text as the user's request.

2. Use the shell tool to capture the displays and shrink each image to 1600px
   on its long side. Set `delay_seconds` to the parsed integer; do not interpolate
   the remaining user text into the command. Use a fresh temporary directory:

   ```sh
   delay_seconds=0
   capture_dir=$(mktemp -d /tmp/codex-screenshot.XXXXXX) &&
     screencapture -x -T "$delay_seconds" "$capture_dir/1.png" "$capture_dir/2.png" "$capture_dir/3.png" "$capture_dir/4.png" &&
     sips -Z 1600 "$capture_dir"/*.png >/dev/null &&
     ls "$capture_dir"/*.png
   ```

   macOS writes one file per display; unused filenames are not created.
   The example accommodates four displays. Supply additional output filenames
   if the user has more. Wait for capture to finish before opening the images.

3. Open every resulting PNG with Codex's `view_image` tool using its absolute
   path. A text read of the file does not display it.

4. Respond to the question or instruction supplied with the invocation. Without
   one, use the screenshot as context for the active task. If no task is active,
   briefly describe what you see and ask what the user wants.

If capture fails or expected windows are missing, report the result. A wallpaper-only
image may indicate missing Screen Recording permission. Suggest checking
System Settings → Privacy & Security → Screen & System Audio Recording for the
app running Codex (Codex or the terminal), and restarting it after granting access.
Do not assume wallpaper alone proves a permission problem.
