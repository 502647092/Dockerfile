var fs = require('fs')
var process = require('child_process');
var https = require('https')

function post(name) {
    return new Promise(function(resolve, reject) {
        var req = https.request({
            host: 'marketplace.visualstudio.com',
            path: '/_apis/public/gallery/extensionquery',
            method: 'POST',
            json: true,
            headers: {
                'content-type': 'application/json',
                'accept': 'application/json;api-version=6.0-preview.1;excludeUrls=true'
            }
        }, function(res) {
            var data = '';
            res.on('data', function(chunk) {
                data += chunk;
            });
            res.on('end', function() {
                resolve(data);
            })
            res.on('error', function(err) {
                reject(err);
            });
        })
        req.on('error', err => {
            reject(err);
        })
        req.write(JSON.stringify({
            "filters": [{
                "criteria": [{
                    "filterType": 7,
                    "value": name
                }],
                "pageNumber": 1,
                "pageSize": 1,
                "sortBy": 0,
                "sortOrder": 0
            }],
            "assetTypes": ["Microsoft.VisualStudio.Services.VSIXPackage"],
            "flags": 131
        }));
        req.end();
    })
}

async function main() {
    var package = JSON.parse(fs.readFileSync('package.json').toString())
    for (adapter of package.plugins) {
        console.log(`Get ${adapter} download url...`)
        if (adapter.startsWith('#')) { continue; }
        if (adapter.startsWith('@theia/vscode-builtin')) {
            delete package.adapters[adapter]
            package.adapters[adapter.split('/')[1]] = process.execSync(`npm info ${adapter}@next dist.tarball`).toString().replace('\n', '')
        } else {
            var args = adapter.split('.')
            var publisher = args[0]
            var asset = args[1]
            // process.execSync(`./build.sh ${adapter}`)
            var json = await post(adapter)
            // var pluginPackage = JSON.parse(fs.readFileSync('extension.info').toString())
            var pluginPackage = JSON.parse(json);
            var varsion = pluginPackage.results[0].extensions[0].versions[0].version
            package.adapters[adapter] = `https://ms-vscode.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${asset}/${varsion}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage`
        }
    }
    fs.writeFileSync('package.json', JSON.stringify(package, undefined, 4))
}
main()
