import urllib.request
import json

base_url = "https://firestore.googleapis.com/v1/projects/trade-wign-bd/databases/(default)/documents/app_settings/"

with open('base64.txt') as f:
    b64 = f.read().strip()

data = {
    "fields": {
        "base64": {"stringValue": b64}
    }
}

for doc in ['logo_light', 'logo_dark']:
    url = f"{base_url}{doc}?updateMask.fieldPaths=base64&key=AIzaSyCzaX2MBI2Uk8Qnil_AtqmxuHErBcK0qQQ"
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), method='PATCH')
    req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req) as res:
            print(f"{doc} status: {res.status}")
    except urllib.error.URLError as e:
        print(f"Error on {doc}: {e}")
        if hasattr(e, 'read'):
            print(e.read().decode('utf-8'))
