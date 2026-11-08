# Project workflow

- Execute work and verification locally; do not use Codex Cloud or remote execution environments.
- Canonical remote: https://github.com/xiruidracozou/-app.git (`origin`). Default integration branch: `main`.
- The user explicitly authorizes repository synchronization and pushes for this project. This supersedes the earlier no-push preference for this repository only; deployment and publishing remain unauthorized unless requested.
- Before each task, inspect working-tree changes and fetch the remote. Bring the current branch up to date with its upstream without discarding local work. Prefer fast-forward updates; resolve divergence carefully and never force-push or reset away user changes.
- After each task that changes project files, run relevant checks, review the diff, commit the intended files, and push to the corresponding remote branch. Verify synchronization and report any failure accurately. Do not create empty commits for read-only tasks.
- Preserve other remote branches. Do not merge separate implementations merely to synchronize the repository.
- Do not commit credentials, local tool state, build artifacts, or unrelated files.
