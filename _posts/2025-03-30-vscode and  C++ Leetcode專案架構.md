---
tags:
  - C++
title: vscode and C++ Leetcode專案架構
created: 2025-03-30T12:00:00
modified: 2025-03-30T12:00:00
---
C++ 的 workflow 要照顧的細節滿多  

個人寫Leetcode時 很多檔案需要手動加入不是很方便  

找到以下各種方法幫助開發時更加方便與自動化  

## fedora安裝c++

1. 安裝 GCC C++ 編譯器（g++）

開啟終端機，輸入：
```bash
sudo dnf install gcc-c++
```


這將會安裝：

    g++（GCC C++ 編譯器）

    libstdc++（標準 C++ 函式庫）

確認安裝成功：



```bash
g++ --version
```

## windows安裝c++

```powershell
#預設會安裝 Ubuntu 子系統
wsl --install
```
wsl -l -v 確認版本，建議使用 WSL 2  
```bash
sudo apt install g++

sudo apt install cmake gdb
```

確認vscode 有裝 wsl的plugin  
```bash
wsl -d ubuntu #進入子系統
#進入目錄後
code . #即可以開啟vscode
```


2. 安裝 C++ 開發工具（可選）

如果你需要完整的開發環境，包括 make、cmake、gdb（除錯器）等，可以安裝以下套件：
```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install cmake gdb
```

---
## 專案目錄結構++
```lua
C_plus
│── problems
│   ├── mergeSort
│   │   ├── solution.cpp
│   │   ├── solution.hpp
│   │ ── ── common.hpp(共用的hpp)
│── .vscode
│   │── launch.json
│   │── task.json
│── main.cpp  (進入點)
│── generate_problems_hpp.sh(寫入problems.hpp的shell)
│── Makefile
│── problems.hpp (在main include)
```

目前的技術總結

1️⃣ Makefile 基礎

    使用 Makefile 作為 build system

    熟悉了 target, dependency, recipe 的結構

    正確管理 .cpp, .o, .d 等中間與最終檔案

```makefile
# ===== Compiler =====

CXX = g++

# ===== Default Mode =====

MODE ?= debug

# ===== Flags 根據 Mode 切換 =====

ifeq ($(MODE),debug)

    CXXFLAGS = -Wall -Wextra -O0 -g -std=c++17 -MMD -MP

    TARGET = main_debug

else ifeq ($(MODE),release)

    CXXFLAGS = -Wall -Wextra -O2 -std=c++17 -MMD -MP

    TARGET = main_release

else

    $(error MODE 必須是 debug 或 release)

endif

# ===== Auto Generate =====

PROBLEMS_HEADER = problems.hpp

GEN_SCRIPT = ./generate_problems_hpp.sh

# ===== Source =====

SRC = main.cpp $(wildcard problems/*/solution.cpp)

OBJ = $(SRC:.cpp=.o)

DEP = $(OBJ:.o=.d)

# ===== Build Rules =====

all: $(PROBLEMS_HEADER) $(TARGET)

# 自動生成 problems.hpp

$(PROBLEMS_HEADER):

    $(GEN_SCRIPT)

# link

$(TARGET): $(OBJ)

    $(CXX) $(OBJ) -o $@

# build object

%.o: %.cpp

    $(CXX) $(CXXFLAGS) -c $< -o $@

# 自動依賴

-include $(DEP)

# ===== Extra Targets =====

clean:
    rm -f $(OBJ) $(DEP) main_debug main_release $(PROBLEMS_HEADER)

rebuild:

    $(MAKE) clean

    $(MAKE) MODE=$(MODE)
```
2️⃣ Wildcard + Pattern Matching
```makefile
SRC = main.cpp $(wildcard problems/*/solution.cpp)
OBJ = $(SRC:.cpp=.o)
DEP = $(OBJ:.o=.d)

```

    自動收集子目錄內的 source files

    自動推導出 object files (.o)

    自動推導出 dependency files (.d)

這等於已經進入了 半自動化建構 的層級。  
3️⃣ 自動 header 聚合器（Header Aggregator）

    自己寫了一個簡單的 Shell Script

generate_problems_hpp.sh
```shell
#!/bin/bash

OUTFILE="problems.hpp"
echo "// Auto-generated file. DO NOT EDIT." > $OUTFILE
echo "#pragma once" >> $OUTFILE
echo "" >> $OUTFILE

for header in $(find problems -name "solution.hpp" | sort); do
    echo "#include \"$header\"" >> $OUTFILE
done

echo "[OK] problems.hpp generated"

```

功能：

    自動掃描 problems/*/solution.hpp

    生成 problems.hpp 作為 集中 include header

    避免手動 include，減少 human error

這是很多競賽系統、OJ（Online Judge）會用的技術。  
4️⃣ Makefile + Script Integration


```makefile
$(PROBLEMS_HEADER):
	$(GEN_SCRIPT)
```
    Makefile 自動呼叫你的 shell script

    保證每次 build 時都會生成最新的 problems.hpp

5️⃣ Dependency Generation（自動依賴管理）
```makefile
CXXFLAGS = -MMD -MP
-include $(DEP)

```


    自動追蹤 .hpp 相依

    修改 header 時，會自動觸發正確的 recompile

    這是 職業 C++ 工程師日常必備  

6️⃣ Debug / Release 可擴充的架構  

雖然你還沒 fully 實作，但其實你已經準備好了：

    rebuild: target

    CXXFLAGS 隨時可以改成 debug / release

    VSCode 配置也已經接上 Makefile build

7️⃣ VSCode Integration

    tasks.json：透過 Makefile 完成 build task

    launch.json：正確用 GDB debug

    preLaunchTask：保證 debug 時會先自動 build

    自訂的 debugger 設定：symbol printing、working directory、gdb mode

launch.json：
```json
{

    "version": "0.2.0",

    "configurations": [

        {

            "name": "Debug LeetCode Solutions",

            "type": "cppdbg",

            "request": "launch",

            "program": "${workspaceFolder}/main_debug",

            "args": [],

            "stopAtEntry": false,

            "cwd": "${workspaceFolder}",

            "environment": [],

            "externalConsole": false,

            "MIMode": "gdb",

            "preLaunchTask": "Build (Debug)",

            "setupCommands": [

                {

                    "description": "Enable pretty-printing",

                    "text": "-enable-pretty-printing",

                    "ignoreFailures": true

                }

            ]

        }

    ]

}

```
tasks.json：
```json
{

    "version": "2.0.0",
    "tasks": [

        {
            "label": "Build (Debug)",

            "type": "shell",

            "command": "make MODE=debug",

            "group": {
                "kind": "build",
                "isDefault": true
            },

            "problemMatcher": ["$gcc"]

        },

        {

            "label": "Build (Release)",

            "type": "shell",

            "command": "make MODE=release",

            "group": "build",

            "problemMatcher": ["$gcc"]

        }
    ]
}
```
8️⃣ GDB Debugger

    成功讓 GDB 能正確辨識 symbol

    已經能設 breakpoint，進行 step-by-step debug

✅ 如果簡單一句話形容：

    你已經構建了一套 具有自動相依、集中管理、自動 build、自動 debug 的 mini build system

## ⭐ 技術關鍵字整理：

- Makefile
    
- GCC / G++
    
- Dependency generation (`-MMD -MP`)
    
- Header aggregation
    
- Shell Script automation
    
- Wildcard file pattern
    
- VSCode tasks & launch integration
    
- GDB debug integration
    
- Debug symbol control (`-g`)

## 執行
因已在Makefile加入指令,  若有更動, 執行make rebuild  

等同於make clean && make  

然後F5即可運行
