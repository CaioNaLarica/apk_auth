import datetime
import json
import time
import urllib.error
import urllib.request
import uuid

AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/'
DB = 'http://127.0.0.1:8085/v1/projects/demo-apk-auth/databases/(default)/documents/'

def request(url, data=None, token=None, method=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    req = urllib.request.Request(url, data=None if data is None else json.dumps(data).encode(), headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)

def auth(action, data):
    return request(AUTH + 'accounts:' + action + '?key=demo-api-key', data)

def signup():
    email = f'rules-{uuid.uuid4().hex[:12]}@exemplo.com'
    status, result = auth('signUp', {'email': email, 'password': 'Teste123!', 'returnSecureToken': True})
    assert status == 200, (status, result)
    return result

if __name__ == '__main__':
    first, second = signup(), signup()
    path = f"users/{first['localId']}/notes/check-{time.time_ns()}"
    fields = {'fields': {'note': {'stringValue': 'Nota privada'}, 'timestamp': {'timestampValue': datetime.datetime.now(datetime.timezone.utc).isoformat()}}}
    try:
        assert request(DB + path, fields, first['idToken'], 'PATCH')[0] == 200
        assert request(DB + path, token=first['idToken'])[0] == 200
        assert request(DB + path, token=second['idToken'])[0] == 403
        assert request(DB + path, fields, second['idToken'], 'PATCH')[0] == 403
        assert request(DB + path, token=second['idToken'], method='DELETE')[0] == 403
        assert request(DB + path)[0] == 403
        empty = {'fields': {**fields['fields'], 'note': {'stringValue': ''}}}
        assert request(DB + path, empty, first['idToken'], 'PATCH')[0] == 403
        status, _ = auth('sendOobCode', {'requestType': 'PASSWORD_RESET', 'email': first['email']})
        assert status == 200
        status, codes = request('http://127.0.0.1:9099/emulator/v1/projects/demo-apk-auth/oobCodes')
        assert status == 200 and any(code['email'] == first['email'] and code['requestType'] == 'PASSWORD_RESET' for code in codes['oobCodes'])
        print('PASSOU: escrita/leitura, isolamento entre contas, bloqueio anônimo, validação da nota e link de redefinição.')
    finally:
        request(DB + path, token=first['idToken'], method='DELETE')
        for user in (first, second):
            auth('delete', {'idToken': user['idToken']})
