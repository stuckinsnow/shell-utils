# Search file contents with ripgrep and open matching files in nvim
# ---------------------------------------------------------------------
rgv() {
  local search_term="$1"
  if [[ -z "$search_term" ]]; then
    echo "Usage: rgv <search_term>"
    return 1
  fi
  
  local files=($(rg --files-with-matches "$search_term"))
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found containing: $search_term"
    return 1
  fi
  
  local selected=$(printf '%s\n' "${files[@]}" | fzf \
    --multi \
    --preview 'bat --color=always --highlight-line $(rg -n "'"$search_term"'" {} | cut -d: -f1 | head -1) {}' \
    --preview-window=right:60% \
    --header="Found ${#files[@]} files containing '$search_term' - Select files (TAB) or ENTER for all")
  
  if [[ -z "$selected" ]]; then
    return 0
  fi
  
  local selected_files=("${(@f)selected}")
  
  if [[ ${#files[@]} -eq 1 ]] && ! echo "$selected" | grep -q $'\t'; then
    nvim "+/$search_term" "${files[@]}"
  else
    nvim "+/$search_term" "${selected_files[@]}"
  fi
}

rgb() {
    local unique=false
    
    # Check for --unique flag
    if [[ "$1" == "--unique" ]]; then
        unique=true
        shift
    fi
    
    if [[ "$1" == "--vim" ]]; then
        shift
        if [[ "$1" == "--and" ]]; then
            shift
            # Build a regex that requires ALL terms to be present on the same line
            local pattern="(?=.*$1)"
            shift
            for term in "$@"; do
                pattern="$pattern(?=.*$term)"
            done
            pattern="$pattern.*"
            
            if [[ "$unique" == true ]]; then
                vim $(rg -l -P "$pattern" . | sort -u)
            else
                vim $(rg -l -P "$pattern" .)
            fi
        else
            # OR search for vim
            local pattern=$(IFS='|'; echo "$*")
            if [[ "$unique" == true ]]; then
                vim $(rg -l "$pattern" . | sort -u)
            else
                vim $(rg -l "$pattern" .)
            fi
        fi
    elif [[ "$1" == "--and" ]]; then
        shift
        # Build a regex that requires ALL terms to be present on the same line
        local pattern="(?=.*$1)"
        shift
        for term in "$@"; do
            pattern="$pattern(?=.*$term)"
        done
        pattern="$pattern.*"

        if [[ "$unique" == true ]]; then
            rg --color=always -P "$pattern" | awk -F: '!seen[$1]++'
        else
            rg --color=always -P "$pattern"
        fi
    else
        # OR search
        local pattern=$(IFS='|'; echo "$*")
        if [[ "$unique" == true ]]; then
            rg --color=always "$pattern" | awk -F: '!seen[$1]++'
        else
            rg --color=always "$pattern"
        fi
    fi
}

