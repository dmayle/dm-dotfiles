{ config, pkgs, ... }:
let
  unstableHomeManager = fetchTarball https://github.com/nix-community/home-manager/tarball/07f6c6481e0cbbcaf3447f43e964baf99465c8e1;
  unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/0b876eaed3ed4715ac566c59eb00004eca3114e8;
  unstablePkgs = import unstable { config.allowUnfree = true; };

  # Custom neovim plugins
  vim-maximizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-maximizer";
    src = pkgs.fetchFromGitHub {
      owner = "szw";
      repo = "vim-maximizer";
      rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
      sha256 = "031brldzxhcs98xpc3sr0m2yb99xq0z5yrwdlp8i5fqdgqrdqlzr";
    };
    meta = {
      homepage = https://github.com/szw/vim-maximizer;
      maintainers = [ "szw" ];
    };
  };

  nvim-colorizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "nvim-colorizer";
    src = pkgs.fetchFromGitHub {
      owner = "norcalli";
      repo = "nvim-colorizer.lua";
      rev = "36c610a9717cc9ec426a07c8e6bf3b3abcb139d6";
      sha256 = "0gvqdfkqf6k9q46r0vcc3nqa6w45gsvp8j4kya1bvi24vhifg2p9";
    };
    meta = {
      homepage = https://github.com/norcalli/nvim-colorizer.lua;
      maintainers = [ "norcalli" ];
    };
  };

  indent-blankline = pkgs.vimUtils.buildVimPlugin rec {
    name = "indent-blankline";
    src = pkgs.fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "indent-blankline.nvim";
      rev = "d925b80b3f57c8e2bf913a36b37aa63b6ed75205";
      sha256 = "1h1jsjn6ldpx0qv7vk3isqs7hrfz1srv5q6vrf44lv2r5di1gr65";
    };
    meta = {
      homepage = https://github.com/lukas-reineke/indent-blankline.nvim;
      maintainers = [ "lukas-reineke" ];
    };
  };
in
{
  imports =
    [
      "${unstableHomeManager}/modules/services/wlsunset.nix"
    ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/tarball/5e3737ae3243e2e206360d39131d5eb6f65ecff5;
    }))

    # For when I need to straight up override packages
    (self: super: {
      # Use nightly neovim as the basis for my regular neovim package
      neovim-unwrapped = self.neovim-nightly;
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "douglas";
  home.homeDirectory = "/home/douglas";

  services.wlsunset = {
    package = unstablePkgs.wlsunset;
    enable = true;
    # Nice, France
    latitude = "43.7";
    longitude = "7.2";
  };

  # Setup vi keybinding with readline
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
    '';
  };

  # Configure solarized light color scheme for kitt
  programs.kitty = {
    enable = true;
    extraConfig = ''
      # Solarized Light Colorscheme

      background              #fdf6e3
      foreground              #657b83
      cursor                  #586e75

      selection_background    #475b62
      selection_foreground    #eae3cb

      color0                #073642
      color8                #002b36

      color1                #dc322f
      color9                #cb4b16

      color2                #859900
      color10               #586e75

      color3                #b58900
      color11               #657b83

      color4                #268bd2
      color12               #839496

      color5                #d33682
      color13               #6c71c4

      color6                #2aa198
      color14               #93a1a1

      color7                #eee8d5
      color15               #fdf6e3

      # Choose Powerline Symbols
      symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3,U+1F512 PowerlineSymbols

      # Setup font size controls
      map kitty_mod+0 set_font_size 11
      map kitty_mod+equal change_font_size all +2.0
      map kitty_mod+minux change_font_size all -2.0
    '';
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    clock24 = true;
    keyMode = "vi";
    shortcut = "a";
    extraConfig = ''
      # Use tmux TERM for more features, and 256color for true color
      set -g default-terminal "tmux-256color"

      # Enable italic support
      #set -as terminal-overrides ',*:sitm=\E[3m'

      # Enable undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

      # Enable colored underline support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # This tmux statusbar config was created by tmuxline.vim
      # on Fri, 14 Feb 2020

      set -g status-justify "left"
      set -g status "on"
      set -g status-left-style "none"
      set -g message-command-style "fg=#eee8d5,bg=#93a1a1"
      set -g status-right-style "none"
      set -g pane-active-border-style "fg=#657b83"
      set -g status-style "none,bg=#eee8d5"
      set -g message-style "fg=#eee8d5,bg=#93a1a1"
      set -g pane-border-style "fg=#93a1a1"
      set -g status-right-length "100"
      set -g status-left-length "100"
      setw -g window-status-activity-style "none"
      setw -g window-status-separator ""
      setw -g window-status-style "none,fg=#93a1a1,bg=#eee8d5"
      set -g status-left "#[fg=#eee8d5,bg=#657b83,bold] #S #[fg=#657b83,bg=#eee8d5,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] %Y-%m-%d  %H:%M #[fg=#657b83,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#657b83] #h "
      setw -g window-status-format "#[fg=#93a1a1,bg=#eee8d5] #I #[fg=#93a1a1,bg=#eee8d5] #W "
      setw -g window-status-current-format "#[fg=#eee8d5,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] #I #[fg=#eee8d5,bg=#93a1a1] #W #[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]"
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      # File explorer
      nerdtree

      # Source code class explorer
      tagbar

      # Status bar with coloring
      vim-airline
      vim-airline-themes

      # Toggle between maximizing current split, and then restoring previous
      # split state
      vim-maximizer

      # Start using treesitter
      nvim-treesitter
      #unstable can install maintained parsers but can't use them
      #unstablePkgs.vimPlugins.nvim-treesitter

      # Configure fuzzy finder integration
      fzf-vim

      # solarized
      NeoSolarized

      # Configurable text colorizing
      nvim-colorizer

      # Nix Filetype support
      vim-nix

      # Code commenting
      vim-commentary

      # Vim Git UI
      vim-fugitive
      vim-signify

      # Builtin Nvim LSP support
      unstablePkgs.vimPlugins.nvim-lspconfig

      # Lightweight autocompletion
      unstablePkgs.vimPlugins.completion-nvim

      # Both Indent guides plugins
      indent-blankline

      # Built-in debugger
      vimspector
    ];

    extraConfig = ''
      " Remember, all autocommands should be in autogroups

      " #######################################################################
      " ****** OVERALL SETTINGS ******
      " #######################################################################

      " I don't want files overriding my settings
      set modelines=0

      " Enable 24-bit color support
      set termguicolors

      " I like to be able to occasionally use the mouse
      set mouse=a

      " Make sure we use Solarized light
      set background=light
      colorscheme NeoSolarized

      " Allow more-responsive async code
      set updatetime=100

      " #######################################################################
      " ****** PLUGIN SETTINGS ******
      " #######################################################################

      " %%%%%%%%%% Indent Blankline %%%%%%%%%%
      " Enable treesitter support
      let g:indent_blankline_use_treesitter = v:true

      " #######################################################################
      " ****** FILETYPE SETTINGS ******
      " #######################################################################

      " Default to bash support in shell scripts
      let g:is_bash = 1

      " #######################################################################
      " ****** PERSONAL SHORTCUTS (LEADER) ******
      " #######################################################################

      nnoremap <Space> <Nop>
      let mapleader = ' '

      " Searches
      nnoremap <silent> <leader><space> :GFiles<CR>
      nnoremap <silent> <leader>ff :Rg<CR>
      inoremap <expr> <c-x><c-f> fzf#vim#complete#path(
        \ "find . -path '*/\.*' -prune -o print \| sed '1d;s:%..::'",
        \ fzf#wrap({'dir': expand('%:p:h')}))

      " Load Git UI
      nnoremap <silent> <leader>gg :G<cr>

      nnoremap <silent> <leader>pp :call <SID>TogglePaste()<cr>
      nnoremap <silent> <leader>sc :call <SID>ToggleScreenMess()<cr>

      " #######################################################################
      " ****** PERSONAL FUNCTIONS ******
      " #######################################################################

      function! s:TogglePaste()
        if &paste
          set nopaste
        else
          set paste
        endif
      endfunction

      " When copying from the buffer in tmux, we wan't to get rid of visual
      " aids like indent lines, line numbering, gutter
      function! s:ToggleScreenMess()
        if &signcolumn ==? "auto"
          " Turn off
          set nonumber nolist norelativenumber signcolumn=no
          exe 'IndentBlanklineDisable'
        else
          " Turn on
          set number list signcolumn=auto
          setlocal relativenumber
          exe 'IndentBlanklineEnable'
        endif
      endfunction

      " #######################################################################
      " ****** COLORING CONTENT ******
      " #######################################################################

      function! s:InitColoring()
        lua require'colorizer'.setup()
        lua require'colorizer'.attach_to_buffer(0)
      endfunction

      augroup MyColoring
        au!
        autocmd VimEnter * call <SID>InitColoring()
      augroup END

      " #######################################################################
      " ****** LINE NUMBERING ******
      " #######################################################################

      " Show line numbers relative to the current cursor line to make repeated
      " commands easier to compose. We only do this while in the buffer.  When
      " focused in another buffer, we use standard numbering.

      function! s:InitLineNumbering()
        " Keep track of current window, since 'windo' chances current window
        let l:my_window = winnr()

        " Global line number settings
        set relativenumber
        set number
        set list
        set signcolumn=auto

        " Setup all windows for line numbering
        windo call s:SetLineNumberingForWindow(0)

        " Go back to window
        exec l:my_window . 'wincmd w'
        "
        " Set special (relative) numbering for focused window
        call s:SetLineNumberingForWindow(1)
      endfunction

      function! s:SetLineNumberingForWindow(entering)
        " Excluded buffers
        if &ft ==? "help" || exists("b:NERDTree")
          return
        endif
        if a:entering
          if &signcolumn ==? "auto"
            " Normal state, turn on relative number
            setlocal relativenumber
          else
            " Visual Indicators Disabled
            setlocal norelativenumber
          endif
        else
          setlocal norelativenumber
        endif
      endfunction

      augroup MyLineNumbers
        au!
        autocmd VimEnter * call <SID>InitLineNumbering()
        autocmd BufEnter,WinEnter * call <SID>SetLineNumberingForWindow(1)
        autocmd WinLeave * call <SID>SetLineNumberingForWindow(0)
      augroup END

      " #######################################################################
      " ****** LSP Configuration ******
      " #######################################################################

      " function! s:InitLSP()
      function! InitLSP()
      lua << EOLUA
        local nvim_lsp = require('lspconfig')
        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          local opts = { noremap=true, silent=true }
          buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
          buf_set_keymap('n', 'gH', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
          buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          buf_set_keymap('n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          buf_set_keymap('n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          buf_set_keymap('n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
          buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
          buf_set_keymap('n', '<space>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

          -- Set some keybinds conditional on server capabilities
          if client.resolved_capabilities.document_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
          elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
          end

          -- Set autocommands conditional on server_capabilities
          if client.resolved_capabilities.document_highlight then
            vim.api.nvim_exec([[
              hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
              augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]], false)
          end
        end

        -- Use a loop to simply setup all language servers
        local servers = { 'bashls', 'dockerls', 'gopls', 'terraformls', 'vimls', 'yamlls' }
        -- Also: { 'sqls', 'rnix', 'efm', 'dartls' }
        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup { on_attach = on_attach }
        end

        -- MS Python language server needs customized config
        nvim_lsp['pyls_ms'].setup {
          on_attach = on_attach,
          InterpreterPah = "${pkgs.python3Full}/bin/python",
          Version = "3.8",
          cmd = { "${pkgs.dotnet-sdk}/bin/dotnet", "exec", "${unstablePkgs.python-language-server}/lib/Microsoft.Python.LanguageServer.dll" }
        }
      EOLUA

        " Re-trigger filetype detection so LSP works on first file
        let &ft=&ft
      endfunction

      augroup MyLSPConfig
        au!
        autocmd VimEnter * call InitLSP()
        " autocmd VimEnter * call <SID>InitLSP()
        autocmd BufEnter * lua require'completion'.on_attach()
      augroup END

      " Use <Tab> and <S-Tab> to navigate through popup menu
      inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      " Always show available completion options, but selection must be manual
      set completeopt=menuone,noinsert,noselect

      " Don't show useless match messages while matching
      set shortmess+=c
    '';
  };

  # home.file."${config.xdg.configHome}/nvim/parser/bash.so".source = "${pkgs.tree-sitter.builtGrammars.bash}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.c}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.cpp}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.go}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/html.so".source = "${pkgs.tree-sitter.builtGrammars.html}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.javascript}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.python}/parser";

  systemd.user.services.wlsunset.Service = {
    Restart = "always";
    RestartSec = 3;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
