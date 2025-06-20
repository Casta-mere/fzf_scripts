conda_activate() {
    local env envs
    envs=$(conda env list | awk 'NF && $0 !~ /^#/')
    env=$(echo "$envs" | fzf \
        --delimiter ' ' \
        --preview='
            pippath={-1}/bin/pip
            "$pippath" list
        ' \
        --prompt="Activate Conda Env > " \
        --height=80% \
        --reverse \
        --accept-nth 1 \
    )

    if [[ -n "$env" ]]; then
        echo "🔄 Activating Conda environment: $env"
        conda activate $env
    else
        echo "❌ Cancelled."
    fi
}

conda_search() {
    local rows=""
    local envs
    envs=$(conda env list | awk 'NF && $0 !~ /^#/' | awk '{print $1}')

    while read -r env; do
        while IFS=$'\t' read -r name version; do
            [[ -n "$name" ]] && rows+="$env\t$name\t$version"$'\n'
        done < <(conda run -n "$env" pip list --format=columns 2>/dev/null | awk 'NR > 2 {print $1 "\t" $2}')
    done <<< "$envs"

    if [[ -z "$rows" ]]; then
        echo "⚠️ Nothing Here"
        return 1
    fi

    {
        echo -e "ENV\tPACKAGE\tVERSION"
        echo -e "$rows"
    } | column -t -s $'\t' | \
    fzf \
        --prompt="🔎 Search pip packages > " \
        --header-lines=1 \
        --reverse \
        --nth 2 \
        --accept-nth 2 \
        --color nth:regular,fg:dim \
        --height=90% \
        --preview='
            env=$(echo {} | awk "{print \$1}")
            pkg=$(echo {} | awk "{print \$2}")
            conda run -n $env pip show $pkg 2>/dev/null || echo "📦 Nothing Here"
        '
}