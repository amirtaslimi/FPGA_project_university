from PIL import Image
import numpy as np

def text_to_image(input_path, output_path, width, height):
    # Read the text file
    with open(input_path, 'r') as file:
        # Read lines from the text file
        lines = file.readlines()

        # Concatenate lines to form a single string
        binary_string = ''.join(lines)

        # Convert the binary string to a numpy array of integers
        pixels = [int(not(int(bit))) for bit in binary_string if bit in ('0', '1')]
        pixels = np.array(pixels)

        # Reshape the 1D array to a 2D array based on the specified width and height
        pixels = pixels[:width * height]
        pixels = pixels.reshape((height, width))

        # Convert the 2D array to a Pillow image
        image = Image.fromarray((pixels * 255).astype(np.uint8), mode='L')

        # Save the image
        image.save(output_path)

if __name__ == "__main__":
    # Replace 'output_text_opencv.txt' with the path to your text file
    input_text_path = 'Pic 2_64 Pix_text.txt'

    # Replace 'output_image.png' with the desired output image file path
    output_image_path = 'output_image_2.png'

    # Replace with the width and height of the original image
    image_width = 64
    image_height = 64

    text_to_image(input_text_path, output_image_path, image_width, image_height)
