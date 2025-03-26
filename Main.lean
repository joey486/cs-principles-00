import Lean
import Std

-- Function to parse a floating-point number manually
def parseFloat (s : String) : Option Float :=
  match s.splitOn "." with
  | [intPart] => (intPart.toInt?).map Float.ofInt  -- No decimal part, convert to Float
  | [intPart, fracPart] =>
    match (intPart.toInt?, fracPart.toInt?) with
    | (some i, some f) =>
      let decimalFactor := Float.ofInt (10 ^ fracPart.length)  -- Convert decimal part
      some (Float.ofInt i + (Float.ofInt f / decimalFactor))
    | _ => none
  | _ => none

-- Function to format a Float by removing trailing zeros
def formatFloat (f : Float) : String :=
  let s := f.toString
  if s.contains '.' then
    let charList := s.toList
    let reversed := charList.reverse
    let dropped := reversed.dropWhile (λ c => c = '0')
    let trimmedList := dropped.reverse
    let trimmed := String.mk trimmedList
    if trimmed.endsWith "." then trimmed.dropRight 1 else trimmed
  else s

-- Function to process .vm files
def processVMFile (filePath : System.FilePath) (outputFile : System.FilePath) : IO (Float × Float) := do
  let content ← IO.FS.readFile filePath
  let lines := content.splitOn "\n"  -- Split the content into lines

  let mut totalBuy : Float := 0.0
  let mut totalCell : Float := 0.0
  let mut outputLines : List String := []

  for line in lines do
    let words := line.splitOn " "  -- Split the line into words
    match words with
    | "buy" :: productName :: amountStr :: priceStr :: _ =>
      match (amountStr.toInt?, parseFloat priceStr) with
      | (some amount, some price) =>
        let total := (Float.ofInt amount) * price
        totalBuy := totalBuy + total
        outputLines := outputLines ++ [s!"### BUY {productName} ###", s!"{formatFloat total}"]
      | _ => IO.println s!"Error: Invalid buy entry in line: {line}"

    | "cell" :: productName :: amountStr :: priceStr :: _ =>
      match (amountStr.toInt?, parseFloat priceStr) with
      | (some amount, some price) =>
        let total := (Float.ofInt amount) * price
        totalCell := totalCell + total
        outputLines := outputLines ++ [s!"$$$ CELL {productName} $$$", s!"{formatFloat total}"]
      | _ => IO.println s!"Error: Invalid sell entry in line: {line}"
    | _ => pure ()  -- Do nothing if the line doesn't match the pattern

  let existing ← IO.FS.readFile outputFile <|> pure ""
  let finalOutput := existing ++ String.intercalate "\n" outputLines ++ "\n"
  IO.FS.writeFile outputFile finalOutput

  return (totalBuy, totalCell)

-- Function to write VM files to an .asm file
def writeVMFilesToTar (dirPath : System.FilePath) : IO Unit := do
  let outputFile := dirPath / "Tar0.asm"
  IO.FS.writeFile outputFile "" -- Create file if it doesn't exist
  IO.println s!"Writing to {outputFile}..."
  let files ← System.FilePath.readDir dirPath
  let vmFiles := files.filter (·.path.extension == some "vm")  -- Filter .vm files

  let mut totalBuySum : Float := 0.0
  let mut totalCellSum : Float := 0.0

  -- Process each .vm file and append to the output file
  for file in vmFiles do
    let fileName := (file.path.fileName.getD "").dropRight 3  -- Remove .vm extension
    let existingContent ← IO.FS.readFile outputFile
    IO.FS.writeFile outputFile (existingContent ++ s!"{fileName}\n")
    let (totalBuy, totalCell) ← processVMFile file.path outputFile
    totalBuySum := totalBuySum + totalBuy
    totalCellSum := totalCellSum + totalCell

  -- Append totals
  let existing ← IO.FS.readFile outputFile
  let finalOutput := existing ++ s!"TOTAL BUY: {formatFloat totalBuySum}\nTOTAL CELL: {formatFloat totalCellSum}\n"
  IO.FS.writeFile outputFile finalOutput

  IO.println "Completed processing all .vm files."

def main : IO Unit := do
  (←IO.getStdout).putStrLn "Enter directory path:"
  let dirPath ← (←IO.getStdin).getLine
  let name := dirPath.dropRightWhile Char.isWhitespace
  writeVMFilesToTar name
