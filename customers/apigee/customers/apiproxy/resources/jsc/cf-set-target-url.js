/* retrieve variable saved from cf-header and assign target.url */
//var cfurl = context.getVariable('cf-url')
//context.setVariable('target.url', cfurl)

var requestURI = context.getVariable('request.uri');
var cfurl = context.getVariable('request.header.X-Cf-Forwarded-Url');

var r = /^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/
var parts = r.exec(cfurl)

//var base = 'http://localhost:8998' + requestURI;
//This sets the base path to localhost 8998 and the base path to the same path that is included in the X-CF-forwarded-url header.
//it also includes the query parameters if any
var base = 'http://localhost:8998';
if (parts[6]) {
    context.setVariable('target.url', base + parts[5] + parts[6])
} else {
    context.setVariable('target.url', base + parts[5])
}
