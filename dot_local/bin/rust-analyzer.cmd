@echo off
rem Runs rust-analyzer from the rust-env pixi environment. Editors like Zed
rem find this on the PATH, and rust-analyzer then finds cargo and everything
rem else in the environment
"%USERPROFILE%\.pixi\bin\pixi.exe" run --manifest-path "%USERPROFILE%\.local\share\rust-env\pixi.toml" -- rust-analyzer %*
