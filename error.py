python3 -c "import base64,json; s='eyJoZWFkZXIiOiJzdHJpbmciLCJib2R5IjoiMjAyNi0wNy0zMCAxMjoyNTo0NSArMDAwMCBVVEMifQ=='; outer=json.loads(base64.b64decode(s)); print(outer['body'][:250])"
