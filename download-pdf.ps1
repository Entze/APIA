while ($true) {
    try {
        Invoke-WebRequest http://localhost:8000/Thesis.pdf -O Thesis.pdf
        Invoke-Item .\Thesis.pdf
    } catch {
        Write-Host $_
    }
    Pause
}
