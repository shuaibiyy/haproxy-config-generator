module.exports = [
  {
    "mode": "host",
    "name": "example",
    "predicate": "example.com",
    "cookie": "JSESSIONID",
    "servers": [
      {
        "name": "app1",
        "ip"  : "192.168.1.5"
      },
      {
        "name": "app2",
        "ip"  : "192.168.1.7"
      }
    ]
  },
  {
    "mode": "path",
    "name": "multiservice",
    "predicate": "service",
    "servers": [
      {
        "name": "service1",
        "ip"  : "10.0.0.5"
      },
      {
        "name": "service2",
        "ip"  : "10.0.0.6"
      }
    ]
  }
]
