$process = Get-Process -Id $pid
$process.PriorityClass = 'BelowNormal' 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Important Files" "E:\Important Files"
cd "E:\Important Files"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Portable Apps" "E:\Portable Apps"
cd "E:\Portable Apps"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\ProgramData" "E:\ProgramData"
cd "E:\ProgramData"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Users" "E:\Users"
cd "E:\Users"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Programs" "E:\Programs"
cd "E:\Programs"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Program Files" "E:\Program Files"
cd "E:\Program Files"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "C:\Program Files (x86)" "E:\Program Files (x86)"
cd "E:\Program Files (x86)"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
robocopy /MIR /XJ /R:1 /W:0 /J /XJ /A-:SH /NFL /NDL /NP "D:\Data" "E:\Data"
cd "E:\Data"
Get-ChildItem -Recurse -File | Where-Object { $_.Name -NotLike "*.7z" -and $_.Name -NotLike "*.zip" -and $_.Name -NotLike "*.rar" -and $_.Name -NotLike "*.gz" } |  ForEach-Object { compact /C /I /F /Q /EXE:LZX $_.Fullname }
Get-ChildItem -Recurse -Directory | ForEach-Object { compact /C /I /F /Q $_.Fullname }
