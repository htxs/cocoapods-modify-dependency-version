A checklist for releasing the Gem:

* Test: `rake`
* Bump version in lib/cocoapods_modify_dependency_version.rb
* Commit
* `git tag x.y.z`
* `git push`
* `git push --tags`
* `gem build cocoapods-modify-dependency-version.gemspec`
* `gem push cocoapods-modify-dependency-version-x.y.z.gem`
* Create release on GitHub from tag
