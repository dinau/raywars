<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [RayWars : Star Wars-style opening crawl example program with Raylib](#raywars--star-wars-style-opening-crawl-example-program-with-raylib)
  - [Prerequisites](#prerequisites)
  - [Download Raylib library [Only for C, Nimony, Nelua, Zig]](#download-raylib-library-only-for-c-nimony-nelua-zig)
  - [Programs](#programs)
    - [C](#c)
    - [C3](#c3)
    - [Go](#go)
    - [Nelua](#nelua)
    - [Nim](#nim)
    - [Nimony v0.2](#nimony-v02)
    - [Node.js / JavaScript](#nodejs--javascript)
    - [Odin](#odin)
    - [Lazarus / Pascal](#lazarus--pascal)
    - [Python](#python)
    - [Ruby](#ruby)
    - [Zig](#zig)
  - [Credit](#credit)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### RayWars : Star Wars-style opening crawl example program with Raylib


**"May the Raylib be with you."**

![alt](img/raywars_v0.2.gif)

#### Prerequisites

---

Install `gcc, make, MSys2 console / commands(cp, rm ...)`

Currently using Raylib v5.5 

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
   - Windows
   
      ```sh
      mkdir -p     libs/windows
      cp -r raylib libs/windows/  
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
      |       |-- c3
      |       snip
      | 
      `-- libs
          |-- windows
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

#####  C3 

---

C3 Compiler Version:       0.7.7

[Install C3lang](https://c3-lang.org/getting-started/prebuilt-binaries/)


Windows / Linux

```sh
pwd
raywars/src/c3

c3c vendor-fetch raylib55
make run
```

- https://github.com/tekin-tontu/c3-raylib-examples
- https://github.com/pherrymason/c3-lsp
- https://c3-lang.org/language-overview/examples/
- https://github.com/c3lang/vendor/tree/main/libraries

##### Go

---

go 1.25.5

```sh
pwd 
raywars/src/go
```

windows

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
          |-- windows
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

Windows / Linux  
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

Windows / Linux  
Use gcc compiler 

(It should be built on MSys2 console on Windows)
   
   ```sh
   make nim
   ```

#####  Node.js / JavaScript

---

Install [Node.js](https://nodejs.org)  (v22.16.0)  
Using [node-raylib](https://github.com/RobLoach/node-raylib)  
Windows / Linux  

```sh
pwd 
raywars/src/nodejs

npm install 
make       # or npm start
```

or double click `raywars.vbs` on Windows 

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
      mkdir -p          libs/windows
      cp -r raylib_msvc libs/windows/  
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
             |-- windows
             |   |-- raylib    
             |   `-- raylib_msvc    <== for Odin
             `-- linux
                 `-- raylib   
        ```

Windows / Linux

```sh
make run
```

#####  Lazarus / Pascal 

---

Prerequisites:  
[Lazarus IDE](https://www.lazarus-ide.org/) and FPC 3.3.1 or newer  
[ray4laz package](https://github.com/GuvaCode/ray4laz) installed in Lazarus  

Thank you for P.R. [@GuvaCode](https://github.com/GuvaCode).

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

python raywars.py      # or python3 raywars.py
```

#####  Ruby 

---
For Windows install [Ruby installer](https://rubyinstaller.org/downloads/):  Ruby 3.4.7  
Linux: Ruby 3.3.8 

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

Windows / Linux

   ```sh
   make run
   ```

#### Credit

---

- Music  
./resources/Classicals.de - Strauss, Richard - Also sprach Zarathustra, Op.30

   ```sh
   "Also sprach Zarathustra, Op.30"
   Provided by Classicals.de
   Conducted by Philip Milman (https://pmmusic.pro/)
   Licensed under CC BY 3.0
   https://www.classicals.de
   ```
