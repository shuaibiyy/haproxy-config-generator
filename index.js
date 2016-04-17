/**
 * Provide an event that contains an array of objects with the following keys:
 *
 *   - mode: type of routing. It can be either `path` or `host`.
 *           In `path` mode, the URL path is used to determine which backend to forward the request to.
 *           In `host` mode, the HTTP host header is used to determine which backend to forward the request to.
 *           Defaults to `host` mode.
 *   - name: name of cluster the servers will be grouped within.
 *   - predicate: value used along with mode to determine which cluster the request will be forwarded to.
 *                `path` mode example: `acl <cluster> url_beg /<predicate>`.
 *                `host` mode example: `acl <cluster> hdr(host) -i <predicate>`.
 *   - cookie: name of cookie to be used for sticky sessions. If not defined, sticky sessions will not be configured.
 *   - servers: key-value pairs of server names and their corresponding IP addresses.
 *
 *   Example:
 *   =======
 *   [
 *     {
 *       "mode": "host",
 *       "name": "example",
 *       "predicate": "example.com",
 *       "cookie": "JSESSIONID",
 *       "servers": [
 *         {
 *           "name": "app1",
 *           "ip"  : "192.168.1.5"
 *         },
 *         {
 *           "name": "app2",
 *           "ip"  : "192.168.1.7"
 *         }
 *       ]
 *     },
 *     {
 *       "mode": "path",
 *       "name": "multiservice",
 *       "predicate": "service",
 *       "servers": [
 *         {
 *           "name": "service1",
 *           "ip"  : "10.0.0.5"
 *         },
 *         {
 *           "name": "service2",
 *           "ip"  : "10.0.0.6"
 *         }
 *       ]
 *     }
 *   ]
 *
 */

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2))

  const nunjucks = require('nunjucks')

  nunjucks.configure('template', { autoescape: true })
  const computedConfig = nunjucks.render('haproxy.cfg.njk', {clusters: event})

  context.done(null, computedConfig)
}
