# clean-path.vim

A clean way of adding directories and files to VIM's `&path`.

## Rationale

As said in the article ["Off the beaten path"](https://gist.github.com/romainl/7e2b425a1706cd85f04a0bd8b3898805), the lazy way of setting VIM's path may actually harm the performance of common commands (`:find`, `:tabfind`, etc), and setting `wildignore` to remove some large directories (that pesky `node_modules` comes to mind) doesn't really do anything to reduce the performance hit. Quoting from the article, "`&wildignore` is only applied after the search, to build the list of candidate for `:help wildmenu`, it is only used for the wildmenu so it is only used for the `:find` family of commands."

That being said, instead of using the classic `set path+=**` hack to allow VIM to have it's own "fuzzy finder", this plugin only adds exactly what is needed to the path.

## How it works

1. Find current git directory (doesn't matter how deep you're in the tree)
2. Read `.gitignore` from root git directory
3. Only add directories and files that are not present in the `.gitignore`

#### Notes

-   If not in a git project, it'll simply use the the current directory `.gitignore`
-   If no `.gitignore` is available, it'll populate the `&path` but not using `**`
-   Deeply nested `.gitignore` in a git project are simply ignored
-   The classic `!` char is also ignored (otherwise some heavy logic would be required)

## Install

Any plugin manager should work (at least the ones that fetch data from GitHub). Below are a few ways you can do it.

#### VIM's 8+ package manager

In the terminal

```bash
git clone https://github.com/Guergeiro/clean-path.vim.git ~/.vim/pack/vendor/start/clean-path.vim
```

In your `.vimrc`

```vim
packloadall
```

#### [Vundle.vim](https://github.com/VundleVim/Vundle.vim)

```vim
call vundle#begin('~/.vim/plugged')
Plugin 'VundleVim/Vundle.vim'
Plugin 'Guergeiro/clean-path.vim'
call vundle#end()
```

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
call plug#begin('~/.vim/plugged')
Plug 'Guergeiro/clean-path.vim'
call plug#end()
```

## Available Configurations

```vim
" Automatically adds the .gitginore to &wildignore. Useful for other plugins.
let g:clean_path_wildignore = 1
```

## Credit

This plugin was heavily inspired by a [plugin](http://www.vim.org/scripts/script.php?script_id=2557) that sets your `wildignore` based on your `.gitignore`, by Adam Bellaire (I was actually using this before reading the article).

Some coding was adapted from the reddit user [kristijanhusak](https://www.reddit.com/user/kristijanhusak/).

Thanks to [romainl](https://github.com/romainl) for helping me understanding a bunch about VIM. Check out some of the [topics](https://gist.github.com/romainl/4b9f139d2a8694612b924322de1025ce) he covers!

## License

This plugin was released under the [MIT License](./LICENSE).
