var fs = require('fs')
var process = require('child_process');

var package = JSON.parse(fs.readFileSync('package.json').toString())
for (adapter in package.adapters) {
    var args = adapter.split('.')
    var publisher = args[0]
    var asset = args[1]
    var varsion = process.execSync('./build.sh ' + adapter).toString().replace('\n', '')
    package.adapters[adapter] = `https://ms-vscode.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${asset}/${varsion}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage`
}

fs.writeFileSync('package.json', JSON.stringify(package, undefined, 4))
