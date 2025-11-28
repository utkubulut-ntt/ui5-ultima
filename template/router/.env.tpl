PORT=1299
MOCK_PORT=1300
MOCK_DIR=["../{{UI_MODULE}}"]
MOCK_LOOKUP_DIRS=["dist"]
destinations=[{ "name": "backend-api", "url": "http://localhost:4004", "forwardAuthToken": true }]
VCAP_SERVICES={}