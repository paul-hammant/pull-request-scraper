#!/bin/bash

touch .nojekyll

# Your destination repo without your username prefix
GHRepo="Paranamer_PRs"

# Make the repo public, navigate to the Pull requests you want to extract.
# Be sure to click on "closed", if those are the ones you want, then paste the URL below.
# You can append a second++ starting point here (as lines) ...
echo "https://github.com/paul-hammant/paranamer/pulls?q=is%3Apr+is%3Aclosed" > starting_urls.txt
#echo "https://github.com/fred_flintstone/someRepo/pulls?q=is%3Apr+is%3Aclosed" >> starting_urls.txt
#echo "https://github.com/barney-rubble/someOtherRepo/pulls?q=is%3Apr+is%3Aclosed" >> starting_urls.txt

echo "get get lists of pull requests ..."

wget --mirror --no-parent --no-host-directories -q --adjust-extension -i starting_urls.txt
rm starting_urls.txt

[ -f pull_requests.txt ] && rm pull_requests.txt
find . -name "*.html" | xargs -I {} cat {} | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort | uniq | grep "/pull/" >> pull_requests.txt

# rename unservable pages
find . -name "*\?*.html" -exec sh -c 'mv $0 `echo "$0" | sed "s/\?/-/g" | sed "s/\=/-/g" | sed "s/%3A/-/g" | sed "s/\+/-and-/g" | sed "s/-q-/-/g" `' '{}' \;

find . -type f -name "*.html" -exec sed -i '' "s# href=\"/\(.*\)\$# href=\"/$GHRepo/\1#" {} +

# Main index page is made from the starter URLs.
echo "<html><body><ul>" > index.html
for pulls_file in $(find . -name "*pulls*")
do
    echo "<li><a href="${pulls_file}">${pulls_file}</a></li>" >> index.html
done
echo "</ul></body></html>" >> index.html

echo "get pull request urls ..."
[ -f pull_request_urls.txt ] && rm pull_request_urls.txt
while read pr; do
  echo "https://github.com/${pr}" >> pull_request_urls.txt
  echo "https://github.com/${pr}/commits" >> pull_request_urls.txt
  echo "https://github.com/${pr}/files" >> pull_request_urls.txt
done <pull_requests.txt
rm pull_requests.txt

wget --mirror --page-requisites --adjust-extension --no-parent --convert-links -nH -q -i pull_request_urls.txt
rm pull_request_urls.txt

echo "get commits ..."
find . -name "*.html" | xargs -I {} cat {} | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort | uniq | grep "/commit/" > commits.txt
wget --page-requisites --adjust-extension --no-parent --convert-links -nH -q -i commits.txt
rm commits.txt

find . -type f -name "*.html" -exec sed -i '' "s#https://github.com#/$GHRepo#g" {} +
find . -type f -name "*.html" -exec sed -i '' 's#/files"#/files.html"#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#/commits"#/commits.html"#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#/commit/\([[:alnum:]]*\)\" class#/commit/\1.html" class#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#/pull/\([[:alnum:]]*\)\" class#/commit/\1.html" class#g' {} +
find . -type f -name "*.html" -exec sed -i '' "s#stylesheets/#/$GHRepo/stylesheets/#g" {} +

# delete or neutralize some UI "action" bits that can't work as this will be a static site
find . -type f -name "*.html" -exec sed -i '' 's#<a .*class=".*btn.*".*/a>##g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#<span .*class=".*octicon.*".*/span>##g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="btn.*"\(.*\)$#\1 style="display: none;"class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="social-count.*"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="site-footer"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="header .*"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="issues-reset-query-wrapper"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="subnav"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +
find . -type f -name "*.html" -exec sed -i '' 's#^\(.*\) class="protip"\(.*\)$#\1 style="display: none;" class=""\2#g' {} +

# delete or change bits that change too much (guids etc)

find . -type f -name "*.html" -exec sed -i '' '/<meta content=\"collector\.githubapp\.com\"/d' {} +
find . -type f -name "*.html" -exec sed -i '' '/name=\"csrf-token\"/d' {} +
find . -type f -name "*.html" -exec sed -i '' '/clone-selector-form/d' {} +
find . -type f -name "*.html" -exec sed -i '' '/\.js\"><\/script>/d' {} +
find . -type f -name "*.html" -exec sed -i '' 's#<li>\&copy; 201[[:digit:]] <span title=\".*\">GitHub</span>, Inc.</li>#<li>\&copy; 2015+ Github, Inc.</li>#' {} +

# delete avatars

find . -type f -name "*.html" -exec sed -i '' '/<img .* class=\".*avatar.*\"/d' {} +

# CSS and images

ack -h --html 'href="([^"#]+)"' | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort | uniq | grep ".css$" > static_resources.txt
ack -h --html 'src="([^"#]+)"' | grep -o -E 'src="([^"#]+)"' | cut -d'"' -f2 | sort | uniq | grep "^http" | grep -v "\.js$" >> static_resources.txt

echo "get static resources ..."
wget --load-cookies cookies.txt --adjust-extension --cut-dirs=4 -q -nc -E -H -K -i static_resources.txt 2>&1 | sed '/Last-modified header missing/d'

rm static_resources.txt

# Fix relative URLS

find . -type f -name "*.html" -exec sed -i '' "s#https://assets-cdn.github.com/images/spinners/#/$GHRepo/#" {} +
find . -type f -name "*.html" -exec sed -i '' "s#https://assets-cdn.github.com/assets/github/#/$GHRepo/#" {} +
find . -type f -name "*.html" -exec sed -i '' "s#https://avatars[[:digit:]].githubusercontent.com/u/#/$GHRepo/#" {} +
find . -type f -name "*.html" -exec sed -i '' "s#https://assets-cdn.github.com/#/$GHRepo/#" {} +
find . -type f -name "*.html" -exec sed -i '' "s#/assets/github2/#/#" {} +