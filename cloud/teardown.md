# Teardown

## Render web service

1. Open https://dashboard.render.com
2. Select the `quicknotes` service
3. Settings → scroll to the bottom → Delete Web Service
4. Confirm by typing the service name

Cost if left running: $0. Free instances are billed at nothing and spin down
when idle; the 750 free instance-hours per month are not exceeded by a single
mostly-idle service.

## ghcr.io package

The container image stays in GitHub Packages. To remove it:

1. https://github.com/users/HNS2112/packages/container/devops-intro%2Fquicknotes/settings
2. Danger Zone → Delete this package

Cost if left in place: $0 for public packages.

## Git tag

`git push --delete origin v0.1.0` removes the remote tag; `git tag -d v0.1.0`
removes it locally. Deleting the tag does not delete the already-published
image.
