## Task 1
```shell
[rightrat@RatLaptop F25-DevOps-Intro]$ git ls-tree HEAD
040000 tree fcec086acea0c6a015dbd056ef3bcb449b950bbd    .github
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
040000 tree d2759bc92060101699b9848d2b0478df00de55b1    labs
040000 tree 2f0387f9eebb6ad846cd02dbd1e7a4a151c06a7e    lectures
100644 blob c7176d17cdf07862b26a567dbfd4f90d49131205    test.txt

[rightrat@RatLaptop F25-DevOps-Intro]$ git log
commit 1d89b9cd6b7282ec49ca7ff45a93321bc27acccb (HEAD -> feature/lab2)
Author: Ivan Smirnov <rightrat42@gmail.com>
Date:   Tue Sep 16 20:07:07 2025 +0300

    docs: modified the test file

commit fa6ad7207b8db5c821b3d4beb472aa39d7325462
Author: Ivan Smirnov <rightrat42@gmail.com>
Date:   Tue Sep 16 19:29:51 2025 +0300

    docs: added a file for a test commit
```

```shell
[rightrat@RatLaptop F25-DevOps-Intro]$ git cat-file -p c7176d17cdf07862b26a567dbfd4f90d49131205

This is a test message inside of a test.txt[rightrat@RatLaptop F25-DevOps-Intro]$
[rightrat@RatLaptop F25-DevOps-Intro]$ git cat-file -p d2759bc92060101699b9848d2b0478df00de55b1
100644 blob b1f8af089a94f160ce00ed7710f07a7e9ba6c584    lab1.md
100644 blob 1468ba02d6bcacd3fee5fd378cc02717a8cb2fbc    lab2.md
100644 blob 890d3c25c2ea110419b0fd28afbeb468cb97a171    lab3.md

[rightrat@RatLaptop F25-DevOps-Intro]$ git cat-file -p 1d89b9cd6b7282ec49ca7ff45a93321bc27acccb
tree 2318b44fd990660aa3d0ad6ce4d23e3d260f13ac
parent fa6ad7207b8db5c821b3d4beb472aa39d7325462
author Ivan Smirnov <rightrat42@gmail.com> 1758042427 +0300
committer Ivan Smirnov <rightrat42@gmail.com> 1758042427 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgjrAoPDZ5jDNrKMpnsK9laT5sn6
 /5KC6/DD/xS6/LeVwAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQC0DBOnS8pWBONhpar3KzKf8dmdRVN+esBGoGhrNMyKDMHfezm416sPMOJ64qxfule
 TSpwY347Hqm7FVETUpmwU=
 -----END SSH SIGNATURE-----

docs: modified the test file
```
As can be seen by executing the __git cat-file__ command, git stores files as blobs, the trees consist of blobs that they contain and commits contain the changes with the signature and common information attached.

## Task 2
```shell
[rightrat@RatLaptop F25-DevOps-Intro]$ git reset --soft HEAD~1

[rightrat@RatLaptop F25-DevOps-Intro]$ git reset --hard HEAD~1
HEAD is now at 4326e3d First commit

[rightrat@RatLaptop F25-DevOps-Intro]$ git reflog
4326e3d (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
29b0855 HEAD@{1}: reset: moving to HEAD~1
dadc728 HEAD@{2}: commit: Third commit
29b0855 HEAD@{3}: commit: Second commit
4326e3d (HEAD -> git-reset-practice) HEAD@{4}: commit: First commit
1d89b9c (feature/lab2) HEAD@{5}: checkout: moving from feature/lab2 to git-reset-practice

[rightrat@RatLaptop F25-DevOps-Intro]$ git reset --hard dadc728
HEAD is now at dadc728 Third commit
```
The first reset reverted the files but not the working tree
The second reset reverted the files and the working tree 
The third reset reverted the repository to the toint of "Third commit" because I decided so

## Task 3
```shell
[rightrat@RatLaptop F25-DevOps-Intro]$ git log --oneline --graph --all
* 15ae186 (side-branch) Side branch commit
* dadc728 (HEAD -> git-reset-practice) Third commit
* 29b0855 Second commit
* 4326e3d First commit
* 1d89b9c (feature/lab2) docs: modified the test file
* fa6ad72 docs: added a file for a test commit
*   bab3f23 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
|\  
| * 82d1989 feat: publish lab3 and lec3
| * 3f80c83 feat: publish lec2
| * 499f2ba feat: publish lab2
| | * fb33338 (origin/feature/lab1, feature/lab1) docs: add commit signing summary
:...skipping...
* 15ae186 (side-branch) Side branch commit
* dadc728 (HEAD -> git-reset-practice) Third commit
* 29b0855 Second commit
* 4326e3d First commit
* 1d89b9c (feature/lab2) docs: modified the test file
* fa6ad72 docs: added a file for a test commit
*   bab3f23 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
|\  
| * 82d1989 feat: publish lab3 and lec3
| * 3f80c83 feat: publish lec2
| * 499f2ba feat: publish lab2
| | * fb33338 (origin/feature/lab1, feature/lab1) docs: add commit signing summary
| |/  
|/|   
* | 9def799 docs: added PR template
|/  
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
:
```
The git graph allows for an easier understanding of the repo structure and history.

## Task 4
```shell
[rightrat@RatLaptop F25-DevOps-Intro]$ git tag v1.0.0
[rightrat@RatLaptop F25-DevOps-Intro]$ git push origin v1.0.0
Enumerating objects: 16, done.
Counting objects: 100% (16/16), done.
Delta compression using up to 8 threads
Compressing objects: 100% (10/10), done.
Writing objects: 100% (15/15), 1.69 KiB | 1.69 MiB/s, done.
Total 15 (delta 9), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (9/9), completed with 1 local object.
To https://github.com/RightRat42/F25-DevOps-Intro.git
 * [new tag]         v1.0.0 -> v1.0.0
[rightrat@RatLaptop F25-DevOps-Intro]$ git reflog
dadc728 (HEAD -> git-reset-practice, tag: v1.0.0) HEAD@{0}: checkout: moving from side-branch to git-reset-practice
15ae186 (side-branch) HEAD@{1}: commit: Side branch commit
dadc728 (HEAD -> git-reset-practice, tag: v1.0.0) HEAD@{2}: checkout: moving from git-reset-practice to side-branch
dadc728 (HEAD -> git-reset-practice, tag: v1.0.0) HEAD@{3}: reset: moving to dadc728
4326e3d HEAD@{4}: reset: moving to HEAD~1
29b0855 HEAD@{5}: reset: moving to HEAD~1
dadc728 (HEAD -> git-reset-practice, tag: v1.0.0) HEAD@{6}: commit: Third commit
29b0855 HEAD@{7}: commit: Second commit
4326e3d HEAD@{8}: commit: First commit
1d89b9c (feature/lab2) HEAD@{9}: checkout: moving from feature/lab2 to git-reset-practice
1d89b9c (feature/lab2) HEAD@{10}: commit: docs: modified the test file
fa6ad72 HEAD@{11}: rebase (finish): returning to refs/heads/feature/lab2
fa6ad72 HEAD@{12}: rebase (start): checkout 0e184aebfaa74dd6f915cd67a0856e3d097e1324^
0e184ae HEAD@{13}: rebase (finish): returning to refs/heads/feature/lab2
0e184ae HEAD@{14}: rebase (start): checkout 876815236f747f1355a62ebca5fad23e33f4073b^
8768152 HEAD@{15}: revert: Revert "docs: removed the file for a commit"
0e184ae HEAD@{16}: commit: docs: removed the file for a commit
fa6ad72 HEAD@{17}: commit: docs: added a file for a test commit
bab3f23 (origin/main, origin/HEAD, main) HEAD@{18}: checkout: moving from main to feature/lab2
```
Tags let the developer know the repo state from a glance if the tags mean something (e.g. version number, is/is not for test and similar)

## Task 5
```shell
rightrat@RatLaptop F25-DevOps-Intro]$ git switch -c cmd-compare
Switched to a new branch 'cmd-compare'
[rightrat@RatLaptop F25-DevOps-Intro]$ git switch -
Switched to branch 'git-reset-practice'
[rightrat@RatLaptop F25-DevOps-Intro]$ git checkout -b cmd-compare-2
Switched to a new branch 'cmd-compare-2'
[rightrat@RatLaptop F25-DevOps-Intro]$ echo "scratch" >> demo.txt
[rightrat@RatLaptop F25-DevOps-Intro]$ git status
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        demo.txt
        labs/submission2.md
[rightrat@RatLaptop F25-DevOps-Intro]$ git add demo.txt
[rightrat@RatLaptop F25-DevOps-Intro]$ git status
On branch cmd-compare-2
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md
[rightrat@RatLaptop F25-DevOps-Intro]$ git restore --staged demo.txt 
[rightrat@RatLaptop F25-DevOps-Intro]$ git status
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        demo.txt
        labs/submission2.md
[rightrat@RatLaptop F25-DevOps-Intro]$ echo "scratch" >> demo.txt
[rightrat@RatLaptop F25-DevOps-Intro]$ git add .
[rightrat@RatLaptop F25-DevOps-Intro]$ git commit -m "added scratch"
[cmd-compare-2 f9a8b2c] added scratch
 1 file changed, 1 insertion(+)
 create mode 100644 demo.txt
[rightrat@RatLaptop F25-DevOps-Intro]$ git restore --source=HEAD~1 demo.txt
[rightrat@RatLaptop F25-DevOps-Intro]$ git add .
[rightrat@RatLaptop F25-DevOps-Intro]$ git commit
[cmd-compare-2 5100926] delete
 1 file changed, 1 deletion(-)
 delete mode 100644 demo.txt
```
I would use __restore --staged__ to to change something I didn't do 1hr ago (so pre-commit)
Restoring to a head version is a bit depressing, but sometimes you gotta start from scratch