# pull-request-scraper

Scraping Github Pull Requests via a bash script.

This will make a static navigable site of Github Pull-Requests, and the association commits, inclusing code-review comments.

First make a Github-pages repo. You only need the gh-pages branch, so sckip the auto-creation of the readme and the .gitignore files as you make the repo online.  Next go to settings. In there run the gh-pages wizard (pick any theme). Now clone. Only the gh-pages branch came down - neat huh?  Next delete the generated files (stylesheets, js, everything) and commit/push.

Now cd to that directory and run the scrape-pull-requests.sh script there (after editing it).  Git add/commit/push.  Navigate to http://YOUR_GH_ID.github.io/THE_NEW_REPO/ and you're good to go.

Of course I could have parameterized the script (sorry).

Refer also [http://paulhammant.com/2015/06/27/scraping-github-pull-requests-and-their-code-review-comments/](http://paulhammant.com/2015/06/27/scraping-github-pull-requests-and-their-code-review-comments/)
