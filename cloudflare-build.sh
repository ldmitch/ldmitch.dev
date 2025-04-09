if [ "$CF_PAGES_BRANCH" = "main" ]; then
  ./hugo --minify  --disableHugoGeneratorInject
else
  ./hugo -b "$CF_PAGES_URL"  --disableHugoGeneratorInject
fi
