#!/bin/bash

fglog() {
    glog --color=always | fzf --ansi --reverse
}