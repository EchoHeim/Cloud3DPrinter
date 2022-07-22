
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const fs = require('fs');

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

app.post('/data/wifi/update', (req, res) => {
    console.log('req = ', req)
    let ssid = Object.keys(req.query).length === 0 ? req.body.ssid : req.query.ssid
    let pw = Object.keys(req.query).length === 0 ? req.body.pw : req.query.pw
    let refresh = Object.keys(req.query).length === 0 ? req.body.refresh : req.query.refresh

    console.log('req.query = ', req.query)
    console.log('ssid = ', ssid, ' , pw = ', pw, ', refresh = ', refresh)
    //res.json(req.query.username);

    let content = '';
    if (ssid !== '' && pw !== '') {
        content = 'WIFI_SSID=' + ssid + '\n' + 'WIFI_PASSWD=' + pw + '\n' + 'N'
    } else if (refresh === 'Y') {
        content = '\n' + '\n' + 'Y'
    } else {
        res.end('Wrong queries')
    }

    //fs.writeFile('./conf/netinfo.txt', content, err => {
    fs.writeFile('/home/biqu/Cloud3DPrinter/wifi/conf/netinfo.txt', content, err => {
        if (err) {
            console.error(err);
        }
        // file written successfully
    });

    res.end('success')
})

app.listen(8888, () => {
    console.log('node server running on http://127.0.0.1:8888');
})

