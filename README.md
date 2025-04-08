# sync-branches

`sync-branches.ps1` is a simple powershell script that can be used to manage branches on a local git repository. It fetches branches from origin, pruning stale local branches. It also checks for and tracks new remote branches.

## usage:

```
Usage: .\sync-branches.ps1 [-Force] [-List] [-Help]
  -Force : Force delete untracked local branches
  -List  : List remote branches after sync
  -Help  : Show this message
```
