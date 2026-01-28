# Vim Configuration

This directory contains a comprehensive Vim configuration optimized for polyglot development.

## Structure

```
vim/
├── .vimrc                 # Main configuration file
└── .vim/
    ├── after/             # Configuration loaded after plugins
    │   └── ftplugin/      # Filetype-specific overrides
    ├── autoload/          # Lazy-loaded functions
    ├── colors/            # Custom color schemes
    ├── ftdetect/          # Filetype detection
    ├── ftplugin/          # Filetype-specific settings
    ├── indent/            # Indentation rules
    ├── pack/              # Native package management
    │   ├── local/start/   # Custom local plugins (auto-loaded)
    │   └── remote/start/  # External plugins (managed by minpac)
    ├── plugin/            # Global plugin scripts
    ├── spell/             # Custom spell files
    └── UltiSnips/         # Snippet definitions
```

## Key Features

### Language Support
- **Ruby**: Full Rails support with vim-rails, Solargraph LSP, RuboCop linting
- **Python**: pylsp language server, flake8 linting
- **JavaScript/TypeScript**: TypeScript LSP, ESLint via ALE
- **Java**: Java language server integration
- **XML/SOAP**: Extensive XML tooling for API development
- **Others**: Go, Terraform, GraphQL, Markdown, etc.

### Plugin Management
- **minpac**: Minimal package manager using native vim packages
- **Pathogen**: Maintained for backward compatibility with older Vim versions

### LSP & Linting Strategy
- **vim-lsc**: Handles LSP protocol (definitions, references, hover, etc.)
- **ALE**: Handles linting and fixing (separate from LSP)
- Both work together - not redundant!

### Completion
- **mucomplete**: Manual completion only (disabled auto-completion)
- Chains: file, ultisnips, omni, tags, dictionary
- Language-specific completion chains configured per filetype

### Custom Local Plugins
Located in `pack/local/start/`:
- **vim-ccr**: Smart command-line <CR> behavior
- **vim-edit**: Enhanced file editing utilities
- **vim-hilinktrace**: Syntax highlighting trace tool
- **vim-hudigraphs**: Human-friendly digraph insertion
- **vim-marks**: Enhanced mark management
- **vim-numfmt**: Number formatting utilities
- **vim-previewdoc**: Enhanced preview documentation
- **vim-textobj**: Custom text objects (method, indent, column, declaration)
- **vim-tmuxnavigate**: Seamless tmux/vim navigation
- **vim-verymagic**: Very magic regex mode by default

## Autoload Functions

Core helper functions in `.vim/autoload/`:
- **args.vim**: Tab-split argument management
- **functions.vim**: Custom fold text and utilities
- **git.vim**: Git blame integration
- **grep.vim**: Enhanced grep commands (Grep, LGrep)
- **pack.vim**: Package management helpers
- **pair.vim**: Pair programming utilities
- **putoperator.vim**: Enhanced paste operator
- **ruby.vim**: Ruby-specific test running
- **skeleton.vim**: Template/skeleton system
- **tag.vim**: Enhanced tag navigation
- **vim.vim**: Vim refresh and focus utilities
- **whitespace.vim**: Trailing whitespace management
- **xml/***: XML/SOAP API development tools (9 files)

## Configuration Philosophy

### Backward Compatibility
- Maintains support for older Vim versions (pre-8.0)
- Pathogen fallback when native packages unavailable
- Feature detection with `has()` checks

### Manual Over Automatic
- Completion: Manual trigger preferred over auto-popup
- Lazy loading: Plugins loaded on-demand when needed
- Minimal startup time: Only essential plugins loaded

## Key Mappings

### Leader Key
- Leader: `<Space>`

### Navigation
- `[b` / `]b`: Previous/next buffer
- `[t` / `]t`: Previous/next tab
- `[q` / `]q`: Previous/next quickfix
- `[l` / `]l`: Previous/next location list
- `<BS>`: Alternate buffer

### Editing
- `Y`: Yank to end of line (consistent with C and D)
- `c*`: Change next occurrence of word under cursor
- `zp`: Paste with operator (e.g., `zpip` paste in paragraph)

### LSP (Ruby files with Solargraph)
- `gd`: Go to definition
- `gr`: Find references
- `gI`: Find implementations
- `ga`: Code actions
- `gR`: Rename symbol
- `K`: Hover documentation

### Tools
- `<Space>gr`: Grep in project
- `<Space>ff`: Find file
- `<Space>m`: Make/build
- `<F5>`: Refresh vim config
- `<F11>`: Focus mode

## Installation

1. Clone this repo to `~/.dotfiles` or similar
2. Symlink: `ln -s ~/.dotfiles/vim/.vimrc ~/.vimrc`
3. Symlink: `ln -s ~/.dotfiles/vim/.vim ~/.vim`
4. Open Vim and run `:PackUpdate` to install plugins
5. Install language servers as needed:
   - Ruby: `gem install solargraph`
   - Python: `pip install python-lsp-server flake8`
   - JavaScript/TypeScript: `npm install -g typescript-language-server`

## Testing

After changes, verify:
```bash
vim -u vim/.vimrc --clean -c 'quit'  # Check for errors
vim -c 'scriptnames'                  # See loaded scripts
```

## Maintenance

- Clean plugins: `:PackClean`
- Update plugins: `:PackUpdate`
- Check plugin status: `:PackStatus`
- Trim whitespace: `:TrimWhiteSpace`

## Notes

- Configuration reduced from 626 to 605 lines in .vimrc
- Total vim config: ~1,450+ lines across all files
- Cleaned 50+ lines from ruby.vim ftplugin
- XML support retained for active SOAP API work
- Both vim-lsc and ALE intentionally configured together
