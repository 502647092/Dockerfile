var fs = require('fs')
var process = require('child_process');

var package = JSON.parse(fs.readFileSync('package.json').toString())
for (adapter of package.plugins) {
    if (adapter.startsWith('@theia/vscode-builtin')) {
        delete package.adapters[adapter]
        package.adapters[adapter.split('/')[1]] = process.execSync(`npm info ${adapter}@next dist.tarball`).toString().replace('\n', '')
    } else {
        var args = adapter.split('.')
        var publisher = args[0]
        var asset = args[1]
        process.execSync(`./build.sh ${adapter}`)
        var pluginPackage = JSON.parse(fs.readFileSync('extension.info').toString())
        var varsion = pluginPackage.results[0].extensions[0].versions[0].version
        package.adapters[adapter] = `https://ms-vscode.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${asset}/${varsion}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage`
    }
}

fs.writeFileSync('package.json', JSON.stringify(package, undefined, 4))
