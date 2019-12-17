# cocoapods-modify-dependency-version

cocoapods-modify-dependency-version will try to modify specific dependency version by branch name or tag.

## Installation

    $ gem install cocoapods-modify-dependency-version

## Usage

`pod modify-dependency-version` will display a list of Pods that changed by this command.

    $ pod modify-dependency-version --name=SuiNetworking --branch=test
    ~SuiNetworking

The symbol before each Pod name indicates the status of the Pod. A `~` indicates specific dependency has been modified.

Verbose mode shows a bit more detail:

    $ pod modify-dependency-version --name=SuiNetworking --branch=test --verbose
    SuiNetworking current_branch: master -> modify_branch: test

If the specific dependency not in the Podfile, then the output looks like:

    $ pod modify-dependency-version --name=FakeRepo --branch=test
    FakeRepo not found.
    
## License

cocoapods-modify-dependency-version is under the MIT license. See the [LICENSE](LICENSE) file for details.

