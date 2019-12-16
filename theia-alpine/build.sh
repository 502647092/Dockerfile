getVersion() {
    local RESULT=$(curl -qsSL 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
    -H 'content-type: application/json' \
    -H 'accept: application/json;api-version=6.0-preview.1;excludeUrls=true' \
    --data-binary '{"filters":[{"criteria":[{"filterType":7,"value":"'${1}'"}],"pageNumber":1,"pageSize":1,"sortBy":0,"sortOrder":0}],"assetTypes":["Microsoft.VisualStudio.Services.VSIXPackage"],"flags":131}')
    node -pe 'JSON.parse(process.argv[1]).results[0].extensions[0].versions[0].version' "${RESULT}"
}
getVersion ${1}
