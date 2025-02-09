## init
dart pub global activate melos

export $PATH:...

melos exec -- flutter pub upgrade --major-versions

## sync master
git remote add upstream https://github.com/media-kit/media-kit.git

git fetch upstream

git merge upstream/master
