---
tags:
  - C++
title: vscode+C++ 專案架構
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
# ===== Compiler & Flags =====
CXX = g++
CXXFLAGS = -Wall -Wextra -O2 -g -std=c++17 -MMD -MP

# ===== Auto Generate =====
PROBLEMS_HEADER = problems.hpp
GEN_SCRIPT = ./generate_problems_hpp.sh

# ===== Source =====
SRC = main.cpp $(wildcard problems/*/solution.cpp)
OBJ = $(SRC:.cpp=.o)
DEP = $(OBJ:.o=.d)

TARGET = main

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

clean:
	rm -f $(OBJ) $(DEP) $(TARGET) $(PROBLEMS_HEADER)

rebuild:
	$(MAKE) clean
	$(MAKE) all

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
            "program": "${workspaceFolder}/main",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "Build with Makefile"
        }
    ]
}

```
tasks.json：
```json
{
    "tasks": [
        {
            "label": "Build with Makefile",
            "type": "shell",
            "command": "make",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["$gcc"],
            "detail": "Use Makefile to compile all C++ solutions"
        }
    ],
    "version": "2.0.0"
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
因已在Makefile加入判斷,  若有更動, 執行make rebuild  

等同於make clean && make  

然後F5即可運行
