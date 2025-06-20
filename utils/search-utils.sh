# Search file contents with ripgrep and open matching files in nvim
# ---------------------------------------------------------------------
# Search file contents with ripgrep and open matching files in nvim
# ---------------------------------------------------------------------
rgv() {
  local unique=false
  local and_search=false
  local search_terms=()
  
  # Parse flags
  while [[ $# -gt 0 ]]; do
    case $1 in
      --unique)
        unique=true
        shift
        ;;
      --and)
        and_search=true
        shift
        ;;
      *)
        search_terms+=("$1")
        shift
        ;;
    esac
  done
  
  if [[ ${#search_terms[@]} -eq 0 ]]; then
    echo "Usage: rgv [--unique] [--and] <search_term> [additional_terms...]"
    return 1
  fi
  
  local pattern
  local files
  
  if [[ "$and_search" == true ]]; then
    # Build a regex that requires ALL terms to be present on the same line
    pattern=""
    for term in "${search_terms[@]}"; do
      pattern="$pattern(?=.*$term)"
    done
    pattern="$pattern.*"
    
    if [[ "$unique" == true ]]; then
      files=($(rg -i -l -P "$pattern" . | sort -u))
    else
      files=($(rg -i -l -P "$pattern" .))
    fi
    
    local search_display="AND: ${search_terms[*]}"
    local preview_pattern="$pattern"
  else
    # OR search (default behavior)
    pattern=$(IFS='|'; echo "${search_terms[*]}")
    
    if [[ "$unique" == true ]]; then
      files=($(rg -i -l "$pattern" . | sort -u))
    else
      files=($(rg -i -l "$pattern" .))
    fi
    
    local search_display="OR: ${search_terms[*]}"
    local preview_pattern="$pattern"
  fi
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found containing: $search_display"
    return 1
  fi
  
  local selected
  if [[ "$and_search" == true ]]; then
    selected=$(printf '%s\n' "${files[@]}" | fzf \
      --multi \
      --preview 'bat --color=always --highlight-line $(rg -i -n -P "'"$preview_pattern"'" {} | cut -d: -f1 | head -1) {}' \
      --preview-window=right:60% \
      --header="Found ${#files[@]} files containing '$search_display' - Select files (TAB) or ENTER for all")
  else
    selected=$(printf '%s\n' "${files[@]}" | fzf \
      --multi \
      --preview 'bat --color=always --highlight-line $(rg -i -n "'"$preview_pattern"'" {} | cut -d: -f1 | head -1) {}' \
      --preview-window=right:60% \
      --header="Found ${#files[@]} files containing '$search_display' - Select files (TAB) or ENTER for all")
  fi
  
  if [[ -z "$selected" ]]; then
    return 0
  fi
  
  local selected_files=("${(@f)selected}")
  
  # Open files in vim with search pattern
  if [[ ${#selected_files[@]} -eq 1 ]] && ! echo "$selected" | grep -q $'\t'; then
    if [[ "$and_search" == true ]]; then
      vim "+/${search_terms[1]}" "${selected_files[@]}"
    else
      vim "+/${search_terms[1]}" "${selected_files[@]}"
    fi
  else
    if [[ "$and_search" == true ]]; then
      vim "+/${search_terms[1]}" "${selected_files[@]}"
    else
      vim "+/${search_terms[1]}" "${selected_files[@]}"
    fi
  fi
  
  # Beautiful output after vim closes
  echo ""
  echo "📁 Opened ${#selected_files[@]} files:"
  printf '%s\n' "${selected_files[@]}" | bat --color=always --style=numbers,grid --language=txt --theme=base16 --paging=never
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
            local pattern=""
            for term in "$@"; do
                pattern="$pattern(?=.*$term)"
            done
            pattern="$pattern.*"
            
            local files
            if [[ "$unique" == true ]]; then
                files=($(rg -l -P "$pattern" . | sort -u))
                vim "${files[@]}"
            else
                files=($(rg -l -P "$pattern" .))
                vim "${files[@]}"
            fi
        else
            # OR search for vim
            local pattern=$(IFS='|'; echo "$*")
            local files
            if [[ "$unique" == true ]]; then
                files=($(rg -l "$pattern" . | sort -u))
                vim "${files[@]}"
            else
                files=($(rg -l "$pattern" .))
                vim "${files[@]}"
            fi
        fi
        
        # Beautiful output after vim closes
        echo ""
        echo "📁 Found ${#files[@]} files:"
        printf '%s\n' "${files[@]}" | bat --color=always --style=numbers,grid --language=txt --theme=base16 --paging=never
        
    elif [[ "$1" == "--and" ]]; then
        shift
        # Build a regex that requires ALL terms to be present on the same line
        local pattern=""
        for term in "$@"; do
            pattern="$pattern(?=.*$term)"
        done
        pattern="$pattern.*"

        local files
        if [[ "$unique" == true ]]; then
            rg --color=always -P "$pattern" | awk -F: '!seen[$1]++'
            files=($(rg -l -P "$pattern" . | sort -u))
        else
            rg --color=always -P "$pattern"
            files=($(rg -l -P "$pattern" .))
        fi
        
        # Beautiful output after search results
        echo ""
        echo "📁 Found ${#files[@]} files:"
        printf '%s\n' "${files[@]}" | bat --color=always --style=numbers,grid --language=txt --theme=base16 --paging=never
        
    else
        # OR search
        local pattern=$(IFS='|'; echo "$*")
        local files
        if [[ "$unique" == true ]]; then
            rg --color=always "$pattern" | awk -F: '!seen[$1]++'
            files=($(rg -l "$pattern" . | sort -u))
        else
            rg --color=always "$pattern"
            files=($(rg -l "$pattern" .))
        fi
        
        # Beautiful output after search results
        echo ""
        echo "📁 Found ${#files[@]} files:"
        printf '%s\n' "${files[@]}" | bat --color=always --style=numbers,grid --language=txt --theme=base16 --paging=never
    fi
}
