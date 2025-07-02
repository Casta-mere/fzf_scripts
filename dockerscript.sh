#!/bin/bash

ContainerUP () {
    # choose from all up containers
    local header=$'NAME\tCONTAINER ID\tIMAGE\tSTATUS'
    local data exited running combined selected
    data=$(docker ps -a --format '{{.Names}}|{{.ID}}|{{.Image}}|{{.Status}}' | \
        awk -F'|' '{
            name = length($1) > 20 ? substr($1, 1, 17) "..." : $1;
            printf "%-20s\t%s\t%s\t%s\n", name, $2, $3, $4
        }')
    exited=$(echo "$data" | awk -F'\t' '$4 ~ /^Exited/ { print }')
    running=$(echo "$data" | awk -F'\t' '$4 !~ /^Exited/ { print }')
    combined="$header"$'\n'"$exited"$'\n'"$running"
    formatted=$(echo "$combined" | column -t -s $'\t')

    preview_lines=100
    exited_count=$(echo "$exited" | grep -c '^')

    selected=$(echo "$formatted"| fzf \
        --reverse \
        --height 80% \
        --header-lines=$((1 + exited_count)) \
        --preview-label="🐳 Preview" \
        --preview="docker logs -n $preview_lines {1}" \
        --preview-window=follow\
        --accept-nth=2 
    )

    echo $selected
}

ContainerDown () {
    # choose from all down containers
    local header=$'NAME\tCONTAINER ID\tIMAGE\tSTATUS'
    local data exited running combined selected
    data=$(docker ps -a --format '{{.Names}}|{{.ID}}|{{.Image}}|{{.Status}}' | \
        awk -F'|' '{
            name = length($1) > 20 ? substr($1, 1, 17) "..." : $1;
            printf "%-20s\t%s\t%s\t%s\n", name, $2, $3, $4
        }')
    exited=$(echo "$data" | awk -F'\t' '$4 ~ /^Exited/ { print }')
    running=$(echo "$data" | awk -F'\t' '$4 !~ /^Exited/ { print }')
    combined="$header"$'\n'"$running"$'\n'"$exited"
    formatted=$(echo "$combined" | column -t -s $'\t')

    preview_lines=100
    running_count=$(echo "$running" | grep -c '^')

    selected=$(echo "$formatted"| fzf \
        --reverse \
        --height 80% \
        --header-lines=$((1 + running_count)) \
        --preview-label="🐳 Preview" \
        --preview="docker logs -n $preview_lines {1}" \
        --preview-window=follow\
        --accept-nth=2 
    )

    echo $selected
}

ContainerAll () {
    # choose from all containers
    local header=$'NAME\tCONTAINER ID\tIMAGE\tSTATUS'
    local data combined selected preview_lines
    data=$(docker ps -a --format '{{.Names}}|{{.ID}}|{{.Image}}|{{.Status}}' | \
        awk -F'|' '{
            name = length($1) > 20 ? substr($1, 1, 17) "..." : $1;
            printf "%-20s\t%s\t%s\t%s\n", name, $2, $3, $4
        }')
    combined="$header"$'\n'"$data"
    formatted=$(echo "$combined" | column -t -s $'\t')

    preview_lines=100

    selected=$(echo "$formatted"| fzf \
        --reverse \
        --height 80% \
        --header-lines="1" \
        --preview-label="🐳 Preview" \
        --preview="docker logs -n $preview_lines {1}" \
        --preview-window=follow\
        --accept-nth=2 
    )

    echo $selected 
}

ImageAll () {
    # choose from all Images
    local data
    data=$(docker images)

    selected=$(echo "$data"| fzf \
        --reverse \
        --height 80% \
        --header-lines="1" \
        --preview-label="🐳 Preview" \
        --preview='
            img=$(echo {} | awk "{print \$1\":\"\$2}");
            echo "Containers Origined from $img:";
            docker ps -a --filter "ancestor=$img" --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
        ' \
        --accept-nth=3
    )

    echo $selected 
}

enter() {
  local selected=$(ContainerUP)
  if [ -z "$selected" ]; then
    echo "Canceled"
    return 1
  fi
  docker exec -it $selected bash
}

dfdel() {
  local selected=$(ContainerAll)
  if [ -z "$selected" ]; then
    echo "Canceled"
    return 1
  fi
  docker rm -f $selected
}

ddel() {
  local selected=$(ContainerDown)
  if [ -z "$selected" ]; then
    echo "Canceled"
    return 1
  fi
  docker rm $selected
}
