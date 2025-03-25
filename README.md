# Lean VM File Processor

## Overview
This Lean project provides functionality to parse and process `.vm` files, extract transaction data (buy/sell operations), and summarize financial information. The processed data is written into an output `.asm` file.

## Features
- **Parses `.vm` files** containing buy and sell transactions.
- **Computes total buy and sell values** from the transactions.
- **Writes processed data** into an output file `Tar0.asm`.
- **Handles invalid data gracefully** by printing error messages.

## Installation & Requirements
- **Lean 4**
- **Std Library**
- Ensure the Lean environment is set up properly.

## Usage
### 1. Parsing Floating-Point Numbers
The `parseFloat` function converts a string representing a floating-point number into an `Option Float`.

```lean
def parseFloat (s : String) : Option Float
```
- Example: `parseFloat "12.34"` → `some 12.34`

### 2. Processing `.vm` Files
The `processVMFile` function reads a `.vm` file, extracts `buy` and `sell` transactions, and writes the formatted data to an output file.

```lean
def processVMFile (filePath : System.FilePath) (outputFile : System.FilePath) : IO (Float × Float)
```
- Example `.vm` file content:
  ```
  buy apple 10 2.5
  cell banana 5 1.2
  ```
- Output format:
  ```
  ### BUY apple ###
  25.0
  $$$ CELL banana $$$
  6.0
  ```
- Returns total buy and sell values.

### 3. Writing `.vm` Data to an `.asm` File
The `writeVMFilesToTar` function processes all `.vm` files in a directory and appends their data to `Tar0.asm`.

```lean
def writeVMFilesToTar (dirPath : System.FilePath) : IO Unit
```
- It computes total buy and sell values across all files and appends them to the output.
- Example output at the end of `Tar0.asm`:
  ```
  TOTAL BUY: 100.0
  TOTAL CELL: 50.0
  ```

### 4. Running the Script
To execute, evaluate:
```lean
#eval writeVMFilesToTar "./tar0"
```

## Error Handling
- If an invalid transaction entry is found, an error message is printed:
  ```
  Error: Invalid buy entry in line: buy apple X 2.5
  ```

## License
This project is not open-source 

## Authors
Yossef Heifetz - 216175398
Yakir Mauda - 