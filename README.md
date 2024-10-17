# FPGA Image Coding System using Chain Code Algorithm 📸

This project involves designing and implementing a digital system for image coding on an FPGA using the **chain code algorithm**. The system consists of an **encoder** and **decoder** module, with communication handled through a **UART module**.

## Overview 🌟

The **chain code algorithm** encodes the edges of objects in a binary image by assigning directional codes (up, down, left, right, and diagonals). This system reads a binary image, generates encoded vectors based on the edges, and reconstructs the original image using the decoded vectors.

### Project Highlights:

- **Encoder Module**: Converts binary images into vector representations using the chain code algorithm.
- **Decoder Module**: Reconstructs the original image from the encoded vectors.
- **UART Communication**: Ensures smooth data transfer between the encoder and decoder modules.

## System Architecture 🏗️

### 1. Encoder Module 🔄

The **Encoder Module** is responsible for converting a binary image into a vector format using the **chain code algorithm**. This module processes transitions between pixels along the boundary of objects, assigning directional codes to represent these transitions.

- **Technology**: Implemented in **Verilog**.
- **State Machine**: A state machine handles the encoding process, finding area, perimeter, and transmitting the vectors.
- **Functionality**:
  - Reads a binary image from memory.
  - Generates chain code vectors that represent the boundary of objects.
  - Transmits the encoded vectors to the decoder via the UART module.

### 2. Decoder Module 🔄

The **Decoder Module** decodes the received chain code vectors and reconstructs the original image. It receives the serial data from the encoder, updates pixel coordinates based on the codes, and stores the processed pixels in memory.

- **Functionality**:
  - Receives encoded data serially via UART.
  - Decodes chain codes to update pixel coordinates.
  - Outputs completion status and any potential errors.
  - Reconstructs and stores the original image in memory.

## Communication Protocol 📡

Communication between the **Encoder** and **Decoder** modules is done through a **UART (Universal Asynchronous Receiver-Transmitter)** protocol. The UART ensures a reliable and synchronized data transfer of the chain code vectors, maintaining data integrity.
