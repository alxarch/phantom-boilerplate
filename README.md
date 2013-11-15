phantom-boilerplate
===================

Boilerplate code for phantomjs tasks


## Usage

```js
var bo = require './phantom-boilerplate';

var page = bo.page()

// Will read a file from test/ and pass it to the client (async)
page.on('read', bo.filereader('test/'))

// On the page

var promise = window.phantom.send('read', 'somefile.txt')

promise.then(function(data){
  // data holds contents of requested file
  console.log(data)
})

```
