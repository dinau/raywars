<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [RayWars : Star Wars-style opening crawl example program with Raylib](#raywars--star-wars-style-opening-crawl-example-program-with-raylib)
  - [Prerequisites](#prerequisites)
  - [Download Raylib library [Only for C, Nimony, Nelua, Zig]](#download-raylib-library-only-for-c-nimony-nelua-zig)
  - [Programs](#programs)
    - [C](#c)
    - [Nelua](#nelua)
    - [Nim](#nim)
    - [Nimony v0.2](#nimony-v02)
    - [Odin](#odin)
    - [Python](#python)
    - [Ruby](#ruby)
    - [Zig](#zig)
    - [LuaJIT (WIP)](#luajit-wip)
    - [C3 (WIP)](#c3-wip)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### RayWars : Star Wars-style opening crawl example program with Raylib


![alt](img/raywars_v0.2.gif)

#### Prerequisites

---

Install `gcc, make, MSys2 console / commands(cp, rm ...)`

#### Download Raylib library [Only for C, Nimony, Nelua, Zig]

---

1. ```sh
   cd your_work_dir
   git clone https://github.com/dinau/raywars
   ```

1. Download Raylib binary  
Windows: [raylib-5.5_win64_mingw-w64.zip](https://github.com/raysan5/raylib/releases/download/5.5/raylib-5.5_win64_mingw-w64.zip)  
Linux: [raylib-5.5_linux_amd64.tar.gz](https://github.com/raysan5/raylib/releases/download/5.5/raylib-5.5_linux_amd64.tar.gz))  
then extracts it.
1. Rename `raylib-5.5_win64_mingw-w64` to `raylib`  
 (for Linux: rename `raylib-5.5_linux_amd64` to `raylib`)
1. Copy raylib  
   - Windows:
   
      ```sh
      mkdir -p     libs/win
      cp -r raylib libs/win/  
      ```
   
   - Linux
   
      ```sh
      mkdir -p     libs/linux
      cp -r raylib libs/linux/  
      ```
   
1. Folder structure:
  
     ```sh
     your_work_dir
      |-- raywars
      |   `-- src
      |       |-- c
      |       |-- luajit
      |       snip
      | 
      `-- libs
          |-- win
          |   `-- raylib    <==
          `-- linux
              `-- raylib    <==
     ```

#### Programs

##### C  

---

```sh
pwd 
raywars/src/c
```

Windows / Linux  
Use gcc compiler 

   ```sh
   make run
   ```

#####  Nelua 

---

1. Install [MSys2/MinGW](https://www.msys2.org/) (Windows OS)
1. Install [NeLua](https://nelua.io/installing/)
1. Clone `Raylib.nelua` library  
[Raylib.nelua](https://github.com/AuzFox/Raylib.nelua): (git SHA-1: a91ad75074e126679adbe91ab369f4d62d1563b4)

   ```sh
   pwd
   your_work_dir/libs
   git clone https://github.com/AuzFox/Raylib.nelua
   ```

1. Folder structure:
  
     ```sh
     your_work_dir
      |-- raywars
      |   `-- src
      |       |-- c
      |       |-- luajit
      |       snip
      | 
      `-- libs
          |-- Raylib.nelua   <== For Nelua
          |-- win
          |   `-- raylib
          `-- linux
              `-- raylib
     ```

1. Building and runing

   ```sh
   pwd 
   raywars/src/nelua
   ```

   Windows / Linux  
   Use gcc compiler 

   (It should be built on MSys2 console on Windows)
   
      ```sh
      make run
      ```
   

#####  Nim 

---

Install [Nim-lang](https://nim-lang.org)

Windows: / Linux  
Use gcc compiler 

```sh
pwd 
raywars/src/nim

nimble install naylib
make run
```

#####  Nimony v0.2

---
[Nimony v0.2 (with Raylib sample)](https://nim-lang.github.io/nimony-website/version0_2.html) : [Manual](https://nim-lang.github.io/nimony-website/manual.html) /  [Github](https://github.com/nim-lang/nimony)

```sh
pwd 
raywars/src/nimony
```

Windows: / Linux  
Use gcc compiler 

(It should be built on MSys2 console on Windows)
   
   ```sh
   make nim
   ```

#####  Odin

---

[Install Odin](https://odin-lang.org/docs/install/)  
Using [odin version dev-2025-11 (-nightly:e5153a9)](https://github.com/odin-lang/Odin/releases)

- For Windows OS
   1. Download [raylib-5.5_win64_msvc16.zip](https://github.com/raysan5/raylib/releases/download/5.5/raylib-5.5_win64_msvc16.zip) then extracts it.
   1. Rename `raylib-5.5_win64_msvc16` folder to `raylib_msvc`  
   1. Copy raylib to `libs` folder  
      
      ```sh
      pwd
      your_work_dir
      mkdir -p          libs/win
      cp -r raylib_msvc libs/win/  
      ```
      
   1. Folder structure:
     
        ```sh
        your_work_dir
         |-- raywars
         |   `-- src
         |       |-- c
         |       |-- c3
         |       snip
         | 
         `-- libs
             |-- win
             |   |-- raylib    
             |   `-- raylib_msvc    <== for Odin
             `-- linux
                 `-- raylib   
        ```

Windows / Linux

```sh
make run
```


#####  Python 

---
- Windows :  Python 3.14.0
- Linux: Debian / Ubuntu : Python 3.13.5

   ```sh
   sudo apt install python3-pip
   ```

```sh
pip install raylib==5.5.0.3 --break-system-packages
```

(https://github.com/electronstudio/raylib-python-cffi)

```sh
pwd 
raywars/src/python

python raywars.py
or
python3 raywars.py
```

#####  Ruby 

---
For Windows install [Ruby installer](https://rubyinstaller.org/downloads/):  Ruby 3.4.7 

```sh
pwd 
raywars/src/ruby

gem install raylib-bingings
ruby raywars.rb             # or double click raywars.rbw on Windows
```

##### Zig

---

[zig-0.15.2](https://ziglang.org/download/):  
- Windows: [zig-x86_64-windows-0.15.2.zip](https://ziglang.org/download/0.15.2/zig-x86_64-windows-0.15.2.zip)
- Linux:   [zig-x86_64-linux-0.15.2.tar.xz](https://ziglang.org/download/0.15.2/zig-x86_64-linux-0.15.2.tar.xz)

```sh
pwd 
raywars/src/zig
```

- Windows / Linux

   ```sh
   make run
   ```

#####  LuaJIT (WIP)

---

raywars.lua


#####  C3 (WIP)

---
