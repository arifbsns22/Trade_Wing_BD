Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("C:\Users\mohos\OneDrive\Desktop\trade_wign_bd\assets\logos\app_logo.png")
$bmp = New-Object System.Drawing.Bitmap 300, 300
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($img, 0, 0, 300, 300)
$bmp.Save("C:\Users\mohos\OneDrive\Desktop\trade_wign_bd\assets\logos\app_logo_resized.png", [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
$bmp.Dispose()
$g.Dispose()
