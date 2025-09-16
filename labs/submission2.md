task 1:
PS C:\Users\egors\F25-DevOps-Intro> git cat-file -p e9edf488e7082d5688545be6c38c44076a039bb9
Signed commits are needed so that you can be sure the changes were actually made by the person shown in the git history. This helps the team and everyone working on the project trust that nobody faked a commit or secretly added malicious code. For big or open-source projects, this really matters for security and trust in the repo.
PS C:\Users\egors\F25-DevOps-Intro> git cat-file -t e9edf488e7082d5688545be6c38c44076a039bb9
blob
PS C:\Users\egors\F25-DevOps-Intro> git cat-file -s e9edf488e7082d5688545be6c38c44076a039bb9
332git switch -c feature/lab2

task 2:
HEAD is now at 3f80c83 feat: publish lec2
3f80c83 (HEAD -> feature/lab2) HEAD@{0}: reset: moving to HEAD~1
82d1989 (upstream/main, upstream/HEAD) HEAD@{1}: reset: moving to HEAD~1
d79dd71 HEAD@{2}: reset: moving to HEAD~1


task 3:
PS C:\Users\egors\F25-DevOps-Intro> git log --graph --oneline --all
* 43f9d79 (HEAD -> feature/lab2, origin/feature/lab2) submission 2
| * 3643ad5 (origin/main, origin/HEAD, main) docs: add commit signing summary
| * d79dd71 docs: add commit signing summary
| * 82d1989 (upstream/main, upstream/HEAD) feat: publish lab3 and lec3
|/
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md

PS C:\Users\egors\F25-DevOps-Intro> git tag v1.0.0
PS C:\Users\egors\F25-DevOps-Intro> git push origin v1.0.0
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/Clothj/F25-DevOps-Intro.git
 * [new tag]         v1.0.0 -> v1.0.0

task 5:
PS C:\Users\egors\F25-DevOps-Intro> git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'

PS C:\Users\egors\F25-DevOps-Intro> git checkout main
Already on 'main'
Your branch is up to date with 'origin/main'.

PS C:\Users\egors\F25-DevOps-Intro> git restore submission2.md 
error: pathspec 'submission2.md' did not match any file(s) known to git