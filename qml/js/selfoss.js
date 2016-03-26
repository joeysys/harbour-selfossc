.pragma library

.import "storage.js" as Storage


var site;
var user;
var passwd;

function readSettings() {
    site = Storage.readSetting('site');
    user = Storage.readSetting('user');
    passwd = Storage.readSetting('passwd');
}

function request(method, path, params, callback) {
    if (!site) {
        callback({"msg": "site not set"});
        return;
    }

    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
        //console.log('http ready: ' + xhr.readyState);
        if (xhr.readyState === 4) {
            //console.log('http status: ' + xhr.status);
            if (xhr.status === 200) {
                var resp = JSON.parse(xhr.responseText);
                typeof(callback) === 'function' && callback(resp);
            } else {
                console.log(xhr.responseText);
                callback({"msg": xhr.responseText});
            }
        }
    }

    if (method === 'POST') {
        xhr.open(method, genUrl(path, ''), true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send(params);
    } else {    // GET, DELETE
        xhr.open(method, genUrl(path, params), true);
        xhr.send();
    }
}

function genUrl(path, params) {
    if (params !== '') { params += '&' }
    params += 'username=' + user + '&password=' + passwd;
    if (params[0] !== '?') { params = '?' + params; }
    //console.log(site + path + params)
    return site + path + params;
}

function listSources(callback) {
    request('GET', '/sources/list', '', callback);
}

function listTags(callback) {
    request('GET', '/tags', '', callback);
}

function listItems(type, page, callback, tag, sourceId) {
    type = type || 'unread';
    page = page || 0;
    var params = 'items=' + 20 + '&offset=' + page * 20;    // TODO 20: pageItems
    if (sourceId) {
        params += '&source=' + sourceId;
    } else if (tag) {
        params += '&tag=' + tag;
    }
    if (type !== 'newest') params += '&type=' + type;
    request('GET', '/items', params, callback);
}

function markAllRead(ids, callback) {
    if (!Array.isArray(ids) || ids.length < 1) { return; }
    var data = 'ids%5B%5D=' + ids[0];
    for (var i=1; i<ids.length; i++) {
        data += '&ids%5B%5D=' + ids[i];
    }
    request('POST', '/mark/', data, callback);
}

function toggleStat(stat, itemId, callback) {
    switch (stat) {
        case 'read':
            request('POST', '/mark/' + itemId, '', callback);
            break;
        case 'unread':
            request('POST', '/unmark/' + itemId, '', callback)
            break;
        case 'starr':
            request('POST', '/starr/' + itemId, '', callback);
            break;
        case 'unstarr':
            request('POST', '/unstarr/' + itemId, '', callback);
            break;
        default:
            break;
    }
}

function getStats(callback) {
    request('GET', '/stats', '', callback);
}

// Helpers
function decodeCharCode(str) {
    str = str.replace(/alt=""/g, '');
    str = str.replace(/<br \/><br \/><a href=\"http:\/\/rc.feedsportal.com.*/, ''); // Solidot
    return str.replace(/(&#[\d]*;)/g, function(p1) {
            var pp=p1.substr(2, p1.length-3);
            return String.fromCharCode(pp);
        });
}
