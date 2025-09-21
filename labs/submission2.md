# Lab 2 — Version Control & Advanced Git

## Task 1 — Git Object Model Exploration

### Blob object

command:
```bash
git cat-file -p baec1feeded41be2e899a27ec4b00b0b3b466178
```

output:
```
# Benefits of signing commits

Signing commits using SSH or GPG provides:

-  Author authentication - confirms that the commit was made by the real owner of the key.
- Data integrity - ensures that the commit has not been modified after creation.
- Anti-forgery protection - eliminates the possibility of falsifying the project history.
- Verified label on GitHub - increases trust in the code and its origin.

GitHub keeps the signature verification forever, even if the key is later revoked or expires. SSH signature is easier to set up and can use an existing key.
```

description:

A blob object in Git contains the pure contents of a file, without information about its name, location, or permissions.



### Tree object

command:
```bash
git cat-file -p c9795fb4abcf4af84f78e746b2e047950542518b
```

output:

```
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
040000 tree 88a76b098374b9e73193ba154a2402f900561439    labs
040000 tree 2f0387f9eebb6ad846cd02dbd1e7a4a151c06a7e    lectures
```

description:

A tree object in Git reflects the structure of a directory, linking file names to corresponding blob objects (file contents) or other trees (subfolders).



### Commit object

command:
```bash
git cat-file -p 31636fa8b2607ffaa1f46bd490ce093d191a2d6d
```

output:

```
tree c9795fb4abcf4af84f78e746b2e047950542518b
parent 82d1989821eb80d23d2f29dc297e919f9a0a121b
author Uiyrte <timofey.kurstak@yandex.by> 1758447669 +0300
committer Uiyrte <timofey.kurstak@yandex.by> 1758447669 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAg+baQmrwfNyIlbPwUvrEZ2+FuUj
 lhyrjKOyLPdIhUSt4AAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQDFhJBgtvoqXmG9exZA/xnbWwoJNSn/fulZ4qWiG6gE2KmrUVGcp+Ia9805FRJFlN8
 HwQ+kl4Ie1pah0MerYjQo=
 -----END SSH SIGNATURE-----
```

description:

A Git commit refers to a tree that represents a snapshot of a project and includes metadata such as parent commits, author and committer information, a digital signature, and a commit message.





## Task 2 - Reset and Reflog Recovery



Creating and switching to a new branch
```bash
git switch -c git-reset-practice
```

Output and save the line to a file, add the contents of the working directory to the index (staging area) for subsequent commit. Write changes to the repository.Repeat 3 times for 3 different commits.
```bash
echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
echo "Third commit"  >> file.txt && git add file.txt && git commit -m "Third commit"
```

Displaying the story in a short, one-line format.
```bash
git log --oneline
```

Removing the last commit from the repository. Changes remain indexed and are not removed from staging area.

```bash
git reset --soft HEAD~1
git log --oneline
```

Removing the last commit from the repository. Resets the indexing and removes it from stagibg area.

```bash
git reset --hard HEAD~1
git log --oneline
```

Shows the history of changes to the HEAD pointer.

```bash
git reflog
```

Transfer to a commit with a hash without saving changes.

```bash
git reset --hard a499152 
```

After git reflog
```
28fa0eb (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
a499152 HEAD@{1}: reset: moving to HEAD~1
06f7fac HEAD@{2}: commit: Third commit
a499152 HEAD@{3}: commit: Second commit
```


git log --oneline

After creating 3 commits
```
06f7fac (HEAD -> git-reset-practice) Third commit
a499152 Second commit
28fa0eb First commit
```

After soft reset
```
a499152 (HEAD -> git-reset-practice) Second commit
28fa0eb First commit
```

After hard reset
```
28fa0eb (HEAD -> git-reset-practice) First commit
```

After reflog reset to a499152  
```
a499152 (HEAD -> git-reset-practice) Second commit
28fa0eb First commit
```


 ###Changes
| Reset Option         | File System Snapshot                 | Staging Area Status             | HEAD Position Update                      |
|----------------------|--------------------------------------|----------------------------------|-------------------------------------------|
| `--soft HEAD~1`      | Files remain unchanged               | Staged changes are preserved     | HEAD moves back by one commit             |
| `--hard HEAD@{1}`    | Files restored to earlier state      | Synced with working directory    | HEAD reset to a previous reference point  |
| `--hard HEAD~1`      | Files revert to the prior commit     | Synced with working directory    | HEAD moves back by one commit             |
| `--hard <commit>`    | Files updated to match given commit  | Synced with working directory    | HEAD set to the specified commit          |


## Task 3 — Visualize Commit History
### Snippet of the graph

```bash
* 177621e (git-reset-practice) Side branch commit
| * b829c23 (HEAD -> side-branch) Side branch commit
|/  
* a499152 Second commit
* 28fa0eb First commit
* 31636fa (origin/feature/lab1, feature/lab1) docs: add commit signing summary
| * a382c03 (origin/main, origin/HEAD, main) docs: add PR template
|/  
* 82d1989 feat: publish lab3 and lec3
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

### Commit messages list
- Side branch commit
- Second commit
- First commit
- docs: add PR template
- docs: add commit signing summary
- feat: publish lab3 and lec3
- feat: publish lec2
- feat: publish lab2
- feat: update lab1
- Publish lab1
- Publish lec1
- Publish README.md

### Reflection
The graph visualizes the repository’s branching structure, clearly illustrating where branches split off and how individual commits are connected.  
This provides insight into the project's evolution and clarifies how different branches relate to one another.

## Task 4 — Tagging Commits
# Move to the lab branch
git switch -c feature/lab2

# Add a lightweight tag named 'v1.0.0' to the current commit
git tag v1.0.0

# Display details of the commit associated with the tag
git show v1.0.0

# Upload the tag to the remote repository named 'origin'
git push origin v1.0.0


### Tag Name 
Tag: v1.0.0
- Commit Hash: b829c23c7d330f2044658890e59a73e16d490073

### Notes
Tags serve as reference markers for key moments in a project's history, typically used to designate official releases. They play a crucial role in version control, help initiate CI/CD workflows, and assist in producing release notes—providing a reliable pointer to stable or production-ready code.

## Task 5 — git switch vs git checkout vs git restore
### Branch Switching with `git switch`
Command:
```bash
git switch feature/lab2
```
Output:
```
Already on 'feature/lab2'
Your branch is up to date with 'origin/feature/lab2'.
```


Creating a new branch cmd-compare and switching.
Command:
```bash
git switch -c cmd-compare
```
Output:
```
Switched to a new branch 'cmd-compare'
```

Switching back to the feature/lab2.

Command:
```bash
git switch -
```
Output:
```
Switched to branch 'feature/lab2'
Your branch is up to date with 'origin/feature/lab2'.
```

Command:
```bash
git branch
```

Showing all branches and indicates the current branch with *.

Output:
```bash
  cmd-compare
  feature/lab1
* feature/lab2
  git-reset-practice
  main
  side-branch
```


### Branch Creation with Legacy `git checkout`

Command:
```bash
git checkout -b cmd-compare-2
```

Creating and switching to a new branch (cmd-compare-2) using the legacy git checkout command

Output:
```
Switched to a new branch 'cmd-compare-2'
```


Command:
```bash
git branch
```
'cmd-compare-2' now is the current brunch

Output:
```bash
  cmd-compare
* cmd-compare-2
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```



### Working with Files Using `git restore`
Command:
```bash
echo "scratch" >> demo.txt
git status
git add demo.txt
```
Save text to the file. Add file to staging.

Output:
```
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        demo.txt
```



Command:
```bash
git restore demo.txt
git status
```
Discards changes only in the working directory.
Output:
```
On branch cmd-compare-2
Changes to be committed:
        new file:   demo.txt
```



Command:
```bash
git restore --staged demo.txt
git status
```

Removing the file from staging area.
Output:
```
On branch cmd-compare-2
Untracked files:
        demo.txt
```


Command:
```bash
git add demo.txt
git restore --source=HEAD~1 demo.txt
git status
```
Output:
```
On branch cmd-compare-2
Changes to be committed:
        new file:   demo.txt
Changes not staged for commit:
        deleted:    demo.txt
```



### Summary of Differences
| Command                          | Description                                                                 |
|----------------------------------|------------------------------------------------------------------------------|
| `git switch`                     | Modern command for changing branches or creating new ones.                  |
| `git checkout -b`               | Older method to create and switch branches; also used for file restoration. |
| `git restore <file>`            | Reverts changes in the working directory for tracked files.                 |
| `git restore --staged <file>`   | Unstages files without modifying their content in the working directory.    |
| `git restore --source=<commit>` | Retrieves a file from a specific commit; removes it if it didn’t exist then.|

### Bonus
Stars help highlight valuable projects and make them easier to find. Following contributors fosters collaboration and keeps the team updated on each other's work.