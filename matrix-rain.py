#!/usr/bin/env python3
"""🟢 Animated Matrix Rain Terminal Animation"""

import curses
import random
import time


def main(stdscr):
    # Setup
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(0)

    # Initialize colors
    curses.start_color()
    curses.use_default_colors()
    for i in range(1, 10):
        curses.init_pair(i, curses.COLOR_GREEN, -1)

    # Matrix characters (katakana + latin + numbers)
    chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Get terminal dimensions
    height, width = stdscr.getmaxyx()

    # Create columns with random positions, speeds, and brightness
    columns = []
    for x in range(width):
        speed = random.uniform(0.3, 1.5)
        y_start = random.randint(-height, 0)
        length = random.randint(5, 25)
        columns.append({
            'x': x,
            'y': y_start,
            'speed': speed,
            'length': length,
            'trail': [random.choice(chars) for _ in range(30)]
        })

    frame = 0
    while True:
        stdscr.erase()
        height, width = stdscr.getmaxyx()

        # Handle resize
        if height == 0 or width == 0:
            continue

        key = stdscr.getch()
        if key == ord('q'):
            break

        for col in columns:
            # Mutate characters randomly
            if random.random() < 0.05:
                idx = random.randint(0, len(col['trail']) - 1)
                col['trail'][idx] = random.choice(chars)

            # Draw the trail
            for i in range(col['length']):
                y = int(col['y']) - i
                x = col['x']

                if 0 <= y < height and 0 <= x < width:
                    char = col['trail'][i % len(col['trail'])]
                    if i == 0:
                        # Head of the trail (bright white-green)
                        try:
                            stdscr.addstr(y, x, char, curses.color_pair(1) | curses.A_BOLD)
                        except curses.error:
                            pass
                    else:
                        # Fade out
                        brightness = max(1, 9 - int(i * 9 / col['length']))
                        try:
                            stdscr.addstr(y, x, char, curses.color_pair(brightness))
                        except curses.error:
                            pass

            # Move the column down
            col['y'] += col['speed']

            # Reset when it goes off screen
            if int(col['y']) - col['length'] > height:
                col['y'] = random.randint(-10, 0)
                col['length'] = random.randint(5, 25)
                col['speed'] = random.uniform(0.3, 1.5)

        stdscr.refresh()
        frame += 1
        time.sleep(0.05)


if __name__ == "__main__":
    curses.wrapper(main)
