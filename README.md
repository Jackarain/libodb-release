# ODB 编译器及运行时库自包含部署指南（GCC 14.3.0 / build2 0.18.1）

**文档类型**：技术部署文档  
**工具版本**：build2 v0.18.1，ODB v14.3.0（stable 仓库）  
**编译器**：GCC 14.3.0（完整工具链嵌入）  

---

## 文档目的

本指南详细说明如何在 Linux 环境下，使用 build2 工具链从源码编译安装：

- **ODB 编译器**（`odb` 及插件 `odb.so`）——安装到 `/root/odb-14.3.0`，并**嵌入完整 GCC 14.3.0 工具链**，实现**自包含**（脱离宿主机 GCC 环境独立运行）。
- **ODB 运行时库**（`libodb`、`libodb-sqlite`、`libodb-pgsql`、`libodb-boost`）——安装到 `/root/libodb-14.3.0`，供项目开发链接。

所有组件均采用 **静态链接**（`libgcc`、`libstdc++`）并启用 `-fPIC`，以便后续集成到动态库中。

---

## 1. 环境与路径约定

- **构建工作目录**：`/root/odb-build`（所有源码和构建配置存放于此）
- **GCC 14.3.0 原始安装路径**：本文假设为 `/root/lib/x86_64-linux-gnu`（包含 `bin/`、`lib/`、`libexec/`、`include/` 等子目录）。**请根据实际环境替换。**
- **安装目标目录**：
  - ODB 编译器 → `/root/odb-14.3.0`
  - ODB 运行时库 → `/root/libodb-14.3.0`
- **build2 工具**（`b`、`bpkg`、`bdep`、`bx`）将安装到 `/usr/local/bin`（需要 `sudo` 权限）。

> ⚠️ **重要**：如果 GCC 安装路径不是上述路径，请将所有相关命令中的路径替换为实际路径，并保持一致性。

---

## 2. 步骤一：安装 build2 构建系统

```bash
# 创建临时目录并下载安装脚本
mkdir -p ~/build2-build
cd ~/build2-build

curl -sSfO https://download.build2.org/0.18.1/build2-install-0.18.1.sh

# （可选）验证校验和
shasum -a 256 -b build2-install-0.18.1.sh

# 执行安装（默认安装到 /usr/local，需 sudo）
sh build2-install-0.18.1.sh
```

安装完成后，`b`、`bpkg`、`bdep`、`bx` 命令即生效，可通过 `bpkg --version` 验证。

---

## 3. 步骤二：编译安装 ODB 编译器（含 GCC 嵌入）

### 3.1 创建构建配置（关键：指定 GCC 路径）

```bash
mkdir -p /root/odb-build
cd /root/odb-build

bpkg create -d odb-gcc-14.3.0 cc \
    config.cxx=g++ \
    config.cxx.coptions="-O3 -fPIC" \
    config.cxx.loptions="-static-libgcc -static-libstdc++" \
    config.bin.rpath=. \
    config.bin.lib=static \
    config.install.root=/root/odb-14.3.0 \
    config.install.sudo=sudo \
    config.odb.gxx_name=../lib/x86_64-linux-gnu/bin/g++
```

**参数说明**：

| 参数 | 含义 |
|------|------|
| `-d odb-gcc-14.3.0` | 构建目录名 |
| `config.cxx=g++` | 用于编译 ODB 自身的 C++ 编译器 |
| `config.cxx.coptions="-O3 -fPIC"` | 优化并生成位置无关代码 |
| `config.cxx.loptions="-static-libgcc -static-libstdc++"` | 静态链接 GCC 运行时库，减少对外部依赖 |
| `config.bin.rpath=.` | 运行时库搜索路径设为当前目录 |
| `config.bin.lib=static` | 优先使用静态库 |
| `config.install.root=/root/odb-14.3.0` | ODB 安装根目录 |
| `config.install.sudo=sudo` | 安装时使用 sudo |
| **`config.odb.gxx_name=../lib/x86_64-linux-gnu/bin/g++`** | **核心**：告诉 ODB 运行时使用哪个 GCC 驱动，路径相对于最终安装的 `bin/odb`（即 `../lib/...` 指向 `/root/odb-14.3.0/lib/x86_64-linux-gnu/bin/g++`） |

> 📌 **为什么使用相对路径？**  
> 这样当我们将完整 GCC 复制到 `/root/odb-14.3.0/lib/x86_64-linux-gnu/` 后，ODB 可执行文件通过 `../lib/x86_64-linux-gnu/bin/g++` 就能找到自带的 GCC，实现自包含。

### 3.2 编译 ODB

```bash
cd odb-gcc-14.3.0
bpkg build odb@https://pkg.cppget.org/1/stable
```

### 3.3 安装 ODB 编译器

```bash
bpkg install odb
```

此时，ODB 编译器已安装到 `/root/odb-14.3.0/bin/odb`，插件为 `/root/odb-14.3.0/lib/odb.so`。

---

## 4. 步骤三：嵌入完整 GCC 14.3.0 工具链（核心环节）

为了让 `/root/odb-14.3.0/bin/odb` 能够完全脱离宿主机环境运行，必须将完整的 GCC 14.3.0 安装树复制到 ODB 安装目录下的 `lib/x86_64-linux-gnu/` 中。

```bash
# 确保目标目录存在
mkdir -p /root/odb-14.3.0/lib

# 复制完整的 GCC 安装树（请将源路径替换为实际 GCC 安装路径）
cp -a /root/lib/x86_64-linux-gnu /root/odb-14.3.0/lib/
```

**验证复制结果**：

```bash
ls -l /root/odb-14.3.0/lib/x86_64-linux-gnu/bin/g++
# 应显示该文件存在并可执行
```

> ⚠️ **务必保证**：目标路径下包含完整的 `bin/`、`lib/`、`libexec/`、`include/` 等子目录，因为 ODB 需要调用 `cc1plus` 等内部工具（通常位于 `libexec/gcc/` 下）。

---

## 5. 步骤四：编译安装 ODB 运行时库（libodb 及数据库后端）

运行时库无需依赖 GCC 工具链，只需普通的 C++ 编译，因此配置中无需 `config.odb.gxx_name`。

### 5.1 创建构建配置

```bash
cd /root/odb-build

bpkg create -d libodb-gcc-14.3.0 cc \
    config.cxx=g++ \
    config.cxx.coptions="-O3 -fPIC" \
    config.cxx.loptions="-static-libgcc -static-libstdc++" \
    config.bin.rpath=. \
    config.bin.lib=static \
    config.install.root=/root/libodb-14.3.0 \
    config.install.sudo=sudo
```

### 5.2 添加官方仓库并获取包列表

```bash
cd libodb-gcc-14.3.0
bpkg add https://pkg.cppget.org/1/stable
bpkg fetch
```

### 5.3 构建所需的库

```bash
bpkg build libodb          # 核心库
bpkg build libodb-sqlite   # SQLite 后端
bpkg build libodb-pgsql    # PostgreSQL 后端
bpkg build libodb-boost    # Boost 支持
```

### 5.4 安装所有库

回到父目录，递归安装所有已构建的包：

```bash
cd /root/odb-build
bpkg install --all --recursive
```

此时，所有头文件安装到 `/root/libodb-14.3.0/include/`，库文件（静态库 `.a`）安装到 `/root/libodb-14.3.0/lib/`。

---

## 6. 验证安装

### 6.1 测试 ODB 编译器自包含性

```bash
/root/odb-14.3.0/bin/odb --version
```

如果正常输出版本信息（例如 `ODB 2.4.0`），说明嵌入的 GCC 工具链生效，ODB 可独立运行。

### 6.2 检查运行时库文件

```bash
ls -l /root/libodb-14.3.0/lib/libodb*.a
```

应看到 `libodb.a`、`libodb-sqlite.a`、`libodb-pgsql.a`、`libodb-boost.a` 等文件。

---

## 7. 结语

通过以上步骤，您将获得一个**完全自包含的 ODB 编译器**（内置 GCC 14.3.0）以及独立的 ODB 运行时库，无需依赖宿主机 GCC 环境即可稳定运行。这种部署方式特别适用于多环境分发、容器化或受限生产环境。

如遇其他问题，请参考：
- ODB 官方文档：https://www.codesynthesis.com/products/odb/
- build2 手册：https://build2.org/

---
