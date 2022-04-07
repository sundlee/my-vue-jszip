@echo off

cmd /C npm run build

cd dist
git init
git add -A
git commit -m "deploy with dist directory"
git push -f https://sundlee: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@github.com/sundlee/my-vue-jszip.git master:gh-pages

cd ..
