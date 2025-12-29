import cv2
import numpy as np
import math


def create_breathing_animation(
    image_path, output_name="home_hero.mp4", duration_sec=4, fps=30
):
    # Use IMREAD_UNCHANGED to preserve transparency if it's a PNG
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        print(f"Error: Could not find image at {image_path}")
        return

    height, width = img.shape[:2]

    # Accessing fourcc via the VideoWriter class to satisfy linters
    fourcc = cv2.VideoWriter.fourcc(*"mp4v")
    out = cv2.VideoWriter(output_name, fourcc, fps, (width, height))

    total_frames = duration_sec * fps

    for i in range(total_frames):
        # Subtle scale: 1.0 to 1.015 (1.5% growth)
        # We use a cosine wave so it starts and ends at the same point (loops perfectly)
        scale = 1.0 + 0.0075 * (1 - math.cos(2 * math.pi * i / total_frames))

        # Scale from the center (approx chest level for a standing pose)
        center_x, center_y = width / 2, height / 2
        M = cv2.getRotationMatrix2D((center_x, center_y), 0, scale)

        # BORDER_CONSTANT with value 0 ensures transparent/black edges don't smear
        frame = cv2.warpAffine(
            img,
            M,
            (width, height),
            borderMode=cv2.BORDER_CONSTANT,
            borderValue=(0, 0, 0, 0),
        )

        # VideoWriter doesn't support alpha, so we drop it for the mp4
        if frame.shape[2] == 4:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGRA2BGR)

        out.write(frame)

    out.release()
    print(f"Success! Created {output_name}")


if __name__ == "__main__":
    create_breathing_animation("input_image.png")
