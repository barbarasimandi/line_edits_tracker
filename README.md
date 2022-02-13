# Line Edits Tracker

This program aims to find specific lines of files in a pull request, which were affected by multiple commits.

At the end of the 4th hour working on this project, the program is able to find files in a pull request, 
edited in multiple commits.

### Setup

In order to send more than 60 requests in an hour, you have to authorize the application by creating a 
[token](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#requests-from-user-accounts).

You should then save it to a `.bearer` file.

### Next steps

1) Match on file's `"patch"` field (with something like `/@@(.*?)\@@/`) in order to see specific line changes
2) Only copy files and specific lines if the exact lines have been changed by multiple commits 
3) Implement a more object oriented way, introduce classes/modules
4) Find ways to increase performance
5) Get all ~28.700 pull requests, and work with that bigger data
