# Shell Utilities

A collection of shell utilities for enhanced Git workflow and file searching capabilities.

https://github.com/user-attachments/assets/f703c91b-f648-4ec3-b77c-c19b2d6193a2

## Setup

Source the main script in your shell configuration:

```bash
source /path/to/main.sh
```

## Requirements

- `fzf` - Fuzzy finder
- `rg` (ripgrep) - Fast text search
- `delta` - Git diff viewer
- `bat` - Enhanced cat with syntax highlighting
- `glow` - Markdown viewer (optional)
- `wl-copy` or `xclip` - Clipboard utilities
- `notify-send` - Desktop notifications

## Git Utilities

### `glog [commit-hash]`

Interactive git log browser with enhanced diff viewing.

**Without arguments:**

- Shows interactive git log with commit graph
- Preview pane displays commit details with delta formatting
- `Ctrl+E` copies commit hash to clipboard

**With commit hash:**

- Prompts for comparison type:
  1. Show changes made in this commit
  2. Show differences vs current HEAD
- Interactive file browser with diff previews
- `Enter` opens full diff in less
- `Ctrl+E` copies filename to clipboard

**Examples:**

```bash
glog                    # Interactive log browser
glog abc1234            # View specific commit changes
```

### `gfum`

Fetch and merge from upstream remote.

Automatically detects whether upstream uses `main` or `master` branch.

```bash
gfum
```

## Search Utilities

### `rgv <search_term>`

Search file contents and open matching files in Neovim.

**Features:**

- Uses ripgrep for fast searching
- Interactive file selection with fzf
- Preview shows file content with bat syntax highlighting
- Search term line highlighted in preview
- Opens files in Neovim with search term highlighted

**Examples:**

```bash
rgv "function"          # Search for "function" in files
rgv "TODO"             # Find all TODO comments
```

### `rgb [options] <search_terms>`

Advanced ripgrep search with multiple options.

**Options:**

- `--unique` - Show only unique filenames (remove duplicates)
- `--vim` - Open results in vim instead of displaying
- `--and` - Require ALL terms on same line (AND search)

**Examples:**

```bash
rgb "error"                           # Basic search
rgb --unique "error"                  # Remove duplicate filenames
rgb --vim "function"                  # Open matching files in vim
rgb --and "function" "async"          # Find lines with both terms
rgb --vim --and "const" "export"      # Open files with both terms
```

**Search Types:**

- Default: OR search (any term matches)
- `--and`: AND search (all terms must be on same line)
- `--vim`: Opens files in vim instead of displaying results
- `--unique`: Removes duplicate filenames from results

## Key Bindings

### glog

- `Enter` - Open full diff
- `Ctrl+E` - Copy to clipboard (commit hash or filename)

### File Previews

- Right panel shows 60% width preview
- Syntax highlighting with delta/bat
- Color-coded git output

## Environment Variables

Set `FZF_TERMINAL_COLORS` for custom fzf color schemes.

## Tips

1. Use `glog` without arguments to browse commit history interactively
2. Combine `rgb --unique --vim` to quickly open files without duplicates
3. Use `rgv` for quick file searches when you want to edit results
4. `gfum` is perfect for syncing forks with upstream repositories
