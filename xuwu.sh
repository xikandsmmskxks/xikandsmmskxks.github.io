#!/bin/sh

# 样式定义
LINE="============================================="
SEP="---------------------------------------------"
ARROW="→"

# 美化列表展示（当前目录文件选择模式用）
list_scripts() {
    echo "$LINE"
    echo "          虚无 文件加密工具          "
    echo "$LINE"
    echo
    echo "  检测到当前目录下的文件："
    echo "$SEP"
    index=1
    file_list=""
    for file in *; do
        if [ -f "$file" ] && [ "$file" != "$(basename "$0")" ]; then
            printf "  %2d) %s\n" "$index" "$file"
            file_list="$file_list $file"
            index=$((index + 1))
        fi
    done
    echo "$SEP"
    echo
}

# 增强版获取文件名函数（兼容更多环境）
get_filename() {
    local path="$1"
    if [ -z "$path" ]; then
        echo ""
        return 1
    fi
    # 处理绝对路径和相对路径
    basename "$path" 2>/dev/null || {
        local dir_sep="/"
        if [[ "$path" == *"$dir_sep"* ]]; then
            echo "${path##*$dir_sep}"
        else
            echo "$path"
        fi
    }
}

# 10层Base64编码函数
base64_encode_10() {
    local content="$1"
    for i in $(seq 1 10); do  # 改为10层编码
        content=$(printf "%s" "$content" | base64 -w 0)
    done
    echo "$content"
}

multi_encrypt() {
    input_file="$1"
    # 输出文件名：原文件名后加“_加密”（保留原后缀）
    output_file="${input_file%.*}_加密.${input_file##*.}"
    # 处理无后缀的文件
    if [ "$output_file" = "_加密.$input_file" ]; then
        output_file="${input_file}_加密"
    fi

    export LC_ALL=C
    
    # 获取输出文件名（增强容错）
    output_basename=$(get_filename "$output_file")
    if [ -z "$output_basename" ]; then
        output_basename=$(basename "$output_file" 2>/dev/null)
    fi
    # 计算文件名MD5（确保非空）
    output_name_md5=$(printf "%s" "$output_basename" | md5sum | awk '{print $1}')
    
    temp_file=$(mktemp)
    cat <<EOF > "$temp_file"
#!/bin/sh

export LC_ALL=C

# 增强版获取当前文件名（增加异常处理）
get_current_filename() {
    local path="\$1"
    if [ -z "\$path" ]; then
        echo ""
        return 1
    fi
    basename "\$path" 2>/dev/null || {
        local dir_sep="/"
        if [[ "\$path" == *"\$dir_sep"* ]]; then
            echo "\${path##*\$dir_sep}"
        else
            echo "\$path"
        fi
    }
}

allowed_name_md5="$output_name_md5"
current_path="\$0"
current_basename=\$(get_current_filename "\$current_path")
if [ -z "\$current_basename" ]; then
    echo "错误：无法获取当前文件名" >&2
    exit 1
fi

current_md5=\$(printf "%s" "\$current_basename" | md5sum | awk '{print \$1}')

if [ -z "\$current_md5" ] || [ "\$current_md5" != "\$allowed_name_md5" ]; then
    echo "djsoskhxjwlahxbsjsjx" >&2
    echo "sjwkskwksoksmsndskkskskskdnd" >&2
    exit 1
fi

EOF
    cat "$input_file" >> "$temp_file"
    chmod +x "$temp_file"

    hex_content=$(gzip -c "$temp_file" | xxd -p)
    base64_content=$(base64_encode_10 "$hex_content")  # 调用10层编码函数

    # 加密后脚本
    cat > "$output_file" <<'EOF'
#!/bin/sh
#==========================================#
#
#            虚无独家公益加密               #
#                                          #
#  难度：⭐️⭐️⭐️                             #
#
#  标识：\(≧∇≦)/                           #
#
#  寄语：举头望明月，低头思故乡             #
#
#  频道：@xuwuljyyds                        #
#
#==========================================#

clear
export LC_ALL=C

xuwunb() {
    local content="$1"
    for i in $(seq 1 10); do  # 改为10层解码
        content=$(printf "%s" "$content" | base64 -d)
    done
    echo "$content"
}

hex_content=$(xuwunb "__BASE64_CONTENT__")
decrypted_content=$(echo "$hex_content" | xxd -p -r | gunzip)
sh -c "$decrypted_content" "$0" "$@"
EOF

    sed -i "s|__BASE64_CONTENT__|$base64_content|g" "$output_file"
    chmod +x "$output_file"
    rm -f "$temp_file"

    echo "$SEP"
    echo "  $ARROW 加密完成"
    echo "  $ARROW 输出文件：$output_file"
    echo "$SEP"
    echo "  🔑 加密保护已启用"
    echo "  💡 by-虚无"
    echo
}

main() {
    echo "$LINE"
    echo "          虚无 文件加密工具          "
    echo "$LINE"
    echo "  1) 输入文件路径加密"
    echo "  2) 当前目录文件加密"
    echo "$SEP"
    printf "  请选择模式 (1/2) $ARROW "
    read -r mode

    case "$mode" in
        1)
            # 输入路径模式
            printf "  请输入文件路径 $ARROW "
            read -r input_path
            if [ ! -f "$input_path" ]; then
                echo "  ⚠️ 错误：文件不存在或不是常规文件"
                exit 1
            fi
            echo "  $ARROW 选中文件：$input_path"
            echo "  $ARROW 开始加密处理..."
            echo
            multi_encrypt "$input_path"
            ;;
        2)
            # 当前目录选择模式
            list_scripts
            if [ -z "$file_list" ]; then
                echo "  ⚠️ 未找到可加密的文件（已排除本工具）"
                exit 1
            fi
            while :; do
                printf "  请选择加密序号 (1-%d) $ARROW " "$((index - 1))"
                read -r choice
                if [ "$choice" -eq 0 2>/dev/null ]; then
                    echo "  👋 程序已退出"
                    exit 0
                elif [ "$choice" -gt 0 ] && [ "$choice" -lt "$index" 2>/dev/null ]; then
                    break
                else
                    echo "  ⚠️ 无效输入，请重新选择"
                fi
            done
            selected_file=$(echo "$file_list" | awk -v num="$choice" '{print $num}')
            echo
            echo "  $ARROW 选中文件：$selected_file"
            echo "  $ARROW 开始加密处理..."
            echo
            multi_encrypt "$selected_file"
            ;;
        *)
            echo "  ⚠️ 无效模式，请选择 1 或 2"
            exit 1
            ;;
    esac
}

main