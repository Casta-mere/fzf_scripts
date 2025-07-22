# fzf_scripts

Some fzf shortcut scipts, View [fzf scripts](https://www.castamerego.com/blog/blog/fzf) for more information on these scripts

Right now we have:

- Docker
  - Select and enter Docker container (_enter_)
  - Select and delete Docker container (_ddel_/_dfdel_)
- grep and preview results (_ffgrep_)
- View and kill processes (_fkill_)
- Conda
  - Enter Conda environment (_conda_activate_)
  - Search Conda environment (for package) (_conda_search_)

# Install

These scripts requires `fzf` as well as some other dependencies, please ensure you have them installed before using these scripts

Recommand download directly from githuh. Click [here](https://github.com/junegunn/fzf/releases) to fzf release

The fzf version in packet manager (like apt) is quite out of date。Writer highly suggest use `uname --all` to check system info and download from github

After downloading, upload it to your device and unzip it. Copy fzf to `/usr/bin`

Other dependencies include:

- batcat (apt install batcat)

## CMD Install

This method require connection to github.com, if not available or connection timeout, please use [manual install](#manual-install)

```
curl -fsSL https://github.com/Casta-mere/fzf_scripts/releases/download/V0.1.0/install.sh -o ./install.sh
chmod +x ./install.sh
./install.sh --install
```

## Manual Install

1. Click [fzf_scripts](https://github.com/Casta-mere/fzf_scripts/releases/tag/latest) and download **install_pack.tar.gz**
2. Upload it to Your device and change to it's dir
3. Use `tar -xzvf install_pack.tar.gz` to unzip it
4. Use `chmod +x ./install.sh && ./install.sh --install` to Install

# Contribution

Please add fun requirements or issues to this repo

---

# fzf 脚本库

一些 fzf 快捷脚本, 查看 [fzf 脚本](https://www.castamerego.com/blog/blog/fzf) 了解这些脚本的信息

目前包括：

- Docker
  - 选择并进入 Docker 容器 (_enter_)
  - 选择并删除 Docker 容器 (_ddel_/_dfdel_)
- grep 并预览结果 (_ffgrep_)
- 查看并杀死进程 (_fkill_)
- Conda
  - 进入 Conda 环境 (_conda_activate_)
  - 搜索 Conda 环境 (搜索包) (_conda_search_)

# 安装

脚本本身需要 `fzf` 以及一些其他依赖, 请确保在使用这些脚本前安装了这些依赖

建议直接去 github 下载安装，点击[链接](https://github.com/junegunn/fzf/releases)直达 release

Linux 下的包管理器中的版本都很旧。笔者建议用 `uname --all` 查看系统信息，去 github 下载对应版本

下载完成后，上传到服务器，解压。将 fzf 复制到 `/usr/bin` 目录下

其他依赖包括

- batcat (apt install batcat)

## 命令安装

该方式需要设备能连接到 github, 若无法连接或下载超时请使用[手动安装](#手动安装)

```
curl -fsSL https://github.com/Casta-mere/fzf_scripts/releases/download/V0.1.0/install.sh -o ./install.sh
chmod +x ./install.sh
./install.sh --install
```

## 手动安装

1. 点击 [fzf_scripts](https://github.com/Casta-mere/fzf_scripts/releases/tag/latest) 下载 **install_pack.tar.gz**
2. 上传文件到设备并切换到该目录
3. 使用 `tar -xzvf install_pack.tar.gz` 解压
4. 使用 `chmod +x ./install.sh && ./install.sh --install` 安装

# 贡献

如果有有趣的需求或问题请添加 issue
