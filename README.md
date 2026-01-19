# llvm_build
A repo to build and place llvm builds


On mac
- brew install cmake
- brew install ninja
- checkout the release/21 branch

# ci
Github will build llvm on each commit to main 

Commits to release branches of the form `release-llvmorg-20.1.0` will build and upload the artifacts to the github release.