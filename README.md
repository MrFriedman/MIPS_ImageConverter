**Question 1: increase_brightness.asm**

# Increase Brightness MIPS Program

This MIPS assembly program, `increase_brightness.asm`, reads in a color PPM (Portable Pixmap) image, increases the RGB values of each pixel by 10, clamping them to a maximum value of 255 if needed, and saves the modified image to a new file. It also calculates and displays the average RGB values of both the original and modified images as double values on the console.

## Instructions:

1. Place the input color PPM image (P3 format) in the same directory as the MIPS program.
2. Rename the input image file to `input.ppm`.
3. Ensure you have a MIPS simulator or emulator (such as SPIM) installed on your system.
4. Assemble and run the MIPS program using your chosen simulator/emulator.

## Execution:

Upon running the program, it will perform the following steps:

1. Read the input image (`input.ppm`).
2. Increase the brightness of each pixel by 10 (clamped to a maximum of 255).
3. Save the modified image to a new file (`output.ppm`).
4. Calculate and display the average RGB values of the original and modified images on the console.

## Files:

- `increase_brightness.asm`: The MIPS assembly source code.
- `input.ppm`: Place your input color PPM image in this file.
- `output.ppm`: The modified image will be saved here.

---

**Question 2: greyscale.asm**

# Greyscale Conversion MIPS Program

This MIPS assembly program, `greyscale.asm`, reads in a color PPM (P3 format) image and converts it into a greyscale PPM (P2 format) image. The greyscale pixel values are calculated by finding the average of their RGB values and rounding them down to the nearest whole number. The program also updates the file type in the header of the new greyscale image to "P2."

## Instructions:

1. Place the input color PPM image (P3 format) in the same directory as the MIPS program.
2. Rename the input image file to `input.ppm`.
3. Ensure you have a MIPS simulator or emulator (such as SPIM) installed on your system.
4. Assemble and run the MIPS program using your chosen simulator/emulator.

## Execution:

Upon running the program, it will perform the following steps:

1. Read the input image (`input.ppm`).
2. Convert the image to greyscale using the described method.
3. Save the greyscale image to a new file (`output.ppm`) in P2 format.
4. Display a message indicating the conversion is complete.

## Files:

- `greyscale.asm`: The MIPS assembly source code.
- `input.ppm`: Place your input color PPM image (P3 format) in this file.
- `output.ppm`: The greyscale image (P2 format) will be saved here.

Feel free to adapt the file names and paths to your specific requirements.

In order to run the assigment make sure java is downloaded on your system, in a Mac system this should be installed already. If using a windoes system you can download java as follows:

1. Use the link (https://www.oracle.com/za/java/technologies/downloads/) or for the Java Development Kit (https://adoptopenjdk.net/releases.html)
2. Install JDK: Download the JDK and follow the set up wizzard.