from PIL import Image

def image_to_text(image_path, output_path):
    # Open the image
    image = Image.open(image_path)

    # Convert the image to black and white (1-bit pixel)
    image = image.convert("1")

    # Get the pixel values
    pixels = list(image.getdata())

    # Create a text file and write pixel values as zeros and ones
    with open(output_path, 'w') as file:
        for i, pixel in enumerate(pixels):
            # Write '1' if pixel is black, '0' if white
            file.write('1' if pixel == 0 else '0')

            # Add a newline character after every width of the image
            if (i + 1) % image.width == 0:
                file.write('\n')

if __name__ == "__main__":
    # Replace 'input_image.png' with the path to your black and white image
    input_image_path = 'Pic1.jpg'

    # Replace 'output_text.txt' with the desired output text file path
    output_text_path = 'Pic 1_64 Pix_text.txt'

    image_to_text(input_image_path, output_text_path)
