Follow these steps to deploy your dotfiles onto a new machine.

1.  **Clone the Bare Repository.**
    ```bash
    git clone --bare --depth 1 https://github.com/fayizshaffaq/.git_dotfiles_dir.git $HOME/.git_dotfiles_dir
    ```

2.  **Set up the Alias.** Add the same `git_dotfiles` alias to the new machine's `~/.zshrc` or `~/.bashrc` and `source` the file.
    ```bash
    alias git_dotfiles='/usr/bin/git --git-dir=$HOME/.git_dotfiles_dir/ --work-tree=$HOME'
    ```

3.  **Check Out Your Configuration.** This command will populate your `$HOME` directory with the files from the repository.
    ```bash
    git_dotfiles checkout -f
    ```
    > [!WARNING] Potential for Overwriting Files
    > Use this with caution. It is often what you want on a fresh system, but consider backing up the default files first.

4.  **Finalize Setup.** Repeat the prerequisite steps from Part 1 to configure your Git user name and email on the new machine. Your system is now synced.
