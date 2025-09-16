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
...