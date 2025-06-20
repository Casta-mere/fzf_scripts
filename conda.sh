conda_activate() {
    local envs
    envs=$(conda env list | awk 'NF && $0 !~ /^#/')
    env=$(echo "$envs" | fzf \
        --preview='
            envpath=$(echo {} | awk "{print \$NF}")
            pippath="$envpath/bin/pip"
            if [[ -x "$pippath" ]]; then
                "$pippath" list
            else
                echo "pip not found in $pippath"
            fi
        ' \
        --prompt="Activate Conda Env > " \
        --height=80% \
        --reverse
    )

    if [[ -n "$env" ]]; then
        envname=$(echo "$env" | awk '{print $1}')
        echo "🔄 Activating Conda environment: $envname"
        conda activate "$envname"
    else
        echo "❌ Cancelled."
    fi
}