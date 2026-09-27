@echo off
rem Runs rust-analyzer from the rust-env pixi environment. Editors like Zed
rem find it on the PATH, and it finds cargo and the rest of the environment
"%USERPROFILE%\.pixi\bin\pixi.exe" run --manifest-path "%USERPROFILE%\.local\share\rust-env\pixi.toml" -- rust-analyzer %*
