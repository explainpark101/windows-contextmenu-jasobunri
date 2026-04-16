@echo off
setlocal EnableExtensions
g++ -std=c++17 -municode -mwindows -o nfc_renamer.exe normalize_nfc.cpp -lNormaliz -lole32 -luuid