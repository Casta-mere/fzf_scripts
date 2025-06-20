#!/bin/bash

ContainerUP () {
    # choose from all up containers
    local header="NAME\tCONTAINER ID\tIMAGE\tSTATUS"
    local data exited running combined selected
    data=$(docker ps -a --format '{{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}')
    exited=$(echo "$data" | awk -F'\t' '$4 ~ /^Exited/ { print }')
    running=$(echo "$data" | awk -F'\t' '$4 !~ /^Exited/ { print }')
    combined="$header"$'\n'"$exited"$'\n'"$running"
    formatted=$(echo "$combined" | column -t -s $'\t')

    preview_lines=$(awk "BEGIN { printf \"%d\", $(tput lines) * 0.8 - 2 }")
    exited_count=$(echo "$exited" | grep -c '^')

    selected=$(echo "$formatted"| fzf \
        --reverse \
        --height 80% \
        --header-lines=$((1 + exited_count)) \
        --preview-label="🐳 Preview" \
        --preview="echo {} | awk '{print \$2}' | xargs docker logs -n $preview_lines" \
        --accept-nth=2 
    )

    echo $selected
}

ContainerAll () {
    # choose from all containers
    local header="NAME\tCONTAINER ID\tIMAGE\tSTATUS"
    local data combined selected preview_lines
    data=$(docker ps -a --format '{{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}')
    combined="$header"$'\n'"$data"
    formatted=$(echo "$combined" | column -t -s $'\t')

    preview_lines=$(awk "BEGIN { printf \"%d\", $(tput lines) * 0.8 - 2 }")

    selected=$(echo "$formatted"| fzf \
        --reverse \
        --height 80% \
        --header-lines="1" \
        --preview-label="🐳 Preview" \
        --preview="echo {} | awk '{print \$2}' | xargs docker logs -n $preview_lines" \
        --accept-nth=2 
    )

    echo $selected 
}

enter() {
  docker exec -it $(ContainerUP) bash
}
