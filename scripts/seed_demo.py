from check_emulators import auth, request, DB
import datetime

email = 'demo@exemplo.com'
password = 'Teste123!'
status, user = auth('signUp', {'email': email, 'password': password, 'returnSecureToken': True})
if status != 200:
    status, user = auth('signInWithPassword', {'email': email, 'password': password, 'returnSecureToken': True})
assert status == 200, 'Não foi possível preparar a conta local.'
path = f"users/{user['localId']}/notes/boas-vindas"
status, _ = request(DB + path, token=user['idToken'])
if status == 404:
    status, _ = request(DB + path, {'fields': {
        'note': {'stringValue': 'Minha primeira nota! Você pode editar ou excluir esta anotação.'},
        'timestamp': {'timestampValue': datetime.datetime.now(datetime.timezone.utc).isoformat()},
    }}, user['idToken'], 'PATCH')
    assert status == 200
print('Conta local preparada: demo@exemplo.com / Teste123!')
