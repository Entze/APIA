$fileNum = 1

while ($true) {
    try {
        Invoke-WebRequest http://localhost:8000/Thesis.pdf -O ".\Thesis_$fileNum.pdf"
        Copy-Item ".\Thesis_$fileNum.pdf" ".\Thesis_Word_$fileNum.pdf"
        Invoke-Item ".\Thesis_$fileNum.pdf"
        & 'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE' ".\Thesis_Word_$fileNum.pdf"
    } catch {
        Write-Host $_
    }
    Pause
    $fileNum++
}
