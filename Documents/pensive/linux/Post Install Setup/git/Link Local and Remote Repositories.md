### Step 9: Link Local and Remote Repositories

1.  **Get the SSH URL** from your new, empty GitHub repository page. It should look like `git@github.com:username/repo.git`.

2.  **Add the remote** to your local repository's configuration.
    ```bash
    git_dotfiles remote add origin git@github.com:fayizshaffaq/.git_dotfiles_dir.git
    ```

3.  **Set the URL.**
    ```bash
    git_dotfiles remote set-url origin git@github.com:fayizshaffaq/.git_dotfiles_dir.git
    ```

4.  **Verify the connection.**
    ```bash
    ssh -T git@github.com
    ```
    You may see a one-time warning about the host's authenticity; type `yes` and press Enter. A success message will include your GitHub username. The message "GitHub does not provide shell access" is normal and expected.
