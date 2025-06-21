glog() {
  if [[ -n "$1" ]]; then
    # Ask user which comparison they want
    choice=$(echo -e "1. Show changes made in this commit\n2. Show differences vs current HEAD" | \
      fzf --prompt="Choose comparison type: " --height=5 ${=FZF_TERMINAL_COLORS})
    
    if [[ "$choice" == "1. Show changes made in this commit" ]]; then
      # Show files changed in specific commit
      git diff-tree --no-commit-id --name-only -r "$1" | \
        fzf --preview-window=right:60% --preview "
          git show --color=always '$1' -- {} |
          delta  --color-only --line-numbers-left-format='' --line-numbers-right-format=''
        " --bind "enter:execute(
          git show --color=always '$1' -- {} |
          delta --color-only --line-numbers-left-format='' --line-numbers-right-format='' |
          less -R
        )" --bind "ctrl-e:execute-silent(
          file={}
          (echo \$file | wl-copy || echo \$file | xclip -selection clipboard) && 
          notify-send '📋 Copied to clipboard' \"\$file\" --expire-time=2000
        )" ${=FZF_TERMINAL_COLORS}
    elif [[ "$choice" == "2. Show differences vs current HEAD" ]]; then
      # Show files changed between specific commit and current HEAD
      git diff --name-only "$1" HEAD | \
        fzf --preview-window=right:60% --preview "
          git diff --color=always '$1' HEAD -- {} |
          delta  --color-only --line-numbers-left-format='' --line-numbers-right-format=''
        " --bind "enter:execute(
          git diff --color=always '$1' HEAD -- {} |
          delta --color-only --line-numbers-left-format='' --line-numbers-right-format='' |
          less -R
        )" --bind "ctrl-e:execute-silent(
          file={}
          (echo \$file | wl-copy || echo \$file | xclip -selection clipboard) && 
          notify-send '📋 Copied to clipboard' \"\$file\" --expire-time=2000
        )" ${=FZF_TERMINAL_COLORS}
    fi
  else
    # Interactive log browser with colors
    git log --graph --decorate --all --color=always \
      --format="%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %C(white)%s%C(reset) %C(red)%an%C(reset)" \
      --date=format:'%d-%m-%Y' | \
      fzf --no-sort --reverse --ansi --preview-window=right:60% --preview '
        commit=$(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)
        git show --color=always $commit |
        delta --color-only --line-numbers-left-format="" --line-numbers-right-format="" 
      ' --bind "ctrl-e:execute-silent(
        commit=\$(echo {} | grep -o '[a-f0-9]\{7,\}' | head -1)
        (echo \$commit | wl-copy || echo \$commit | xclip -selection clipboard) && 
        notify-send '📋 Copied commit hash' \"\$commit\" --expire-time=2000
      )" ${=FZF_TERMINAL_COLORS}
  fi
}

gfum() {
  git fetch upstream && git merge upstream/$(git show-ref --verify --quiet refs/remotes/upstream/main && echo main || echo master)
}

gn() {
  gh notify -an 20
}
