import os

# ================= 配置项 =================
# DRY_RUN = True  : 预览模式，只打印会删除的文件，不真正删除。
# DRY_RUN = False : 实战模式，直接删除文件！
DRY_RUN = False

# 要搜索的目标字符串
TARGET_STRING = 'DEFINE_GUID'
# 支持的文件后缀名（可以根据需要添加或修改）
EXTENSIONS = ('.h', '.c', '.cpp', '.hpp', '.cc')
# ==========================================

def delete_target_files():
    current_dir = os.getcwd()
    print(f"📂 正在扫描目录: {current_dir}")
    if DRY_RUN:
        print("⚠️ 当前处于【预览模式】，不会真正删除文件。")
    print("-" * 50)

    deleted_count = 0
    
    # os.walk 会遍历当前目录及所有子目录
    # 如果只想删除当前根目录，不包含子目录，可以改用 os.listdir()
    for root, dirs, files in os.walk(current_dir):
        for file in files:
            # 过滤文件后缀，避免读取大二进制文件或无关文件
            if file.endswith(EXTENSIONS):
                file_path = os.path.join(root, file)
                
                # 跳过脚本自身，防止误伤
                if file == os.path.basename(__file__):
                    continue
                
                try:
                    # 使用 utf-8 读取，忽略无法解码的字符（防止部分文件编码格式不同导致报错）
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        
                    if TARGET_STRING in content:
                        if DRY_RUN:
                            print(f"[匹配] 准备删除: {file_path}")
                        else:
                            os.remove(file_path)
                            print(f"[已删除]: {file_path}")
                        deleted_count += 1
                        
                except Exception as e:
                    print(f"❌ 无法 safety 读取文件 {file_path}: {e}")

    print("-" * 50)
    if DRY_RUN:
        print(f"🔍 扫描完毕。共发现 {deleted_count} 个包含目标字符串的文件。")
        print("💡 确认无误后，请将脚本中的 `DRY_RUN = True` 改为 `DRY_RUN = False` 来执行真正删除。")
    else:
        print(f"✨ 核心清理完毕！共成功删除 {deleted_count} 个文件。")

if __name__ == "__main__":
    delete_target_files()