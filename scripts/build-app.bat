@echo off
setlocal EnableExtensions
g++ -std=c++17 -municode -mwindows -o ./dist/nfc_renamer.exe ./src/normalize_nfc.cpp -lNormaliz -lole32 -luuid